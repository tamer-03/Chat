import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<BaseResponseModel<ProfileEntity>> getProfile();
  Future<BaseResponseModel> updateProfile(
      String username, String email, String phone);
}
