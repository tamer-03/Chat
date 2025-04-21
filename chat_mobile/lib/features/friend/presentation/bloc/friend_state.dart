import 'package:chat_android/features/friend/domain/entites/friend_request_entity.dart';
import 'package:chat_android/features/friend/domain/entites/get_friends_entity.dart';
import 'package:chat_android/features/friend/domain/entites/search_friend_entity.dart';

abstract class FriendState {}

class FriendInitial extends FriendState {}

class FriendLoading extends FriendState {}

class FriendSuccess extends FriendState {
  final String message;

  FriendSuccess({
    required this.message,
  });
}

class GetFriendsSuccess extends FriendState {
  final String message;
  final List<GetFriendsEntity> friendRequests;

  GetFriendsSuccess({required this.message, required this.friendRequests});
}

class FriendRequestSuccess extends FriendState {
  final String message;
  final List<FriendRequestEntity> friendRequests;

  FriendRequestSuccess({
    required this.message,
    required this.friendRequests,
  });
}

class FriendSearchSuccess extends FriendState {
  final List<SearchFriendEntity> searchResults;
  final String message;
  FriendSearchSuccess({required this.message, required this.searchResults});

  FriendSearchSuccess copywith({
    List<SearchFriendEntity>? searchResults,
  }) {
    return FriendSearchSuccess(
        message: message, searchResults: searchResults ?? this.searchResults);
  }
}

class FriendFailure extends FriendState {
  final String errorMessage;

  FriendFailure({required this.errorMessage});
}
