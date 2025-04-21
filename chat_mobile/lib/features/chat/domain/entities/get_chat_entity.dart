class GetChatEntity {
  final int userId;
  final String username;
  final String? message;
  final String photoUrl;
  final String chatId;

  GetChatEntity({
    required this.userId,
    required this.username,
    required this.message,
    required this.chatId,
    required this.photoUrl,
  });
}
