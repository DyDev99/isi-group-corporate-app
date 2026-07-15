import 'package:isi_group_corporate_app/core/utils/typedefs.dart';
import 'package:isi_group_corporate_app/features/notification/domain/entities/notification_item.dart';

/// Contract for fetching notifications.
///
/// Implemented by the notification data layer so the domain layer can stay
/// independent from network or local cache details.
abstract class NotificationRepository {
  ResultFuture<List<NotificationItem>> fetchNotifications();
}
