import 'package:chat_android/features/friend/domain/entites/friend_request_entity.dart';
import 'package:chat_android/features/friend/domain/entites/get_friends_entity.dart';
import 'package:chat_android/features/friend/domain/entites/search_friend_entity.dart';
import 'package:chat_android/core/base_response.dart';

abstract class FriendRepository {
  Future<BaseResponseModel<SearchFriendEntity>> searchFriend(String username);
  Future<BaseResponseModel> addFriend(int receiverId);
  Future<BaseResponseModel<FriendRequestEntity>> getFriendRequest();
  Future<BaseResponseModel> updateFriendRequest(int senderId, String status);
  Future<BaseResponseModel<GetFriendsEntity>> getFriends();
}
