import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/friend/domain/repositories/friend_repository.dart';

class AddFriendUsecassess {
  final FriendRepository friendRepository;
  AddFriendUsecassess({required this.friendRepository});

  Future<BaseResponseModel> call(int receiverId) async {
    return friendRepository.addFriend(receiverId);
  }
}
