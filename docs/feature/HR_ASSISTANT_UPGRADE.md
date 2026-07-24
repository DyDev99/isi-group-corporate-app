# HR AI Assistant — full-architecture upgrade

Rebuild of `hr_ai_assistant_screen.dart` as a complete vertical slice, following
`AI_ENGINEERING_PLAYBOOK.md` §4 (feature checklist) and §13 (the `StockCount`
shape), with a mock datasource standing in for the future retrieval gateway.

## 1. What changed

| Before | After |
|---|---|
| Everything in `_HrChatScreenState` | `presentation → domain → data` triad |
| `List<Map<String, dynamic>>` messages | Immutable `ChatMessage` with `copyWith` |
| `setState` | `HrChatBloc` — every state transition is an event |
| Send did nothing | Streamed answer, sources, payloads, follow-ups |
| ~30 inline hex literals | `HrColors` / `HrRadius` / `HrMotion` / `HrShadows` |
| Static chips | Scope-filtered, staggered, tappable |
| Bottom bar `Positioned` over a `120px` pad | `Column` + `SafeArea`, keyboard-safe |
| No tests | Repository/intent tests included |

## 2. File map

```
lib/features/hr_assistant/
├── hr_assistant_scope.dart          ← drop-in entry point (no get_it needed)
├── hr_assistant_injection.dart      ← get_it registration for the main app
├── domain/
│   ├── entities/                    chat_message · knowledge_doc · leave_balance
│   │                                answer_event (sealed) · hr_category
│   ├── failures/hr_failure.dart     typed failures only
│   ├── repositories/                HrAssistantRepository
│   └── usecases/                    Ask · GetGreeting · GetSuggested · Search · GetLeaveBalance
├── data/
│   ├── datasources/hr_assistant_mock_datasource.dart   ← ALL demo data lives here
│   └── repositories/hr_assistant_repository_impl.dart
└── presentation/
    ├── bloc/                        hr_chat_bloc · _event · _state
    ├── theme/hr_tokens.dart
    ├── pages/hr_ai_assistant_screen.dart
    └── widgets/                     category_filter_bar · chat_bubble · chat_composer
                                     source_carousel · doc_viewer_sheet
                                     knowledge_center_sheet · leave_balance_card
                                     suggested_questions · typing_indicator
test/features/hr_assistant/hr_assistant_repository_impl_test.dart
```

Domain has zero Flutter/Drift/dio imports. Widgets read bloc state and call
usecases through it — no widget touches the datasource.

## 3. Wiring

`pubspec.yaml` needs only `flutter_bloc` (already in the main app):

```yaml
dependencies:
  flutter_bloc: ^8.1.6
```

Then:

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const HrAssistantScope()),
);
```

In the main app, call `registerHrAssistantFeature(sl)` from `core/di/` and
provide `sl<HrChatBloc>()` above `HrAiAssistantScreen` instead. If the demo app
has no `get_it`, delete `hr_assistant_injection.dart` — nothing references it.

## 4. Everything that now works

**Conversation** — type or tap a suggestion, the answer streams in word by word
behind a typing indicator, with a blinking caret while it writes. Stop mid-answer
with the stop button. Nine intents are wired (leave, expenses, travel, IT policy,
Wi-Fi/VPN, payroll/NSSF, benefits, handbook, public holidays) plus an honest
fallback that says it didn't find anything rather than inventing an answer.

**Filter** — the scope bar re-filters retrieval, the suggested questions and the
Knowledge Center at once; the header subtitle reflects the active scope.

**Swipe** — left on your own message deletes it; right on an answer re-asks it;
the scope bar, the source cards and the follow-up chips all swipe horizontally.

**Zoom** — two kinds. Pinch, double-tap, or use the ±/percentage control in the
document viewer (0.6× – 5×, pivoting on the viewport centre so the passage stays
under your eyes). And `A−/A+` in the app bar scales every message body 90–130%.

**Cards** — source cards with match score and version, an animated leave-balance
card with drawing progress bars, a grounding meter per answer, and the cited
passage highlighted in the document page.

**Detail** — long-press menu, copy to clipboard with toast, thumbs up/down,
regenerate, clear conversation, jump-to-latest pill, pulsing avatar while
composing, staggered chip entrance, offline/failure banner.

## 5. Mock data

All of it is in `hr_assistant_mock_datasource.dart`: nine documents with real
excerpt paragraphs (Cambodian Labour Law leave accrual, NSSF deductions,
per-diem rates, probation, holiday substitution), one leave balance, per-scope
suggestions, and the intent keyword table. Swap that one file for a
`HrAssistantRemoteDatasource` built on `core/network/` and nothing above the
datasource boundary changes.

## 6. Definition of Done — what is still open

Honest gaps against `AI_ENGINEERING_PLAYBOOK.md` §5, all deliberate for a demo:

- [ ] Widget/golden tests for the screen (light + dark, en + kh)
- [ ] Khmer localization — strings are hardcoded English; move to the app's
      localization layer before this ships to Cambodian users
- [ ] Dark theme values in `hr_tokens.dart`
- [ ] Offline posture documented in `OFFLINE_FIRST.md` §4 — today the assistant
      needs the gateway; decide whether recent answers are cached in Drift
- [ ] `AuthGuard` on the screen entry (`context.requireAuth`) once it leaves demo
- [ ] Real retrieval, with citation offsets from the document service rather
      than hand-authored `cited: true` paragraphs

`// TODO(release-gate):` markers are in place on the mock datasource and the
local failure hierarchy.
