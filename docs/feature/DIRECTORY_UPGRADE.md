# Directory / Org Chart — full-architecture upgrade

Rebuild of `directory_screen.dart` as a complete vertical slice against
`ENGINEERING_STANDARD.md` §3–§7 and `AI_ENGINEERING_PLAYBOOK.md` §4/§13, with a
mock datasource standing in for the organisation service.

## 1. Defects found in the original screen

| # | Finding | Rule broken |
|---|---|---|
| 1 | **Zoom silently did nothing.** `_zoomIn()` called `matrix.scale(1.1)` on the controller's own `Matrix4` and assigned the *same object* back. `TransformationController` is a `ValueNotifier` — `old == new`, so no notification, no repaint. | — (real bug) |
| 2 | Search field had no controller, no `onChanged`, no filtering | — |
| 3 | Applied filters ended in `debugPrint("Filters applied: …")` and were discarded | STD §4 |
| 4 | "1,243 Employees" preview was a hardcoded string, unrelated to the data | — |
| 5 | Both search fields inside the filter sheet filtered nothing | — |
| 6 | `childrenCount` contradicted `children` — Sarah "12" with 2 children; Michael "8" with none, so his expander opened nothing | — |
| 7 | `OrgNodeData.isExpanded` was **mutable** and duplicated in widget state | STD §3, PLAYBOOK §1 |
| 8 | Card actions (mail/call/more) lived behind `MouseRegion` hover — unreachable on a phone, yet always occupying layout height at `opacity: 0` | — |
| 9 | `Image.network` avatars in an **offline-first** app | ARCHITECTURE §1, §3 |
| 10 | Connector lines drawn by a `LayoutBuilder` half-width guess — wrong whenever subtree widths differ | — |
| 11 | Data, models, widgets and state in one 989-line file; no domain, repository, usecase or bloc | STD §3–§6 |
| 12 | ~60 inline hex literals across three classes | — |

## 2. File map

```
lib/features/directory/
├── directory_scope.dart              ← drop-in entry point (no get_it needed)
├── directory_injection.dart          ← registerDirectoryFeature(sl) for the app
├── domain/
│   ├── entities/  employee · directory_filter · org_tree
│   ├── repositories/DirectoryRepository
│   └── usecases/  GetOrgTree · GetCompanies · GetDepartments
├── data/
│   ├── datasources/directory_mock_datasource.dart   ← ALL demo data
│   └── repositories/directory_repository_impl.dart
└── presentation/
    ├── bloc/    directory_bloc · _event · _state
    ├── layout/  org_layout.dart      ← tidy-tree solver (pure, tested)
    ├── theme/   directory_tokens.dart
    ├── pages/   directory_screen.dart
    └── widgets/ org_chart_canvas · org_node_card · connector_painter
                 directory_top_bar · filter_sheet · employee_directory_sheet
                 people_list_view · match_carousel · appear_once
test/features/directory/  org_tree_test.dart · org_layout_test.dart
```

Domain is pure Dart — zero Flutter imports. No widget touches the datasource.

## 3. Wiring

Only `flutter_bloc` is required (already in the app):

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const DirectoryScope()),
);
```

## 4. What works now

**Zoom** — pinch, double-tap (zooms to the point you tapped, again to fit),
and ±/fit buttons with a live percentage. Every transform is a *new* `Matrix4`,
animated over 280 ms, clamped 25 %–250 %, pivoting on the viewport centre.
Opening a profile or swiping the results carousel pans the camera to that person.

**Filter** — company (single), department (multi), presence (multi) and
free-text search over name, role, location and email. Facets combine, the sheet
shows a live "N of 30 people" preview computed from the tree before you apply,
per-facet headcounts are real, and the two in-sheet search fields work. Matches
glow, non-matching ancestors dim to 45 % so the branch stays readable, and the
branch containing every hit auto-expands.

**Swipe** — list rows swipe right to call, left to email (they spring back, since
a contact is not a delete); the profile sheet is a `PageView` across teammates;
the results carousel swipes through hits and drives the chart; sheets drag to
dismiss.

**Chart** — a real tidy-tree solver places every card, so connectors are exact
rounded elbows drawn by a `CustomPainter` and animated in on every shape change.
Nodes move with `AnimatedPositioned`, enter with a staggered fade-scale, and the
branch to a search hit is drawn in the brand colour.

**Cards** — initials-on-gradient avatars per department accent (no network),
presence dot, department chip, location · company line, and a reports pill that
counts *actual* children and rotates as it expands. Tap opens the profile,
long-press opens quick actions — both reachable without a mouse.

**Also** — chart ⇄ list view toggle, expand-all / collapse-all, filter badge,
copy contact, reporting-line breadcrumb, direct-reports list, empty states.

## 5. Mock data

30 people across five levels, four companies and nine departments, all in
`directory_mock_datasource.dart`: Phnom Penh, Sihanoukville, Battambang, Siem
Reap and Kampot locations, `@isigroup.com.kh` addresses, tenure dates and mixed
presence. Reports counts are derived from the tree, so defect #6 cannot recur.

## 6. Definition of Done — still open

Honest gaps against `ENGINEERING_STANDARD.md` §10, deliberate for a demo:

- [ ] Widget + golden tests for the screen (light/dark, en/kh)
- [ ] Khmer localization — strings are hardcoded English
- [ ] Real datasource behind the repository, with a Drift cache and the offline
      posture declared in `OFFLINE_FIRST.md` §4
- [ ] Avatar photos as filesystem references (ARCHITECTURE §3 Layer 4), never
      `Image.network`
- [ ] RBAC gate — phone numbers and the full tree should respect permissions
      once the Organization/Role model exists (ARCHITECTURE §6)
- [ ] Virtualisation if the tree grows past a few hundred nodes; today every
      visible node is a live widget

`// TODO(release-gate):` markers are on the mock datasource.
