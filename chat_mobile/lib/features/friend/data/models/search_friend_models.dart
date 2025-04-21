import 'package:chat_android/features/friend/domain/entites/search_friend_entity.dart';

class SearchFriendModels extends SearchFriendEntity {
  SearchFriendModels({
    required super.userId,
    required super.userName,
    required super.email,
    required super.friendStatus,
  });

  factory SearchFriendModels.fromJson(Map<String, dynamic> json) {
    return SearchFriendModels(
        userId: json['user_id'],
        userName: json['username'],
        email: json['email'],
        friendStatus: json['friend_status']);
  }
}
