import 'package:equatable/equatable.dart';
import 'package:isi_group_corporate_app/features/order/domain/entities/sync_queue_item.dart';

class PendingSyncState extends Equatable {
  final bool isSyncing;
  final SyncCounts counts;
  final List<SyncQueueItem> items;

  const PendingSyncState({
    this.isSyncing = false,
    this.counts = const SyncCounts(),
    this.items = const [],
  });

  @override
  List<Object?> get props => [isSyncing, counts, items];
}

class SyncCounts extends Equatable {
  final int outstanding;
  final int pending;
  final int failed;
  final int conflict;

  const SyncCounts({
    this.outstanding = 0,
    this.pending = 0,
    this.failed = 0,
    this.conflict = 0,
  });

  @override
  List<Object?> get props => [outstanding, pending, failed, conflict];
}
