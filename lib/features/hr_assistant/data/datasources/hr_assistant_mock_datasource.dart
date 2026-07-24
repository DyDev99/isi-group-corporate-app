import 'dart:math';

import '../../domain/entities/answer_event.dart';
import '../../domain/entities/hr_category.dart';
import '../../domain/entities/knowledge_doc.dart';
import '../../domain/entities/leave_balance.dart';

/// Demo-only stand-in for the future HR retrieval gateway.
///
/// Everything the UI needs lives here: the document corpus, the intent
/// matcher, the canned answers and the artificial latency that makes the
/// streaming UI look real. When the real API lands, only this file is
/// replaced — the repository, blocs and widgets above it do not change.
///
/// TODO(release-gate): swap for `HrAssistantRemoteDatasource` backed by
/// `core/network/` before this feature ships.
class HrAssistantMockDatasource {
  HrAssistantMockDatasource({Random? random}) : _random = random ?? Random(7);

  final Random _random;

  static const String employeeFirstName = 'Sarah';

  // ── Corpus ────────────────────────────────────────────────────────────────

  late final List<KnowledgeDoc> _corpus = [
    KnowledgeDoc(
      id: 'doc_leave',
      code: 'HR-POL-004',
      title: 'Annual Leave & Absence Policy',
      summary:
          'Entitlement, accrual, carry-over caps and the approval chain for every leave type.',
      owner: 'People Operations',
      version: 'v4.2',
      category: HrCategory.leave,
      updatedAt: DateTime(2026, 4, 18),
      pageCount: 12,
      citedPage: 3,
      excerpt: const [
        DocParagraph(
          heading: '3.1 Annual leave entitlement',
          body:
              'Permanent employees accrue 1.5 days of paid annual leave per completed month of service, giving 18 days per calendar year in line with the Cambodian Labour Law. Accrual starts on the confirmation date, not the offer date.',
          cited: true,
        ),
        DocParagraph(
          heading: '3.2 Carry-over',
          body:
              'A maximum of 5 unused days may be carried into the following year and must be consumed before 31 March. Days beyond the cap lapse and are not paid out except on termination.',
        ),
        DocParagraph(
          heading: '3.3 Notice and approval',
          body:
              'Leave of 3 days or fewer requires 48 hours notice. Leave of 4 days or more requires 10 working days notice and countersignature by the department head. Requests are raised in the Employee Portal, never by email.',
        ),
        DocParagraph(
          heading: '3.6 Sick leave',
          body:
              'Up to 7 days of paid sick leave per year are granted without a certificate. Any absence of 2 consecutive days or more requires a certificate from a licensed practitioner, uploaded within 3 working days of returning.',
        ),
      ],
    ),
    KnowledgeDoc(
      id: 'doc_travel',
      code: 'HR-POL-011',
      title: 'Business Travel & Per Diem',
      summary:
          'Booking rules, per diem rates by destination, and what travel time counts as working time.',
      owner: 'People Operations',
      version: 'v2.9',
      category: HrCategory.policy,
      updatedAt: DateTime(2026, 6, 2),
      pageCount: 9,
      citedPage: 2,
      excerpt: const [
        DocParagraph(
          heading: '2.1 Approval before booking',
          body:
              'All travel is approved in the portal before any booking is made. Tickets bought ahead of approval are reimbursed at the traveller\'s risk and may be declined.',
          cited: true,
        ),
        DocParagraph(
          heading: '2.4 Per diem rates',
          body:
              'Domestic travel outside Phnom Penh: USD 25 per day. Regional (ASEAN): USD 60 per day. Long haul: USD 95 per day. Per diem covers meals and incidentals only; accommodation and intercity transport are reimbursed on receipt.',
        ),
        DocParagraph(
          heading: '2.5 Class of travel',
          body:
              'Economy class for flights under 6 hours. Ground transport under 250 km is booked through the company fleet desk where a vehicle is available.',
        ),
        DocParagraph(
          heading: '2.8 Travel time',
          body:
              'Travel on a working day counts as working time. Travel on a rest day is compensated with time off in lieu, agreed with the line manager before departure.',
        ),
      ],
    ),
    KnowledgeDoc(
      id: 'doc_expense',
      code: 'FIN-SOP-002',
      title: 'Expense Claim Standard Operating Procedure',
      summary:
          'How to file a claim, the evidence required, and the payment run it lands in.',
      owner: 'Finance Shared Services',
      version: 'v3.1',
      category: HrCategory.payroll,
      updatedAt: DateTime(2026, 5, 21),
      pageCount: 7,
      citedPage: 1,
      excerpt: const [
        DocParagraph(
          heading: '1.2 Submission window',
          body:
              'Claims are submitted within 30 days of the expense date. Claims older than 60 days require a written exception from the Finance Manager.',
          cited: true,
        ),
        DocParagraph(
          heading: '1.4 Evidence',
          body:
              'Every line needs a legible receipt or tax invoice showing vendor, date and amount. Card slips alone are not accepted. Amounts above USD 100 additionally need the approved purpose recorded on the claim.',
        ),
        DocParagraph(
          heading: '2.1 Routing',
          body:
              'Claims route to the line manager, then to Finance for verification. Anything above USD 500 adds a Finance Manager step. Median end-to-end approval time in the last quarter was 2.4 working days.',
        ),
        DocParagraph(
          heading: '3.1 Payment',
          body:
              'Approved claims are paid in the next payroll run, on the 25th, provided approval completes by the 18th.',
        ),
      ],
    ),
    KnowledgeDoc(
      id: 'doc_it_use',
      code: 'IT-POL-001',
      title: 'IT Acceptable Use & Device Guidelines',
      summary:
          'What company devices may be used for, password standards, and reporting a lost device.',
      owner: 'ISIG IT Digital & Innovation',
      version: 'v5.0',
      category: HrCategory.it,
      updatedAt: DateTime(2026, 7, 8),
      pageCount: 15,
      citedPage: 4,
      excerpt: const [
        DocParagraph(
          heading: '4.1 Account security',
          body:
              'Passwords are at least 14 characters and unique to the company account. Multi-factor authentication is mandatory on email, the Employee Portal and any SAP or Business Central access. Passwords are never shared, including with IT staff.',
          cited: true,
        ),
        DocParagraph(
          heading: '4.3 Personal use',
          body:
              'Reasonable personal use of company devices is permitted where it does not affect performance, consume metered bandwidth, or introduce unlicensed software.',
        ),
        DocParagraph(
          heading: '5.2 Lost or stolen devices',
          body:
              'Report a lost device to the IT service desk within 4 hours. A remote wipe is issued for any device holding customer or pricing data, and the case is logged for the security review.',
        ),
        DocParagraph(
          heading: '6.1 Data handling',
          body:
              'Customer lists, price books and payroll extracts are never copied to personal cloud storage or messaging apps. Transfers use the approved company drive only.',
        ),
      ],
    ),
    KnowledgeDoc(
      id: 'doc_network',
      code: 'IT-SOP-007',
      title: 'Network, Wi-Fi & VPN Access',
      summary:
          'Joining the corporate Wi-Fi, requesting VPN, and what to do when access fails.',
      owner: 'ISIG IT Digital & Innovation',
      version: 'v2.4',
      category: HrCategory.it,
      updatedAt: DateTime(2026, 6, 27),
      pageCount: 6,
      citedPage: 2,
      excerpt: const [
        DocParagraph(
          heading: '2.1 Corporate Wi-Fi',
          body:
              'Company devices join ISI-CORP automatically using the device certificate. Personal phones use ISI-GUEST, which is internet-only and refreshes its passphrase monthly at the reception desk.',
          cited: true,
        ),
        DocParagraph(
          heading: '3.1 VPN eligibility',
          body:
              'VPN is granted to roles that need internal systems off-site: field sales, service engineers and on-call IT. The line manager raises the request; approval is typically same-day.',
        ),
        DocParagraph(
          heading: '4.2 When access fails',
          body:
              'Forget the network and rejoin before raising a ticket. If the device certificate has expired the join silently fails — the service desk reissues it in minutes.',
        ),
      ],
    ),
    KnowledgeDoc(
      id: 'doc_payroll',
      code: 'PAY-CAL-2026',
      title: 'Payroll Calendar & NSSF Contributions',
      summary:
          'Pay dates, cut-off dates, payslip access and the statutory deductions applied.',
      owner: 'Payroll',
      version: 'v1.6',
      category: HrCategory.payroll,
      updatedAt: DateTime(2026, 1, 9),
      pageCount: 4,
      citedPage: 1,
      excerpt: const [
        DocParagraph(
          heading: '1.1 Pay dates',
          body:
              'Salaries are paid on the 25th of each month, or the preceding working day when the 25th falls on a weekend or public holiday. The variable-pay cut-off is the 18th.',
          cited: true,
        ),
        DocParagraph(
          heading: '1.3 Payslips',
          body:
              'Payslips are published in the Employee Portal on the pay date and remain available for 24 months. They are not sent by email.',
        ),
        DocParagraph(
          heading: '2.1 Statutory deductions',
          body:
              'NSSF pension and occupational risk contributions are deducted at the prevailing statutory rate and shown as separate lines. Salary tax is withheld under the monthly progressive scale.',
        ),
      ],
    ),
    KnowledgeDoc(
      id: 'doc_benefits',
      code: 'BEN-POL-003',
      title: 'Medical & Insurance Benefits',
      summary:
          'Coverage levels, dependants, claim routes and the annual enrolment window.',
      owner: 'People Operations',
      version: 'v3.4',
      category: HrCategory.benefits,
      updatedAt: DateTime(2026, 3, 14),
      pageCount: 11,
      citedPage: 3,
      excerpt: const [
        DocParagraph(
          heading: '3.1 Coverage',
          body:
              'All confirmed employees receive outpatient and inpatient cover from the first day after probation. The annual outpatient limit is USD 800 per member; inpatient cover follows the group policy schedule.',
          cited: true,
        ),
        DocParagraph(
          heading: '3.4 Dependants',
          body:
              'A spouse and up to three children under 18 may be added within 30 days of joining, marriage or birth. Outside those windows, additions wait for the November enrolment window.',
        ),
        DocParagraph(
          heading: '4.2 Claiming',
          body:
              'Present the member card at a network clinic for direct billing. Outside the network, pay and claim within 60 days with the itemised invoice and diagnosis.',
        ),
      ],
    ),
    KnowledgeDoc(
      id: 'doc_handbook',
      code: 'HR-HB-2026',
      title: 'Employee Handbook 2026',
      summary:
          'Working hours, probation, code of conduct and the grievance route.',
      owner: 'People Operations',
      version: 'v2026.1',
      category: HrCategory.policy,
      updatedAt: DateTime(2026, 2, 3),
      pageCount: 46,
      citedPage: 8,
      excerpt: const [
        DocParagraph(
          heading: '8.1 Working hours',
          body:
              'Standard hours are 08:00 to 17:00, Monday to Friday, with a one-hour break. Field roles follow the route plan agreed with their supervisor and record attendance in the mobile app.',
          cited: true,
        ),
        DocParagraph(
          heading: '8.4 Probation',
          body:
              'Probation is three months, extendable once by one month with written notice. Confirmation follows a documented review with the line manager.',
        ),
        DocParagraph(
          heading: '12.2 Raising a concern',
          body:
              'Concerns go first to the line manager. Where that is not appropriate, contact People Operations directly; every report is handled confidentially and acknowledged within 2 working days.',
        ),
      ],
    ),
    KnowledgeDoc(
      id: 'doc_holidays',
      code: 'HR-CAL-2026',
      title: 'Cambodia Public Holiday Calendar 2026',
      summary:
          'The observed public holidays, and how a holiday falling on a weekend is handled.',
      owner: 'People Operations',
      version: 'v1.2',
      category: HrCategory.leave,
      updatedAt: DateTime(2026, 1, 6),
      pageCount: 2,
      citedPage: 1,
      excerpt: const [
        DocParagraph(
          heading: '1.1 Observed holidays',
          body:
              'The company observes the public holidays gazetted for the calendar year, including Khmer New Year, Pchum Ben, Water Festival, International Labour Day and Constitution Day.',
          cited: true,
        ),
        DocParagraph(
          heading: '1.3 Weekend overlap',
          body:
              'Where a gazetted holiday falls on a Saturday or Sunday, the substitute day announced by the authorities is observed. No substitute is granted where none is gazetted.',
        ),
      ],
    ),
  ];

  List<KnowledgeDoc> get corpus => List.unmodifiable(_corpus);

  KnowledgeDoc _doc(String id) => _corpus.firstWhere((d) => d.id == id);

  // ── Leave balance ─────────────────────────────────────────────────────────

  LeaveBalance get _leaveBalance => LeaveBalance(
        employeeName: employeeFirstName,
        employeeCode: 'ISI-04412',
        asOf: DateTime(2026, 7, 24),
        buckets: const [
          LeaveBucket(code: 'AL', label: 'Annual leave', entitled: 18, used: 7, pending: 2),
          LeaveBucket(code: 'SL', label: 'Sick leave', entitled: 7, used: 1),
          LeaveBucket(code: 'SPL', label: 'Special leave', entitled: 7, used: 0),
        ],
      );

  // ── Intents ───────────────────────────────────────────────────────────────

  static const _fallbackAnswer =
      'I could not find that in the published policies, so I would rather not guess. '
      'Two things that usually help: narrow the scope with the filter above the chat, '
      'or open the Knowledge Center and browse the owning document directly. '
      'If it is genuinely undocumented, People Operations answers within 2 working days.';

  List<_Intent> get _intents => [
        _Intent(
          keywords: ['leave balance', 'leave', 'balance', 'day off', 'annual', 'holiday left', 'vacation'],
          answer:
              'You have 9 days of annual leave left for 2026 — 18 accrued, 7 taken and 2 sitting in an unapproved request. '
              'Sick leave is at 6 of 7 days.\n\n'
              'Two things worth knowing before you plan: anything of 4 days or more needs 10 working days notice and your department head\'s countersignature, '
              'and only 5 unused days carry into 2027, expiring on 31 March.',
          sourceIds: ['doc_leave', 'doc_holidays'],
          withLeaveBalance: true,
          confidence: 0.96,
          followUps: [
            'Request 3 days in August',
            'When does carry-over expire?',
            'Who approves my leave?',
          ],
        ),
        _Intent(
          keywords: ['expense', 'claim', 'reimburse', 'receipt', 'refund'],
          answer:
              'File it in the Employee Portal under Finance › Expense Claim. Each line needs a legible receipt showing vendor, date and amount — a card slip on its own will be rejected.\n\n'
              'The clock matters more than the paperwork: claims go in within 30 days of the expense date, and anything past 60 days needs a written exception from the Finance Manager. '
              'Routing is manager → Finance, plus a Finance Manager step above USD 500. Approve by the 18th and it pays out on the 25th.',
          sourceIds: ['doc_expense', 'doc_payroll'],
          confidence: 0.94,
          followUps: [
            'What if I lost the receipt?',
            'Track my pending claims',
            'Per diem rates for Sihanoukville',
          ],
        ),
        _Intent(
          keywords: ['it guideline', 'it policy', 'acceptable use', 'device', 'password', 'security', 'laptop'],
          answer:
              'The short version of IT-POL-001: passwords are 14+ characters, unique to your company account, and never shared — including with IT. '
              'MFA is mandatory on email, the portal and any SAP or Business Central access.\n\n'
              'Personal use of your device is fine as long as it does not slow your work or bring in unlicensed software. '
              'Customer lists, price books and payroll extracts stay off personal cloud storage and messaging apps. '
              'If a device goes missing, tell the service desk within 4 hours so a remote wipe can be issued.',
          sourceIds: ['doc_it_use', 'doc_network'],
          confidence: 0.93,
          followUps: [
            'How do I reset my password?',
            'Report a lost laptop',
            'Can I install my own software?',
          ],
        ),
        _Intent(
          keywords: ['travel', 'per diem', 'trip', 'flight', 'business travel'],
          answer:
              'Travel is approved in the portal before anything is booked — tickets bought ahead of approval are at your own risk.\n\n'
              'Per diem covers meals and incidentals only: USD 25 a day for domestic travel outside Phnom Penh, USD 60 regionally, USD 95 long haul. '
              'Hotels and intercity transport are reimbursed on receipt instead. Flights under 6 hours are economy, and ground trips under 250 km go through the fleet desk when a vehicle is free.\n\n'
              'Travelling on a working day counts as working time; travelling on a rest day earns time off in lieu, agreed with your manager before you leave.',
          sourceIds: ['doc_travel', 'doc_expense'],
          confidence: 0.95,
          followUps: [
            'Per diem for a Bangkok trip',
            'Book travel for next week',
            'Is travel time paid?',
          ],
        ),
        _Intent(
          keywords: ['payslip', 'salary', 'payroll', 'pay date', 'nssf', 'tax', 'paid'],
          answer:
              'Payday is the 25th, moving to the preceding working day when the 25th lands on a weekend or public holiday. The variable-pay cut-off is the 18th.\n\n'
              'Payslips appear in the Employee Portal on the pay date and stay there for 24 months — payroll does not email them. '
              'NSSF pension and occupational risk contributions show as separate deduction lines, and salary tax is withheld on the monthly progressive scale.',
          sourceIds: ['doc_payroll'],
          confidence: 0.92,
          followUps: [
            'Open my June payslip',
            'Explain my NSSF deduction',
            'Update my bank account',
          ],
        ),
        _Intent(
          keywords: ['wifi', 'wi-fi', 'vpn', 'network', 'internet', 'connect'],
          answer:
              'Company devices join ISI-CORP on their own using the device certificate. Personal phones use ISI-GUEST, which is internet-only and gets a fresh passphrase from reception each month.\n\n'
              'VPN is granted by role — field sales, service engineers and on-call IT — and your line manager raises the request, usually approved the same day.\n\n'
              'If ISI-CORP will not connect, forget the network and rejoin before opening a ticket. An expired device certificate fails silently, and the service desk reissues it in minutes.',
          sourceIds: ['doc_network', 'doc_it_use'],
          confidence: 0.91,
          followUps: [
            'Request VPN access',
            'Guest Wi-Fi password',
            'Open an IT ticket',
          ],
        ),
        _Intent(
          keywords: ['insurance', 'medical', 'benefit', 'health', 'clinic', 'dependant', 'dependent'],
          answer:
              'Outpatient and inpatient cover starts the day after probation ends. The outpatient limit is USD 800 per member per year; inpatient follows the group policy schedule.\n\n'
              'A spouse and up to three children under 18 can be added within 30 days of joining, marriage or birth — miss that window and the next chance is the November enrolment.\n\n'
              'At a network clinic, show the member card and it is billed directly. Outside the network, pay and claim within 60 days with the itemised invoice and diagnosis.',
          sourceIds: ['doc_benefits'],
          confidence: 0.9,
          followUps: [
            'Add my spouse to the plan',
            'Which clinics are in network?',
            'What is not covered?',
          ],
        ),
        _Intent(
          keywords: ['working hours', 'probation', 'contract', 'handbook', 'conduct', 'grievance', 'complaint'],
          answer:
              'Standard hours are 08:00 to 17:00, Monday to Friday, with an hour\'s break; field roles follow the agreed route plan and record attendance in the mobile app.\n\n'
              'Probation runs three months and can be extended once by a month with written notice, ending in a documented review with your line manager.\n\n'
              'If something needs raising, start with your line manager. Where that is not appropriate, People Operations takes it directly — confidentially, acknowledged within 2 working days.',
          sourceIds: ['doc_handbook'],
          confidence: 0.89,
          followUps: [
            'When is my confirmation review?',
            'Overtime rules',
            'Raise a concern confidentially',
          ],
        ),
        _Intent(
          keywords: ['public holiday', 'khmer new year', 'pchum ben', 'water festival', 'calendar'],
          answer:
              'The company observes the gazetted public holidays for the year — Khmer New Year, Pchum Ben, Water Festival, International Labour Day and Constitution Day among them.\n\n'
              'When a holiday falls on a Saturday or Sunday, we follow whatever substitute day the authorities gazette. If none is gazetted, no substitute day is granted.',
          sourceIds: ['doc_holidays', 'doc_leave'],
          confidence: 0.88,
          followUps: [
            'Next public holiday',
            'Do I get a day back?',
            'Plan leave around Pchum Ben',
          ],
        ),
      ];

  // ── API ───────────────────────────────────────────────────────────────────

  String greeting() =>
      'Hi $employeeFirstName. I answer from the published ISI policies, SOPs and the 2026 handbook — '
      'and I show you the exact passage behind every answer so you can check me.\n\n'
      'Ask in English or Khmer, or start with one of these:';

  List<String> suggestedQuestions(HrCategory category) {
    const byCategory = <HrCategory, List<String>>{
      HrCategory.all: [
        'What is my leave balance?',
        'How do I submit an expense claim?',
        'Summarize the travel policy',
        'Show me the IT guidelines',
      ],
      HrCategory.leave: [
        'What is my leave balance?',
        'How much notice for 5 days off?',
        'When does carry-over expire?',
        'Next public holiday',
      ],
      HrCategory.payroll: [
        'When is payday this month?',
        'How do I submit an expense claim?',
        'Explain my NSSF deduction',
        'Where do I find my payslip?',
      ],
      HrCategory.it: [
        'Show me the IT guidelines',
        'How do I get VPN access?',
        'Guest Wi-Fi password',
        'I lost my laptop, what now?',
      ],
      HrCategory.policy: [
        'Summarize the travel policy',
        'What are the standard working hours?',
        'How long is probation?',
        'How do I raise a concern?',
      ],
      HrCategory.benefits: [
        'What does my medical cover include?',
        'Add my spouse to the plan',
        'Which clinics are in network?',
        'When is the enrolment window?',
      ],
    };
    return List.unmodifiable(byCategory[category] ?? const []);
  }

  List<KnowledgeDoc> searchDocs({String query = '', HrCategory category = HrCategory.all}) {
    final normalized = query.trim().toLowerCase();
    return _corpus
        .where((doc) => category.matches(doc.category))
        .where((doc) =>
            normalized.isEmpty ||
            doc.title.toLowerCase().contains(normalized) ||
            doc.code.toLowerCase().contains(normalized) ||
            doc.summary.toLowerCase().contains(normalized) ||
            doc.owner.toLowerCase().contains(normalized))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  LeaveBalance leaveBalance() => _leaveBalance;

  /// Streams a canned answer word by word so the UI can exercise its real
  /// streaming path.
  Stream<AnswerEvent> ask({
    required String question,
    required HrCategory scope,
  }) async* {
    yield const AnswerRetrieving();
    await Future<void>.delayed(Duration(milliseconds: 420 + _random.nextInt(380)));

    final intent = _matchIntent(question, scope);
    final answer = intent?.answer ?? _fallbackAnswer;

    final words = answer.split(' ');
    final buffer = StringBuffer();
    for (var i = 0; i < words.length; i++) {
      buffer.write(i == 0 ? words[i] : ' ${words[i]}');
      yield AnswerTextChunk(buffer.toString());
      final pause = words[i].endsWith('.') || words[i].endsWith('\n\n') ? 90 : 18 + _random.nextInt(22);
      await Future<void>.delayed(Duration(milliseconds: pause));
    }

    await Future<void>.delayed(const Duration(milliseconds: 160));

    if (intent == null) {
      yield AnswerCompleted(
        confidence: 0.34,
        followUps: const [
          'Browse the Knowledge Center',
          'Ask People Operations',
        ],
        sources: searchDocs(category: scope).take(2).toList(),
      );
      return;
    }

    yield AnswerCompleted(
      confidence: intent.confidence,
      followUps: intent.followUps,
      leaveBalance: intent.withLeaveBalance ? _leaveBalance : null,
      sources: [
        for (var i = 0; i < intent.sourceIds.length; i++)
          _doc(intent.sourceIds[i]).copyWith(relevance: 0.97 - (i * 0.19)),
      ],
    );
  }

  _Intent? _matchIntent(String question, HrCategory scope) {
    final normalized = question.toLowerCase();
    _Intent? best;
    var bestScore = 0;

    for (final intent in _intents) {
      var score = 0;
      for (final keyword in intent.keywords) {
        if (normalized.contains(keyword)) {
          score += keyword.split(' ').length * 2;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = intent;
      }
    }
    return bestScore == 0 ? null : best;
  }
}

class _Intent {
  final List<String> keywords;
  final String answer;
  final List<String> sourceIds;
  final List<String> followUps;
  final double confidence;
  final bool withLeaveBalance;

  const _Intent({
    required this.keywords,
    required this.answer,
    this.sourceIds = const [],
    this.followUps = const [],
    this.confidence = 0.9,
    this.withLeaveBalance = false,
  });
}
