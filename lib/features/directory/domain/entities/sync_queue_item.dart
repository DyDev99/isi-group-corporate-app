import 'package:isi_group_corporate_app/features/directory/domain/entities/quotation_sync_status.dart';

class SyncQueueItem {
  final String quotationId;
  final String? shopName;
  final int? itemCount;
  final double? total;
  final int attemptCount;
  final String? sapDocumentNumber;
  final int? syncDurationMs;
  final String? lastError;
  final QuotationSyncStatus status;

  const SyncQueueItem({
    required this.quotationId,
    this.shopName,
    this.itemCount,
    this.total,
    this.attemptCount = 0,
    this.sapDocumentNumber,
    this.syncDurationMs,
    this.lastError,
    this.status = QuotationSyncStatus.submitted,
  });
}
