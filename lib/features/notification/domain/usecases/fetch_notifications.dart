import 'package:isi_group_corporate_app/core/usecase/usecase.dart';
import 'package:isi_group_corporate_app/core/utils/typedefs.dart';
import 'package:isi_group_corporate_app/features/notification/domain/entities/notification_item.dart';
import 'package:isi_group_corporate_app/features/notification/domain/repositories/notification_repository.dart';

/// Retrieves the current notifications list for the notifications sheet.
class FetchNotifications extends UseCase<List<NotificationItem>, NoParams> {
  const FetchNotifications(this._repository);
  final NotificationRepository _repository;

  @override
  ResultFuture<List<NotificationItem>> call(NoParams params) =>
      _repository.fetchNotifications();
}

