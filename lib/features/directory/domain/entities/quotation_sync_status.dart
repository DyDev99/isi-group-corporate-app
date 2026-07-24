enum QuotationSyncStatus {
  accepted,
  failed,
  rejected,
  conflict,
  syncing,
  submitted,
}

extension QuotationSyncStatusExtension on QuotationSyncStatus {
  bool get needsUserAction =>
      this == QuotationSyncStatus.failed ||
      this == QuotationSyncStatus.rejected ||
      this == QuotationSyncStatus.conflict;

  String get label {
    return switch (this) {
      QuotationSyncStatus.accepted => 'Accepted',
      QuotationSyncStatus.failed => 'Failed',
      QuotationSyncStatus.rejected => 'Rejected',
      QuotationSyncStatus.conflict => 'Conflict',
      QuotationSyncStatus.syncing => 'Syncing',
      QuotationSyncStatus.submitted => 'Submitted',
    };
  }
}
