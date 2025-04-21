import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:chat_android/features/auth/domain/entities/token_entity.dart';
import 'package:chat_android/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<BaseResponseModel<TokenEntity>> login(
      String email, String password) async {
    final response =
        await authRemoteDataSource.login(email: email, password: password);

    return BaseResponseModel(
        message: response.message,
        status: response.status,
        data: response.data);
  }

  @override
  Future<BaseResponseModel<TokenEntity>> register(String username, String email,
      String password, String password1, String phone) async {
    final response = await authRemoteDataSource.register(
      username: username,
      email: email,
      password: password,
      password1: password1,
      phone: phone,
    );

    return BaseResponseModel(
        message: response.message,
        status: response.status,
        data: response.data);
  }
}
