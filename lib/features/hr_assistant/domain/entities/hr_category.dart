/// Scope filter applied to both the assistant's retrieval and the knowledge
/// library. Pure Dart — no Flutter imports (AI_ENGINEERING_PLAYBOOK §1).
enum HrCategory {
  all('All'),
  leave('Leave & Time'),
  payroll('Payroll'),
  it('IT Support'),
  policy('Policies'),
  benefits('Benefits');

  const HrCategory(this.label);

  final String label;

  bool matches(HrCategory other) => this == HrCategory.all || this == other;
}
