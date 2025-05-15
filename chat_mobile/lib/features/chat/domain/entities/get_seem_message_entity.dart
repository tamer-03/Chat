class GetSeemMessageEntity {
  final int userId;
  final String username;
  final String photo;
  final DateTime seemedAt;
  final String chatMessageId;

  GetSeemMessageEntity({
    required this.userId,
    required this.username,
    required this.photo,
    required this.seemedAt,
    required this.chatMessageId,
  });
}
