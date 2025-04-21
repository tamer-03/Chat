import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/profile/domain/entities/profile_entity.dart';
import 'package:chat_android/features/profile/domain/repository/profile_repository.dart';

class GetProfileUsecasse {
  final ProfileRepository repository;

  GetProfileUsecasse({required this.repository});

  Future<BaseResponseModel<ProfileEntity>> call() async {
    return await repository.getProfile();
  }
}
