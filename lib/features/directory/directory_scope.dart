import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/datasources/directory_mock_datasource.dart';
import 'data/repositories/directory_repository_impl.dart';
import 'domain/repositories/directory_repository.dart';
import 'domain/usecases/directory_usecases.dart';
import 'presentation/bloc/directory_bloc.dart';
import 'presentation/pages/directory_screen.dart';

/// Drop-in entry point — no service locator required:
///
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(builder: (_) => const DirectoryScope()),
/// );
/// ```
///
/// In the main app use `registerDirectoryFeature(sl)` from
/// `directory_injection.dart` and provide `sl<DirectoryBloc>()` instead.
class DirectoryScope extends StatelessWidget {
  const DirectoryScope({super.key});

  @override
  Widget build(BuildContext context) {
    final DirectoryRepository repository =
        DirectoryRepositoryImpl(DirectoryMockDatasource());

    return BlocProvider<DirectoryBloc>(
      create: (_) => DirectoryBloc(
        getOrgTree: GetOrgTree(repository),
        getCompanies: GetCompanies(repository),
        getDepartments: GetDepartments(repository),
      )..add(const DirectoryStarted()),
      child: const DirectoryScreen(),
    );
  }
}
