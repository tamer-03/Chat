import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/auth/domain/entities/token_entity.dart';
import 'package:chat_android/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<BaseResponseModel<TokenEntity>> call(String username, String email,
      String password, String password1, String phone) {
    return repository.register(username, email, password, password1, phone);
  }
}
