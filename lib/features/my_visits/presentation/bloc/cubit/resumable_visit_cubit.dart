import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isi_group_corporate_app/features/my_visits/domain/entities/active_workflow.dart';
import 'package:isi_group_corporate_app/features/my_visits/domain/entities/route_plan.dart';

class ResumableVisitCubit extends Cubit<ResumableVisitState> {
  ResumableVisitCubit() : super(const ResumableVisitState());

  Future<void> refresh() async {}
  Future<void> dismiss() async {}
  Future<void> checkOut() async {}
}

class ResumableVisitState extends Equatable {
  final bool loaded;
  final RoutePlan? route;
  final ActiveWorkflow? workflow;
  final String? activeShopId;

  const ResumableVisitState({
    this.loaded = false,
    this.route,
    this.workflow,
    this.activeShopId,
  });

  @override
  List<Object?> get props => [loaded, route, workflow, activeShopId];
}
