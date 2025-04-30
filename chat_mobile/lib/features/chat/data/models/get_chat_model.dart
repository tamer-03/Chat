import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';

class GetChatModel extends GetChatEntity {
  GetChatModel({
    required super.userId,
    required super.username,
    required super.message,
    required super.chatId,
    required super.photoUrl,
    required super.chatType,
  });

  factory GetChatModel.fromJson(Map<String, dynamic> json) {
    var model = GetChatModel(
        userId: json['user_id'],
        username: json['username'],
        message: json['message'],
        chatId: json['chat_id'],
        photoUrl: json['photo'],
        chatType: json['chat_type']);
    return model;
  }
}
