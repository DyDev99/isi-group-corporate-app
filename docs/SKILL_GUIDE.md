---
name: isi-feature-development
description: >
  Development procedure for the ISI Steel Sales Mobile app (Flutter, offline-first
  Clean Architecture with flutter_bloc + get_it). Use when creating a new feature,
  extending the HR Assistant or Company Directory, or changing any code under
  lib/features/. Covers the required layer order, the file-by-file build sequence,
  the test tiers that gate merge, and the release checklist. Read this before
  writing code; it encodes constraints not visible from any single file.
---

# SKILL: ISI Feature Development

This is an operational guide for an AI coding agent (Claude Code, Cursor) working
in this repository. It is imperative and checklist-driven on purpose. Follow the
phases in order. Do not skip the read phase. When a rule here conflicts with a
pattern you infer from a single file, this guide and `ENGINEERING_STANDARD.md`
win.

The architecture and invariants behind these steps are in `FEATURE_BLUEPRINT.md`
and `ARCHITECTURE.md`. This document is the procedure; those are the rationale.

---

## 0. Golden rules (violating any is a defect, even if it compiles)

1. **Dependencies point inward:** `presentation → domain → data`. Never import
   `presentation` from `domain`, or one feature's internals from another.
2. **`domain/` is pure Dart.** No `package:flutter`, `drift`, `dio`,
   `get_it`, or `hive` imports there. Entities hold an accent *index*, not a
   `Color`.
3. **Widgets never call a datasource.** Widget → bloc event → usecase →
   repository → datasource. One direction.
4. **Immutability.** Rebuild state with `copyWith`. Never mutate an entity or a
   bloc state field in place.
5. **One usecase per action**, exposed as `call(...)`.
6. **Typed failures only** reach presentation (`domain/failures/`). No raw
   exception or stack trace shown to a user.
7. **Offline is normal.** No feature may hard-depend on the network on a hot
   path without a graceful fallback (`ARCHITECTURE.md` §1).
8. **No module ahead of its dependencies.** Do not build a `data/local` layer
   against a Drift table that does not exist yet (`ENGINEERING_STANDARD.md` §2).

---

## 1. Phase READ — before writing anything

Do this every time. It is cheap and prevents the most common failure: generating
code against a structure that does not match the repo.

```text
1. Read ENGINEERING_STANDARD.md and ARCHITECTURE.md (§3–§7 at minimum).
2. Read FEATURE_BLUEPRINT.md for the feature you will touch.
3. List the feature tree:      lib/features/<feature>/**
4. Open, in this order:        domain/entities → domain/usecases →
                               data/repositories → presentation/bloc →
                               the widget you will change.
5. Identify the ONE file that owns the thing you are changing.
   Prefer editing that file over adding a parallel one.
```

If a referenced type, field, or method is not in the files you read, it does not
exist — do not assume it. Confirm names against the actual code.

---

## 2. Phase BUILD — the layer order is the build order

Always build inward-out, compiling after each layer. Never start at the widget.

### 2.1 A new feature (scaffold order)

```text
domain/entities/*.dart          Pure data + pure logic. Unit-testable now.
domain/repositories/<f>_repository.dart   Abstract interface only.
domain/usecases/<f>_usecases.dart         One class per action, call(...).
data/datasources/<f>_mock_datasource.dart Mock first. ALL demo data here.
data/repositories/<f>_repository_impl.dart Maps datasource → entities; typed failures.
presentation/theme/<f>_tokens.dart         Colours/radii/durations/shadows.
presentation/bloc/<f>_bloc.dart (+_event,_state)   All logic. Immutable state.
presentation/widgets/*.dart                Dumb; read state, dispatch events.
presentation/pages/<f>_screen.dart         Compose widgets under a BlocBuilder.
<f>_injection.dart                          register<F>Feature(GetIt sl).
<f>_scope.dart                              Optional hand-wired entry for tests/demo.
```

Compile-first tactic: if you do not yet know a real constructor signature, make
the usecase or repository method throw `UnimplementedError()` rather than
guessing. The project must stay compilable at every commit.

### 2.2 Extending an existing feature

Find the layer that owns the change and work outward only as far as needed:

| You are adding… | Start in | Then touch |
|---|---|---|
| A new field on an entity | `domain/entities` | mock datasource, any mapper, widgets that show it |
| A new filter/search facet | `domain/entities` (the filter object) | bloc event+handler, filter widget |
| A new answer type / payload | `domain/entities` + sealed event | bloc handler, a new render widget |
| A new action (call/export/…) | `domain/usecases` | repository (+impl), bloc event, widget |
| Visual-only change | `presentation/theme` or the widget | nothing below presentation |

Never add a data field by reaching from a widget into the datasource. Thread it
through the entity.

### 2.3 Data & mock conventions

- All demo data lives in the feature's **mock datasource**, nowhere else.
- Derive structural facts; do not store them (e.g. `directReports =
  children.length`). A stored count that can disagree with the structure is a
  bug (this is the Directory's original `childrenCount` defect).
- The repository sets typed failures and (for syncable tables, when real) marks
  `dirty` + enqueues in the same transaction (`ENGINEERING_STANDARD.md` §6).
- Mark every temporary shortcut with `// TODO(release-gate):` and a one-line
  reason. CI greps for these on release branches.

### 2.4 Presentation conventions

- One bloc per feature-slice. Events imperative (`...Requested`, `...Changed`),
  states are outcomes with a value-equality `==`.
- No global auth-redirect listener; each surface owns its transition
  (`ENGINEERING_STANDARD.md` §4).
- Motion: use the feature's token durations/curves. Any `Matrix4`/transform
  animation must emit a **new** matrix each frame (see §6 gotcha 1).
- Cross-feature widgets (e.g. `AppearOnce`, `GridBackground`) belong in
  `shared/widgets/`, never imported feature-to-feature.
- New user-facing text is localized (en + km). No hardcoded display strings.

---

## 3. Phase WIRE — dependency injection

```text
1. In <f>_injection.dart, register datasource, repository, usecases (lazy
   singletons) and the bloc (factory):
       void registerXFeature(GetIt sl) { … sl.registerFactory(() => XBloc(...)); }
2. Call registerXFeature(sl) once from core/di/injection_container.dart,
   in the Features block, respecting dependency order.
3. Provide the bloc where it is used. For a shell tab, add it to the shell's
   MultiBlocProvider so state survives tab switches; seed its start event.
4. Do NOT also mount the *_scope.dart widget for the same feature. One graph.
```

If a screen throws `ProviderNotFoundException`, the bloc was not provided above
it — fix the provider, do not wrap the screen in its own scope as a workaround
(that creates the second graph rule 3 forbids).

---

## 4. Phase TEST — tiers that gate merge (`ENGINEERING_STANDARD.md` §10)

Write tests in the same PR as the code. Minimum tiers by what you touched:

| Touched | Required test | Coverage gate |
|---|---|---|
| `domain/` (entities, usecases, tree/filter logic) | Unit (`flutter_test`, `mocktail`) | ≥ 90% |
| `data/` (repository, mappers) | Unit, mocked datasource | ≥ 80% |
| Pure algorithms (layout solver, backoff, key derivation) | Unit; 100% of branches for crypto/sync | 100% branch (crypto/sync) |
| `presentation/` state/widgets | Widget (`flutter_test`) | — |
| Visual (light/dark, en/km) | Golden (`golden_toolkit`) | — |

What to assert, concretely:

- **Directory:** `applyFilter` keeps matches + connecting ancestors; `pathTo`
  is root-first; `directReports`/`descendantCount` equal the structure; layout
  solver places siblings without overlap and centres parents over children.
- **HR Assistant:** a matched intent completes with the right sources and
  payload and confidence > 0.9; an unmatched question completes with
  confidence < 0.5 and no fabricated payload; scope filters the corpus.

Run locally before opening a PR:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --coverage
```

All three must be clean/green. A red analyzer or a formatting diff blocks merge.

---

## 5. Phase SHIP — release checklist

Merge only when every box holds (this is `FEATURE_BLUEPRINT.md` §6 + §12 of the
standard):

```text
[ ] flutter analyze clean, dart format clean
[ ] required test tiers green; coverage gates met
[ ] new strings localized (en + km)
[ ] domain/ has no Flutter/drift/dio imports
[ ] no feature-to-feature data/ or presentation/ import
[ ] no un-fallbacked network dependency on a hot path
[ ] every // TODO(release-gate): is intended for this release or removed
[ ] debug-only escape hatches (e.g. TLS override in main.dart) are behind
    kDebugMode and NOT active in release
[ ] independent reviewer approved
```

Release-branch CI additionally greps for `// TODO(release-gate):` and fails if
any remain. Never disable that check to land a branch.

---

## 6. Known gotchas (each caused a real bug in this codebase)

1. **`TransformationController` won't repaint on an in-place matrix mutation.**
   It is a `ValueNotifier`; `controller.value..scale(x)` reassigns the same
   instance, so `old == new` and no notification fires. Build a *new* `Matrix4`
   and assign/animate to it. (Directory zoom.)
2. **A `ListTile` inside a coloured `DecoratedBox`/`Container` throws** "ink may
   be invisible." `ListTile` paints its fill and ripple on the nearest
   `Material`. Put the fill on a `Material` (keep border/shadow on the outer
   box), or make the tile transparent. Do not colour the intermediate box.
3. **`Image.network` can fail with `CERTIFICATE_VERIFY_FAILED`** behind an
   HTTPS-inspecting proxy/AV, and is always blank offline. Every network image
   needs an `errorBuilder` → initials/placeholder. Prefer bundled assets for an
   offline-first app; if a dev machine must load remote images, gate a TLS
   override behind `kDebugMode` in `main.dart` and never ship it.
4. **Storing a count that duplicates structure** (e.g. `childrenCount`) drifts
   from reality. Derive it.
5. **Mutable widget state as the source of truth** (applied filters kept in
   `setState`, then `debugPrint`-ed) loses data on rebuild. The bloc owns state.
6. **Language change remounts the tree.** Do not hold un-restorable state in a
   widget that a locale switch will rebuild; keep it in the bloc.

---

## 7. Definition of a good PR (self-check for the agent)

Before you present a diff as done, confirm you can answer yes to all:

- Did I edit the one owning file rather than add a parallel one?
- Does every new public type have a one-line doc comment stating its contract?
- Is all demo data in the mock datasource, and nothing hardcoded in a widget?
- Did I add or update tests in the same change, at the required tiers?
- Did I run analyze + format + test and paste the results?
- Did I leave the app compilable at each step (no half-wired layer)?
- Did I flag, in prose, any invariant I could not satisfy and why — rather than
  silently working around it?

If any answer is no, the change is not done.
