import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/friend/domain/entites/friend_request_entity.dart';
import 'package:chat_android/features/friend/domain/repositories/friend_repository.dart';

class FirendGetRequestUsecassess {
  final FriendRepository friendRepository;

  FirendGetRequestUsecassess({required this.friendRepository});

  Future<BaseResponseModel<FriendRequestEntity>> call() async {
    return friendRepository.getFriendRequest();
  }
}
