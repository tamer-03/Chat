import 'package:chat_android/features/friend/domain/entites/get_friends_entity.dart';

class GetFriendsModel extends GetFriendsEntity {
  GetFriendsModel({
    required super.userId,
    required super.username,
    required super.email,
  });

  factory GetFriendsModel.fromJson(Map<String, dynamic> json) {
    return GetFriendsModel(
        userId: json['user_id'],
        username: json['username'],
        email: json['email']);
  }
}
