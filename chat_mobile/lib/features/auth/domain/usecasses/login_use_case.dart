import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/auth/domain/entities/token_entity.dart';
import 'package:chat_android/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<BaseResponseModel<TokenEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}
