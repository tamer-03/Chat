import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';

class GetLastMessageModel extends GetLastMessageEntity {
  GetLastMessageModel({
    required super.chatId,
    required super.userId,
    required super.username,
    required super.photo,
    required super.chatMessageId,
    required super.message,
    required super.sendedAt,
    required super.chatType,
    super.chatImage,
  });

  factory GetLastMessageModel.fromJson(Map<String, dynamic> json) {
    return GetLastMessageModel(
      chatImage: json['chat_image'] ?? 'empty',
      message: json['message'],
      sendedAt: DateTime.parse(json['sended_at']),
      chatId: json['chat_id'],
      userId: json['user_id'],
      username: json['username'],
      photo: json['photo'],
      chatMessageId: json['chat_message_id'],
      chatType: json['chat_type'],
    );
  }
}
