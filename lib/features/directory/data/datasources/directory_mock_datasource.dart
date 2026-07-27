import '../../domain/entities/employee.dart';
import '../../domain/entities/org_tree.dart';

/// Demo-only stand-in for the HR/organisation service.
///
/// Everything the directory renders comes from here: a 30-person, five-level
/// ISI Group reporting tree, four companies and nine departments. Swap this one
/// class for a remote datasource on `core/network/` and nothing above the
/// datasource boundary changes.
///
/// TODO(release-gate): replace with `DirectoryRemoteDatasource` + Drift cache
/// before this feature ships (ARCHITECTURE.md §4 dependency rule).
class DirectoryMockDatasource {
  static const List<Company> _companies = [
    Company(
      id: 'c_corp',
      name: 'Corporate Office',
      tagline: 'Shared services',
      emoji: '🏛',
    ),
    Company(
      id: 'c_steel',
      name: 'ISI Steel',
      tagline: 'Manufacturing & distribution',
      emoji: '🏢',
    ),
    Company(
      id: 'c_enc',
      name: 'ISI E&C',
      tagline: 'Engineering & construction',
      emoji: '🏗',
    ),
    Company(
      id: 'c_log',
      name: 'ISI Logistics',
      tagline: 'Transport & fleet',
      emoji: '🚚',
    ),
  ];

  static const List<Department> _departments = [
    Department(id: 'd_exec', name: 'Executive', emoji: '🧭', accent: 0),
    Department(id: 'd_it', name: 'IT Innovation', emoji: '💻', accent: 1),
    Department(id: 'd_fin', name: 'Finance', emoji: '💰', accent: 2),
    Department(id: 'd_hr', name: 'Human Resources', emoji: '👥', accent: 3),
    Department(id: 'd_mkt', name: 'Marketing', emoji: '📢', accent: 4),
    Department(id: 'd_ops', name: 'Operations', emoji: '📦', accent: 5),
    Department(id: 'd_sales', name: 'Sales', emoji: '🤝', accent: 1),
    Department(id: 'd_fac', name: 'Factory', emoji: '🏭', accent: 2),
    Department(id: 'd_eng', name: 'Engineering', emoji: '📐', accent: 3),
  ];

  /// Demo avatar URLs (all direct .jpg). The first two are the images you
  /// supplied; the rest keep 30 faces distinct. Loads over the network —
  /// needs connectivity, and behind a TLS-inspecting proxy needs the debug
  /// override in main.dart. Missing/failed URLs fall back to initials.
  ///
  /// TODO(release-gate): replace with real HR headshots served over trusted
  /// TLS, or bundle as assets for the offline-first path (ARCHITECTURE §1).
  static const Map<String, String> _avatarUrls = {
    'e_david': 'https://i.pinimg.com/736x/ea/2b/c3/ea2bc318ed2aa011fa477315b1076708.jpg',
    'e_sarah': 'https://i.pinimg.com/736x/0c/ad/ed/0cadeda5420722297c4416036c039f8b.jpg',
    'e_james': 'https://i.pinimg.com/736x/87/ee/38/87ee38cdb2064b82e7f7261054983eb8.jpg',
    'e_alex': 'https://i.pinimg.com/736x/6c/31/52/6c31529e8fcaf78c888fd49320f30ddb.jpg',
    'e_pheakdey': 'https://i.pinimg.com/736x/ac/2e/39/ac2e39b620f5bff70f88f7a30cd4ebb3.jpg',
    'e_daniel': 'https://i.pinimg.com/736x/96/25/6f/96256ff7e6a5d2adb06b60c9188ddea4.jpg',
    'e_michael': 'https://randomuser.me/api/portraits/men/75.jpg',
    'e_sopheak': 'https://randomuser.me/api/portraits/women/12.jpg',
    'e_vannak': 'https://randomuser.me/api/portraits/men/51.jpg',
    'e_rithy': 'https://randomuser.me/api/portraits/women/29.jpg',
    'e_dara': 'https://randomuser.me/api/portraits/men/64.jpg',
    'e_chenda': 'https://randomuser.me/api/portraits/women/90.jpg',
    'e_emma': 'https://randomuser.me/api/portraits/men/11.jpg',
    'e_sreymom': 'https://randomuser.me/api/portraits/women/55.jpg',
    'e_piseth': 'https://randomuser.me/api/portraits/men/85.jpg',
    'e_linda': 'https://randomuser.me/api/portraits/women/33.jpg',
    'e_chamroeun': 'https://randomuser.me/api/portraits/men/22.jpg',
    'e_kimly': 'https://randomuser.me/api/portraits/women/71.jpg',
    'e_ratana': 'https://randomuser.me/api/portraits/men/40.jpg',
    'e_bopha': 'https://randomuser.me/api/portraits/women/18.jpg',
    'e_sovann': 'https://randomuser.me/api/portraits/men/3.jpg',
    'e_nary': 'https://randomuser.me/api/portraits/women/82.jpg',
    'e_visal': 'https://randomuser.me/api/portraits/men/57.jpg',
    'e_samoeun': 'https://randomuser.me/api/portraits/men/78.jpg',
    'e_vuthy': 'https://randomuser.me/api/portraits/men/92.jpg',
    'e_sophea': 'https://randomuser.me/api/portraits/women/47.jpg',
    'e_kosal': 'https://randomuser.me/api/portraits/men/6.jpg',
    'e_chantha': 'https://randomuser.me/api/portraits/men/36.jpg',
    'e_sereypich': 'https://randomuser.me/api/portraits/men/69.jpg',
    'e_makara': 'https://randomuser.me/api/portraits/men/15.jpg',
  };

  List<Company> companies() => List.unmodifiable(_companies);

  List<Department> departments() => List.unmodifiable(_departments);

  static Employee _person({
    required String id,
    required String name,
    required String role,
    required String companyId,
    required String departmentId,
    required String location,
    required PresenceStatus status,
    required int joinedYear,
    required int joinedMonth,
    String? managerId,
  }) {
    final handle = name.toLowerCase().replaceAll(' ', '.');
    final digits = id.hashCode.abs() % 900 + 100;
    return Employee(
      id: id,
      name: name,
      role: role,
      imageUrl: _avatarUrls[id],
      companyId: companyId,
      departmentId: departmentId,
      location: location,
      email: '$handle@isigroup.com.kh',
      phone: '+855 12 $digits ${(digits * 3) % 900 + 100}',
      status: status,
      joinedAt: DateTime(joinedYear, joinedMonth, 1),
      managerId: managerId,
    );
  }

  OrgTree orgTree() {
    // ── IT branch ───────────────────────────────────────────────────────────
    final rithy = OrgNode(
      employee: _person(
        id: 'e_rithy',
        name: 'Rithy Meas',
        role: 'Senior Flutter Engineer',
        companyId: 'c_corp',
        departmentId: 'd_it',
        location: 'Phnom Penh',
        status: PresenceStatus.online,
        joinedYear: 2023,
        joinedMonth: 4,
        managerId: 'e_sopheak',
      ),
    );
    final dara = OrgNode(
      employee: _person(
        id: 'e_dara',
        name: 'Dara Pich',
        role: 'SAP Basis Administrator',
        companyId: 'c_corp',
        departmentId: 'd_it',
        location: 'Phnom Penh',
        status: PresenceStatus.away,
        joinedYear: 2021,
        joinedMonth: 9,
        managerId: 'e_sopheak',
      ),
    );
    final sopheak = OrgNode(
      employee: _person(
        id: 'e_sopheak',
        name: 'Sopheak Chan',
        role: 'Head of Digital & Innovation',
        companyId: 'c_corp',
        departmentId: 'd_it',
        location: 'Phnom Penh',
        status: PresenceStatus.online,
        joinedYear: 2020,
        joinedMonth: 2,
        managerId: 'e_michael',
      ),
      children: [rithy, dara],
    );
    final chenda = OrgNode(
      employee: _person(
        id: 'e_chenda',
        name: 'Chenda Lim',
        role: 'Network Engineer',
        companyId: 'c_corp',
        departmentId: 'd_it',
        location: 'Phnom Penh',
        status: PresenceStatus.offline,
        joinedYear: 2022,
        joinedMonth: 11,
        managerId: 'e_vannak',
      ),
    );
    final vannak = OrgNode(
      employee: _person(
        id: 'e_vannak',
        name: 'Vannak Sim',
        role: 'IT Infrastructure Manager',
        companyId: 'c_corp',
        departmentId: 'd_it',
        location: 'Phnom Penh',
        status: PresenceStatus.online,
        joinedYear: 2019,
        joinedMonth: 6,
        managerId: 'e_michael',
      ),
      children: [chenda],
    );
    final michael = OrgNode(
      employee: _person(
        id: 'e_michael',
        name: 'Michael Chen',
        role: 'IT Director',
        companyId: 'c_corp',
        departmentId: 'd_it',
        location: 'Phnom Penh',
        status: PresenceStatus.online,
        joinedYear: 2018,
        joinedMonth: 3,
        managerId: 'e_sarah',
      ),
      children: [sopheak, vannak],
    );

    // ── HR branch ───────────────────────────────────────────────────────────
    final emma = OrgNode(
      employee: _person(
        id: 'e_emma',
        name: 'Emma Watson',
        role: 'HR Director',
        companyId: 'c_corp',
        departmentId: 'd_hr',
        location: 'Phnom Penh',
        status: PresenceStatus.offline,
        joinedYear: 2017,
        joinedMonth: 8,
        managerId: 'e_sarah',
      ),
      children: [
        OrgNode(
          employee: _person(
            id: 'e_sreymom',
            name: 'Sreymom Kang',
            role: 'HR Business Partner',
            companyId: 'c_corp',
            departmentId: 'd_hr',
            location: 'Phnom Penh',
            status: PresenceStatus.online,
            joinedYear: 2022,
            joinedMonth: 1,
            managerId: 'e_emma',
          ),
        ),
        OrgNode(
          employee: _person(
            id: 'e_piseth',
            name: 'Piseth Nou',
            role: 'Payroll Specialist',
            companyId: 'c_corp',
            departmentId: 'd_hr',
            location: 'Phnom Penh',
            status: PresenceStatus.away,
            joinedYear: 2021,
            joinedMonth: 5,
            managerId: 'e_emma',
          ),
        ),
      ],
    );

    // ── Logistics branch ────────────────────────────────────────────────────
    final linda = OrgNode(
      employee: _person(
        id: 'e_linda',
        name: 'Linda Thorne',
        role: 'Head of Operations',
        companyId: 'c_log',
        departmentId: 'd_ops',
        location: 'Phnom Penh',
        status: PresenceStatus.online,
        joinedYear: 2019,
        joinedMonth: 10,
        managerId: 'e_sarah',
      ),
      children: [
        OrgNode(
          employee: _person(
            id: 'e_chamroeun',
            name: 'Sok Chamroeun',
            role: 'Warehouse Manager',
            companyId: 'c_log',
            departmentId: 'd_ops',
            location: 'Sihanoukville',
            status: PresenceStatus.online,
            joinedYear: 2020,
            joinedMonth: 7,
            managerId: 'e_linda',
          ),
        ),
        OrgNode(
          employee: _person(
            id: 'e_kimly',
            name: 'Kimly Ouk',
            role: 'Fleet Supervisor',
            companyId: 'c_log',
            departmentId: 'd_ops',
            location: 'Battambang',
            status: PresenceStatus.away,
            joinedYear: 2023,
            joinedMonth: 2,
            managerId: 'e_linda',
          ),
        ),
      ],
    );

    final sarah = OrgNode(
      employee: _person(
        id: 'e_sarah',
        name: 'Sarah Jenkins',
        role: 'Chief Operating Officer',
        companyId: 'c_corp',
        departmentId: 'd_exec',
        location: 'Phnom Penh',
        status: PresenceStatus.online,
        joinedYear: 2016,
        joinedMonth: 4,
        managerId: 'e_david',
      ),
      children: [michael, emma, linda],
    );

    // ── Finance branch ──────────────────────────────────────────────────────
    final james = OrgNode(
      employee: _person(
        id: 'e_james',
        name: 'James Wilson',
        role: 'Chief Financial Officer',
        companyId: 'c_corp',
        departmentId: 'd_fin',
        location: 'Phnom Penh',
        status: PresenceStatus.away,
        joinedYear: 2016,
        joinedMonth: 9,
        managerId: 'e_david',
      ),
      children: [
        OrgNode(
          employee: _person(
            id: 'e_ratana',
            name: 'Ratana Yim',
            role: 'Financial Controller',
            companyId: 'c_corp',
            departmentId: 'd_fin',
            location: 'Phnom Penh',
            status: PresenceStatus.online,
            joinedYear: 2019,
            joinedMonth: 3,
            managerId: 'e_james',
          ),
          children: [
            OrgNode(
              employee: _person(
                id: 'e_bopha',
                name: 'Bopha Chea',
                role: 'Senior Accountant',
                companyId: 'c_corp',
                departmentId: 'd_fin',
                location: 'Phnom Penh',
                status: PresenceStatus.online,
                joinedYear: 2022,
                joinedMonth: 6,
                managerId: 'e_ratana',
              ),
            ),
          ],
        ),
        OrgNode(
          employee: _person(
            id: 'e_sovann',
            name: 'Sovann Keo',
            role: 'Procurement Manager',
            companyId: 'c_corp',
            departmentId: 'd_fin',
            location: 'Phnom Penh',
            status: PresenceStatus.offline,
            joinedYear: 2020,
            joinedMonth: 11,
            managerId: 'e_james',
          ),
        ),
      ],
    );

    // ── Marketing branch ────────────────────────────────────────────────────
    final alex = OrgNode(
      employee: _person(
        id: 'e_alex',
        name: 'Alex Rivera',
        role: 'Marketing Director',
        companyId: 'c_corp',
        departmentId: 'd_mkt',
        location: 'Phnom Penh',
        status: PresenceStatus.online,
        joinedYear: 2018,
        joinedMonth: 1,
        managerId: 'e_david',
      ),
      children: [
        OrgNode(
          employee: _person(
            id: 'e_nary',
            name: 'Nary Sok',
            role: 'Brand Manager',
            companyId: 'c_corp',
            departmentId: 'd_mkt',
            location: 'Phnom Penh',
            status: PresenceStatus.online,
            joinedYear: 2021,
            joinedMonth: 8,
            managerId: 'e_alex',
          ),
        ),
        OrgNode(
          employee: _person(
            id: 'e_visal',
            name: 'Visal Ken',
            role: 'Digital Marketing Lead',
            companyId: 'c_corp',
            departmentId: 'd_mkt',
            location: 'Phnom Penh',
            status: PresenceStatus.away,
            joinedYear: 2023,
            joinedMonth: 5,
            managerId: 'e_alex',
          ),
        ),
      ],
    );

    // ── ISI Steel branch ────────────────────────────────────────────────────
    final pheakdey = OrgNode(
      employee: _person(
        id: 'e_pheakdey',
        name: 'Chan Pheakdey',
        role: 'Managing Director, ISI Steel',
        companyId: 'c_steel',
        departmentId: 'd_exec',
        location: 'Phnom Penh',
        status: PresenceStatus.online,
        joinedYear: 2015,
        joinedMonth: 2,
        managerId: 'e_david',
      ),
      children: [
        OrgNode(
          employee: _person(
            id: 'e_samoeun',
            name: 'Sam Oeun',
            role: 'National Sales Manager',
            companyId: 'c_steel',
            departmentId: 'd_sales',
            location: 'Phnom Penh',
            status: PresenceStatus.online,
            joinedYear: 2018,
            joinedMonth: 7,
            managerId: 'e_pheakdey',
          ),
          children: [
            OrgNode(
              employee: _person(
                id: 'e_vuthy',
                name: 'Vuthy Chhorn',
                role: 'Area Sales Representative',
                companyId: 'c_steel',
                departmentId: 'd_sales',
                location: 'Siem Reap',
                status: PresenceStatus.online,
                joinedYear: 2022,
                joinedMonth: 3,
                managerId: 'e_samoeun',
              ),
            ),
            OrgNode(
              employee: _person(
                id: 'e_sophea',
                name: 'Sophea Ngin',
                role: 'Area Sales Representative',
                companyId: 'c_steel',
                departmentId: 'd_sales',
                location: 'Battambang',
                status: PresenceStatus.offline,
                joinedYear: 2024,
                joinedMonth: 1,
                managerId: 'e_samoeun',
              ),
            ),
          ],
        ),
        OrgNode(
          employee: _person(
            id: 'e_kosal',
            name: 'Kosal Rin',
            role: 'Factory Manager',
            companyId: 'c_steel',
            departmentId: 'd_fac',
            location: 'Sihanoukville',
            status: PresenceStatus.away,
            joinedYear: 2017,
            joinedMonth: 4,
            managerId: 'e_pheakdey',
          ),
          children: [
            OrgNode(
              employee: _person(
                id: 'e_chantha',
                name: 'Chantha Mao',
                role: 'Production Supervisor',
                companyId: 'c_steel',
                departmentId: 'd_fac',
                location: 'Sihanoukville',
                status: PresenceStatus.online,
                joinedYear: 2021,
                joinedMonth: 10,
                managerId: 'e_kosal',
              ),
            ),
          ],
        ),
      ],
    );

    // ── ISI E&C branch ──────────────────────────────────────────────────────
    final daniel = OrgNode(
      employee: _person(
        id: 'e_daniel',
        name: 'Daniel Roth',
        role: 'Managing Director, ISI E&C',
        companyId: 'c_enc',
        departmentId: 'd_exec',
        location: 'Phnom Penh',
        status: PresenceStatus.offline,
        joinedYear: 2017,
        joinedMonth: 1,
        managerId: 'e_david',
      ),
      children: [
        OrgNode(
          employee: _person(
            id: 'e_sereypich',
            name: 'Sereypich Hor',
            role: 'Project Engineering Lead',
            companyId: 'c_enc',
            departmentId: 'd_eng',
            location: 'Phnom Penh',
            status: PresenceStatus.online,
            joinedYear: 2020,
            joinedMonth: 5,
            managerId: 'e_daniel',
          ),
          children: [
            OrgNode(
              employee: _person(
                id: 'e_makara',
                name: 'Makara Uch',
                role: 'Site Engineer',
                companyId: 'c_enc',
                departmentId: 'd_eng',
                location: 'Kampot',
                status: PresenceStatus.online,
                joinedYear: 2023,
                joinedMonth: 9,
                managerId: 'e_sereypich',
              ),
            ),
          ],
        ),
      ],
    );

    return OrgTree(
      OrgNode(
        employee: _person(
          id: 'e_david',
          name: 'David Smith',
          role: 'Chief Executive Officer',
          companyId: 'c_corp',
          departmentId: 'd_exec',
          location: 'Phnom Penh',
          status: PresenceStatus.online,
          joinedYear: 2014,
          joinedMonth: 1,
        ),
        children: [sarah, james, alex, pheakdey, daniel],
      ),
    );
  }
}