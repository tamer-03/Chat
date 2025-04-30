class GetLastMessageEntity {
  final int userId;
  final String username;
  final String photo;
  final String chatMessageId;
  final String chatId;
  final String? chatImage;
  final String message;
  final DateTime sendedAt;
  final String chatType;

  GetLastMessageEntity({
    required this.message,
    required this.sendedAt,
    this.chatImage,
    required this.chatId,
    required this.userId,
    required this.username,
    required this.photo,
    required this.chatMessageId,
    required this.chatType,
  });
}
