class LocalAllMessagesEntity {
  final String message;
  final DateTime sendedAt;
  final String photo;
  final int userId;
  final String chatId;
  final String chatMessageId;

  LocalAllMessagesEntity(
      {required this.chatId,
      required this.chatMessageId,
      required this.message,
      required this.sendedAt,
      required this.photo,
      required this.userId});
}
