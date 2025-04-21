import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/profile/domain/repository/profile_repository.dart';

class UpdateProfileUsecase {
  final ProfileRepository repository;

  UpdateProfileUsecase({required this.repository});

  Future<BaseResponseModel> call(String username, String email, String phone) {
    return repository.updateProfile(username, email, phone);
  }
}
