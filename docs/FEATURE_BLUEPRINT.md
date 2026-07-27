# Feature Blueprint — HR Assistant & Company Directory

> ISI Steel Sales Mobile — Offline-First Enterprise CRM (Flutter)
> Blueprint and reference architecture for two shipped features.
> Implements the rules in `ENGINEERING_STANDARD.md`; conforms to `ARCHITECTURE.md`.
> Status: Reference · v1.0 · Companion to `SKILL_GUIDE.md` (development procedure).

---

## 1. Purpose

This document is the architectural blueprint for two features built to the
project standard: the **HR Assistant** (a grounded question-answering surface
over company policy) and the **Company Directory** (an interactive org chart
and people search). It describes what each feature is, how it is layered, the
contracts between layers, and the invariants that must hold. It is the "what
and why." The companion `SKILL_GUIDE.md` is the "how" — the step-by-step
procedure a developer or AI agent follows to change these features safely.

Both features were built as **UI-complete vertical slices backed by a mock
datasource**, deliberately: they exercise the full Clean Architecture stack
(presentation → domain → data) so that swapping the mock for a real
remote/Drift datasource requires changes to exactly one file per feature and
nothing above the datasource boundary. This is the same posture the rest of the
app takes toward its unbuilt infrastructure (`ARCHITECTURE.md` §1).

---

## 2. Shared architectural position

Both features obey the project's layering rule — dependencies point inward
only, and no layer reaches around the one beneath it:

```
presentation  →  domain  →  data
   (BLoC,          (entities,        (repository impl,
    widgets)        usecases,         mock datasource,
                    repo interface)   — future: remote + Drift)
```

The following invariants are load-bearing. A change that violates any of them
is a defect regardless of whether it compiles:

1. **Domain is pure Dart.** No `package:flutter`, no `drift`, no `dio` imports
   under `domain/`. Entities carry an accent *index*, never a `Color`.
2. **Widgets never touch a datasource.** They read bloc state and dispatch
   events. All data access is through a usecase, called by the bloc.
3. **State is immutable.** Entities and bloc states are rebuilt with `copyWith`;
   no field is mutated in place. (The original pre-rebuild screens mutated
   widget state directly — this is the specific regression being prevented.)
4. **One usecase per business action**, callable as `call(...)`. No "god"
   usecase that branches on a mode flag.
5. **Typed failures only** cross into presentation — never a raw exception or
   stack trace (`ENGINEERING_STANDARD.md` §7).
6. **One shared value, one place.** Colours, radii, durations and shadows live
   in a feature `*_tokens.dart`; cross-feature widgets live in `shared/`.

---

## 3. Feature A — Company Directory

### 3.1 What it is

An interactive organisation chart and people directory: a zoomable/pannable
reporting tree, a flat searchable list, faceted filtering (company, department,
presence), and a per-person profile with reporting line and direct reports.

### 3.2 Layer map

```
features/directory/
├── directory_scope.dart              Drop-in entry point (builds the graph by hand)
├── directory_injection.dart          registerDirectoryFeature(GetIt) — app path
├── domain/
│   ├── entities/
│   │   ├── employee.dart             Employee · Company · Department · PresenceStatus
│   │   ├── directory_filter.dart     Immutable faceted filter value object
│   │   └── org_tree.dart             OrgNode · OrgTree · FilteredOrg (prune + paths)
│   ├── repositories/directory_repository.dart
│   └── usecases/directory_usecases.dart   GetOrgTree · GetCompanies · GetDepartments
├── data/
│   ├── datasources/directory_mock_datasource.dart   30-person tree, 4 companies, 9 depts
│   └── repositories/directory_repository_impl.dart
└── presentation/
    ├── bloc/        directory_bloc · _event · _state
    ├── layout/      org_layout.dart      Pure tidy-tree solver (no widgets)
    ├── theme/       directory_tokens.dart
    ├── pages/       directory_screen.dart
    └── widgets/     org_chart_canvas · org_node_card · connector_painter
                     directory_top_bar · filter_sheet · employee_directory_sheet
                     people_list_view · match_carousel · employee_avatar · appear_once
```

### 3.3 Domain model

`OrgTree` wraps a root `OrgNode`; every node holds an `Employee` and its
children. Structural facts are **derived, never stored**: `directReports` is
`children.length`, `descendantCount` recurses. This is a hard rule — an earlier
model carried a hand-written `childrenCount` that disagreed with the actual
children and put expander controls on childless nodes. Storing a count that can
drift from the structure is prohibited.

Key operations, all pure and unit-tested:

| Operation | Contract |
|---|---|
| `applyFilter(filter)` | Returns a `FilteredOrg`: the pruned tree, the set of matched ids, and the set of ancestor ids kept only to connect matches to the root. |
| `pathTo(id)` | Root→node inclusive, for the reporting-line breadcrumb and auto-expand. Empty list if not found. |
| `peersOf(id)` | The person's manager's other reports — backs profile-sheet swiping. |
| `everyone` / `headcount` | Flattened list / count, for the list view and filter previews. |

`DirectoryFilter` is an immutable value object with `matches(employee)`,
`activeCount`, and `toggle*`/`copyWith` builders. It is the single source of
truth for "what is currently shown," owned by the bloc — not by any widget.

### 3.4 Presentation contract

`DirectoryBloc` owns all logic: search, faceted filtering, node expansion,
selection, view mode (chart/list) and a one-shot `focusId` that asks the chart
to animate its camera to a node. Events are imperative
(`DirectorySearchChanged`, `DirectoryNodeToggled`, `DirectoryFocusRequested`);
state is a single immutable `DirectoryState` with a value-equality `==`.

The chart is not a widget tree of nested rows. `org_layout.dart` is a **pure
tidy-tree solver** that computes an absolute position for every visible node;
`OrgChartCanvas` renders those positions inside an `InteractiveViewer`, and
`ConnectorPainter` draws exact elbow connectors between them. Separating the
solver from the renderer is what makes the connectors correct (they were a
half-width guess before) and every layout change animatable.

### 3.5 Feature invariants (beyond the shared six)

- **Zoom transforms must produce a new `Matrix4`.** `TransformationController`
  is a `ValueNotifier`; mutating its matrix in place and reassigning the same
  instance does not notify and does not repaint. This was the original zoom
  bug. Every zoom/fit builds a fresh matrix and animates to it.
- **Avatars never block on the network.** `EmployeeAvatar` shows initials while
  a photo loads and stays on initials on any failure (offline, 404, refused TLS
  handshake). Faces are an enhancement; the directory is fully usable with none.
- **The camera pivots on the viewport centre** for button zoom, and on the tap
  point for double-tap — never on the canvas origin.

---

## 4. Feature B — HR Assistant

### 4.1 What it is

A grounded question-answering surface over company HR policy: a chat interface
that streams answers, shows the source documents each answer was built from,
renders structured payloads (e.g. a leave-balance card), and lets the user
browse the underlying policy corpus in a Knowledge Center. Every answer is
attributed to documents; the assistant declines rather than inventing when it
has no grounding.

### 4.2 Layer map

```
features/hr_assistant/
├── hr_assistant_scope.dart           Drop-in entry point
├── hr_assistant_injection.dart       registerHrAssistantFeature(GetIt)
├── domain/
│   ├── entities/     chat_message · knowledge_doc · leave_balance
│   │                 answer_event (sealed) · hr_category
│   ├── failures/     hr_failure.dart (sealed typed failures)
│   ├── repositories/ hr_assistant_repository.dart
│   └── usecases/     Ask · GetGreeting · GetSuggested · SearchDocs · GetLeaveBalance
├── data/
│   ├── datasources/  hr_assistant_mock_datasource.dart   corpus + intents + fake stream
│   └── repositories/ hr_assistant_repository_impl.dart
└── presentation/
    ├── bloc/     hr_chat_bloc · _event · _state
    ├── theme/    hr_tokens.dart
    ├── pages/    hr_ai_assistant_screen.dart
    └── widgets/  chat_bubble · chat_composer · source_carousel · doc_viewer_sheet
                  knowledge_center_sheet · leave_balance_card · suggested_questions
                  typing_indicator
```

### 4.3 Streaming contract

`ask()` returns a `Stream<AnswerEvent>`, where `AnswerEvent` is a **sealed**
type: `AnswerRetrieving` → zero or more `AnswerTextChunk` → one
`AnswerCompleted` (carrying sources, optional payload, follow-ups, confidence).
Sealing it makes the bloc's handling exhaustive — a new event kind becomes a
compile error rather than a silently dropped branch. The bloc appends a
streaming placeholder message, patches its text on each chunk, and finalises it
on completion; a stop control sets a flag the stream loop checks.

### 4.4 Grounding invariant

An answer must not present a confident claim it cannot attribute. The mock
resolves an intent by keyword; an unmatched question returns a low-confidence
answer that says it found nothing and points to the Knowledge Center, never a
fabricated policy. When the real retrieval service replaces the mock, this
invariant transfers: the confidence meter and the source carousel are driven by
retrieval, and an ungrounded answer must render as ungrounded.

### 4.5 Feature invariants (beyond the shared six)

- **The answer stream is the only writer of assistant message text.** Widgets
  render `ChatMessage`; they never compose answer content.
- **Child-safety / accuracy posture:** the assistant answers only from the
  corpus. Do not add a code path that free-generates policy text outside the
  grounded intent set without a corresponding source.

---

## 5. Wiring (both features)

Two supported paths. In this app, use DI.

**DI path (production).** Each feature exposes one
`register<Feature>Feature(GetIt sl)` at its root, called once from the app-level
`initDependencies()` in `core/di/injection_container.dart`
(`ENGINEERING_STANDARD.md` §5). Blocs are provided at shell level so filters,
expansion and chat history survive tab switches:

```dart
// injection_container.dart
registerDirectoryFeature(sl);
registerHrAssistantFeature(sl);

// main_shell.dart — MultiBlocProvider
BlocProvider(create: (_) => sl<DirectoryBloc>()..add(const DirectoryStarted())),
BlocProvider(create: (_) => sl<HrChatBloc>()..add(const HrChatStarted())),
```

`BlocProvider.create` is lazy — nothing is constructed until the tab is first
opened.

**Scope path (demo/isolation).** `DirectoryScope` / `HrAssistantScope` build the
object graph by hand and need no service locator — useful for widgetbook, tests
or a standalone demo. **Do not ship both paths for the same feature**; two
graphs for one feature drift apart. Once the DI path is wired, delete the scope
file or keep it only for tests.

---

## 6. Definition of Done (per `ENGINEERING_STANDARD.md` §10 & §12)

A change to either feature is shippable only when all of the following hold.
This is the gate `SKILL_GUIDE.md` §7 automates.

- [ ] `flutter analyze` clean; `dart format --set-exit-if-changed` clean.
- [ ] Domain unit tests pass; coverage ≥ 90% domain, ≥ 80% data.
- [ ] New user-facing strings are localized (en + km), not hardcoded.
- [ ] No `package:flutter` / `drift` / `dio` import under `domain/`.
- [ ] No widget imports another feature's `data/` or `presentation/`.
- [ ] No network image or call on a hot path without a graceful offline
      fallback (ARCHITECTURE §1).
- [ ] Any temporary shortcut carries a `// TODO(release-gate):` tag; CI greps
      for these on release branches (§11).
- [ ] A reviewer independent of the author approved the PR.

---

## 7. Known gaps (tracked, not yet built)

Deliberate for the current demo stage; each is a follow-up, not a defect:

| Gap | Feature | Closes when |
|---|---|---|
| Real datasource behind the repository (remote + Drift cache) | Both | SAP gateway + Drift DAOs land (`MIGRATION_PLAN.md`) |
| Khmer localization of UI strings | Both | Strings moved to the localization layer |
| Dark-theme token values | Both | `*_tokens.dart` gains dark palettes |
| Widget + golden tests (light/dark, en/km) | Both | §10 golden tier implemented |
| RBAC gating (phone numbers, full tree, salary-adjacent data) | Directory | Organization/Role model exists (ARCHITECTURE §6) |
| Node virtualisation past a few hundred people | Directory | Perf budget requires it |
| Retrieval with real citation offsets | HR Assistant | Retrieval service replaces the mock |
| Offline cache of recent answers | HR Assistant | `OFFLINE_FIRST.md` §4 posture decided |

---

## 8. Related documents

- `ENGINEERING_STANDARD.md` — rules that govern all code
- `ARCHITECTURE.md` — system layers, persistence, dependency graph
- `SKILL_GUIDE.md` — step-by-step development procedure for these features (AI-agent oriented)
- `OFFLINE_FIRST.md`, `DATABASE_GUIDE.md`, `SECURITY.md`, `MIGRATION_PLAN.md`
