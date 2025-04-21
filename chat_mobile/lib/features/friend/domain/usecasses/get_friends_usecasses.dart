import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/friend/domain/entites/get_friends_entity.dart';
import 'package:chat_android/features/friend/domain/repositories/friend_repository.dart';

class GetFriendsUsecasses {
  final FriendRepository friendRepository;

  GetFriendsUsecasses({required this.friendRepository});

  Future<BaseResponseModel<GetFriendsEntity>> call() async {
    return await friendRepository.getFriends();
  }
}
