import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isi_group_corporate_app/features/order/domain/entities/sync_queue_item.dart';
import 'package:isi_group_corporate_app/features/order/presentation/bloc/sync/pending_sync_state.dart';

class PendingSyncCubit extends Cubit<PendingSyncState> {
  PendingSyncCubit() : super(const PendingSyncState());

  void enqueue(String quotationId) {}
  void syncNow() {}
  void discard(String quotationId) {}
  void retry(String quotationId) {}
}
