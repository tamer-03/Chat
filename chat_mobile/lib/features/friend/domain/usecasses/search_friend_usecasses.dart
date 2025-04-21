import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/friend/domain/entites/search_friend_entity.dart';
import 'package:chat_android/features/friend/domain/repositories/friend_repository.dart';

class SearchFriendUsecasses {
  final FriendRepository friendRepository;

  SearchFriendUsecasses({required this.friendRepository});

  Future<BaseResponseModel<SearchFriendEntity>> call(String username) async {
    return friendRepository.searchFriend(username);
  }
}
