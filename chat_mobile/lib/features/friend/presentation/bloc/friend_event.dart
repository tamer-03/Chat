abstract class FriendEvent {}

class FriendInitialEvent extends FriendEvent {}

class GetFriendEvent extends FriendEvent {}

class SearchFriendEvent extends FriendEvent {
  final String username;

  SearchFriendEvent({required this.username});
}

class AddFriendEvent extends FriendEvent {
  final int receiverId;

  AddFriendEvent({required this.receiverId});
}

class UpdateFriendRequestEvent extends FriendEvent {
  final int senderId;
  final String status;

  UpdateFriendRequestEvent({required this.senderId, required this.status});
}
