import 'package:isi_group_corporate_app/features/notification/domain/entities/notification_item.dart';

/// A thin data source abstraction for notification retrieval.
///
/// In production, this would talk to a remote API or local cache. For now it
/// returns mocked notification data so the feature can work end-to-end.
abstract class NotificationRemoteDataSource {
  Future<List<NotificationItem>> fetchNotifications();
}

class MockNotificationRemoteDataSource implements NotificationRemoteDataSource {
  const MockNotificationRemoteDataSource();

  @override
  Future<List<NotificationItem>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return [
      NotificationItem(
        id: 'notif-1',
        kind: NotificationKind.creditApproved,
        title: 'notifications.credit_approved_title',
        body: 'notifications.credit_approved_body',
        createdAt: DateTime.utc(2026, 7, 15, 9, 15),
      ),
      NotificationItem(
        id: 'notif-2',
        kind: NotificationKind.followUpDue,
        title: 'notifications.follow_up_due_title',
        body: 'notifications.follow_up_due_body',
        createdAt: DateTime.utc(2026, 7, 14, 16, 30),
      ),
      NotificationItem(
        id: 'notif-3',
        kind: NotificationKind.leadAssigned,
        title: 'notifications.lead_assigned_title',
        body: 'notifications.lead_assigned_body',
        createdAt: DateTime.utc(2026, 7, 14, 13, 5),
      ),
    ];
  }
}
