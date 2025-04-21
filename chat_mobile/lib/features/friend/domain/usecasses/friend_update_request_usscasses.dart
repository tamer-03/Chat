import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/friend/domain/repositories/friend_repository.dart';

class FriendUpdateRequestUsscasses {
  final FriendRepository friendRepository;

  FriendUpdateRequestUsscasses({required this.friendRepository});

  Future<BaseResponseModel> call(int senderId, String status) async {
    return friendRepository.updateFriendRequest(senderId, status);
  }
}
