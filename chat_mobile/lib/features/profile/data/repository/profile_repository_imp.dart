import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:chat_android/features/profile/domain/entities/profile_entity.dart';
import 'package:chat_android/features/profile/domain/repository/profile_repository.dart';
import 'dart:developer';

class ProfileRepositoryImp implements ProfileRepository {
  final ProfileRemoteDataSource profileRemoteDataSource;

  ProfileRepositoryImp({required this.profileRemoteDataSource});

  @override
  Future<BaseResponseModel<ProfileEntity>> getProfile() async {
    final response = await profileRemoteDataSource.getProfile();
    log('profileRepositoryImp response: ${response.message}');
    log('profileRepositoryImp response: ${response.data}');
    final responseModel = BaseResponseModel(
      message: response.message,
      status: response.status,
      data: response.data,
    );
    log('profileRepositoryImp responseModel data: ${responseModel.data}');
    return responseModel;
  }

  @override
  Future<BaseResponseModel> updateProfile(
      String username, String email, String phone) async {
    log('profileRepositoryImp username: $username');
    final response = await profileRemoteDataSource.updateProfile(
        username: username, email: email, phone: phone);
    log('profileRepositoryImp response: ${response.message}');
    final responseModel = BaseResponseModel(
        message: response.message,
        status: response.status,
        data: response.data);
    return responseModel;
  }
}
