class LocalAllMessagesEntity {
  final String message;
  final DateTime sendedAt;
  final String photo;
  final int userId;

  LocalAllMessagesEntity(
      {required this.message,
      required this.sendedAt,
      required this.photo,
      required this.userId});
}
