import 'package:chat_android/core/constant/storage_keys.dart';
import 'package:chat_android/features/auth/domain/entities/token_entity.dart';
import 'package:chat_android/features/auth/domain/usecasses/login_use_case.dart';
import 'package:chat_android/features/auth/domain/usecasses/register_use_case.dart';
import 'package:chat_android/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_android/features/auth/presentation/bloc/auth_satate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';

class AuthBloc extends Bloc<AuthEvent, AuthSatate> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final _storage = FlutterSecureStorage();

  AuthBloc({required this.registerUseCase, required this.loginUseCase})
      : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
  }

  Future<void> _onRegister(
      RegisterEvent event, Emitter<AuthSatate> emit) async {
    emit(AuthLoading());
    try {
      final response = await registerUseCase.call(event.username, event.email,
          event.password, event.password1, event.phone);
      log(' response:${response.toString()}');
      if (response.status != 200) {
        log(' response:    $response');
        emit(AuthFailure(error: response.message));
      } else {
        log(' response:    $response');
        emit(AuthSuccess(message: 'Register is succesful'));
      }
    } catch (err) {
      log(' response:  $err');
      emit(AuthFailure(error: 'Register failed $err'));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthSatate> emit) async {
    emit(AuthLoading());
    try {
      final response = await loginUseCase.call(
        event.email,
        event.password,
      );
      TokenEntity tokenModel = response.data!.first;

      log(tokenModel.accessToken.toString());
      if (response.data != null) {
        await _storage.write(
            key: StorageKeys.token, value: tokenModel.accessToken);
        await _storage.write(
            key: StorageKeys.refreshToken, value: tokenModel.refreshToken);

        emit(AuthSuccess(message: 'Login is succesful'));
      } else {
        emit(AuthFailure(error: 'Login failed: Token not received'));
      }
    } catch (err) {
      emit(AuthFailure(error: 'Login failed $err'));
    }
  }
}
