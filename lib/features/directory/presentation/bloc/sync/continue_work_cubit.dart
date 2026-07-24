import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isi_group_corporate_app/features/directory/domain/entities/quotation.dart';

class ContinueWorkCubit extends Cubit<ContinueWorkState> {
  ContinueWorkCubit() : super(const ContinueWorkState());

  Future<void> dismiss(String quotationId) async {}
}

class ContinueWorkState extends Equatable {
  final bool loaded;
  final List<Quotation> drafts;

  const ContinueWorkState({
    this.loaded = false,
    this.drafts = const [],
  });

  @override
  List<Object?> get props => [loaded, drafts];
}
