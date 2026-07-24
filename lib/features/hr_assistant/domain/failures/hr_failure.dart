/// Typed failure crossing into presentation — never a raw exception or stack
/// trace (AI_ENGINEERING_STANDARD §7 / PLAYBOOK §1).
///
/// TODO(release-gate): replace with the shared `core/error/failures.dart`
/// hierarchy once this feature moves into the main app.
sealed class HrFailure {
  final String message;

  const HrFailure(this.message);
}

class HrRetrievalFailure extends HrFailure {
  const HrRetrievalFailure([super.message = 'I could not reach the knowledge base. Your question was not sent.']);
}

class HrOfflineFailure extends HrFailure {
  const HrOfflineFailure([super.message = 'You are offline. Answers resume as soon as you reconnect.']);
}
