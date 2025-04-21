import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/auth/domain/entities/token_entity.dart';

abstract class AuthRepository {
  Future<BaseResponseModel<TokenEntity>> login(String email, String password);
  Future<BaseResponseModel<TokenEntity>> register(String username, String email,
      String password, String password1, String phone);
}
