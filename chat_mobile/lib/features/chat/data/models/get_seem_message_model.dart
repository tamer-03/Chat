import 'package:chat_android/features/chat/domain/entities/get_seem_message_entity.dart';

class GetSeemMessageModel extends GetSeemMessageEntity {
  GetSeemMessageModel({
    required super.userId,
    required super.username,
    required super.photo,
    required super.seemedAt,
    required super.chatMessageId,
  });

  factory GetSeemMessageModel.fromJson(Map<String, dynamic> json) {
    return GetSeemMessageModel(
      userId: json['user_id'],
      username: json['username'],
      photo: json['photo'],
      seemedAt: DateTime.parse(json['seemed_at']),
      chatMessageId: json['chat_message_id'],
    );
  }
}
