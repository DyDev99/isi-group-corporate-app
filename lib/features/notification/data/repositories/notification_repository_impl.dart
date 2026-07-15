import 'package:isi_group_corporate_app/core/error/failures.dart';
import 'package:isi_group_corporate_app/core/utils/result.dart';
import 'package:isi_group_corporate_app/core/utils/typedefs.dart';
import 'package:isi_group_corporate_app/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:isi_group_corporate_app/features/notification/domain/entities/notification_item.dart';
import 'package:isi_group_corporate_app/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required NotificationRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<NotificationItem>> fetchNotifications() async {
    try {
      final items = await _remoteDataSource.fetchNotifications();
      return Success(items);
    } catch (e) {
      return Failed(ServerFailure(message: e.toString()));
    }
  }
}
