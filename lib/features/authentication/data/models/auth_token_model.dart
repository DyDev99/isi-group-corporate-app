import 'package:isi_group_corporate_app/core/utils/typedefs.dart';
import 'package:isi_group_corporate_app/features/authentication/domain/entities/auth_token.dart';

class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokenModel.fromMap(DataMap map) => AuthTokenModel(
        accessToken: map['access_token'] as String? ?? '',
        refreshToken: map['refresh_token'] as String? ?? '',
      );

  DataMap toMap() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };
}

