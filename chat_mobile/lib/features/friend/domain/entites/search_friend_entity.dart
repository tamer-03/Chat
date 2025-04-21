class SearchFriendEntity {
  final int userId;
  final String userName;
  final String email;
  final String friendStatus;
  SearchFriendEntity(
      {required this.userId,
      required this.userName,
      required this.email,
      required this.friendStatus});

  SearchFriendEntity copyWith({String? friendStatus}) {
    return SearchFriendEntity(
        userId: userId,
        userName: userName,
        email: email,
        friendStatus: friendStatus ?? this.friendStatus);
  }
}
