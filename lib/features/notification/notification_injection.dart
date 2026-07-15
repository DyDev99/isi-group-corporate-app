import 'package:get_it/get_it.dart';
import 'package:isi_group_corporate_app/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:isi_group_corporate_app/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:isi_group_corporate_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:isi_group_corporate_app/features/notification/domain/usecases/fetch_notifications.dart';

void registerNotificationFeature(GetIt sl) {
  sl.registerLazySingleton<NotificationRemoteDataSource>(
      () => const MockNotificationRemoteDataSource());
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => FetchNotifications(sl()));
}
