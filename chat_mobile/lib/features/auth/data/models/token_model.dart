import 'package:chat_android/features/auth/domain/entities/token_entity.dart';

class TokenModel extends TokenEntity {
  TokenModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    var token = TokenModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
    return token;
  }
}
