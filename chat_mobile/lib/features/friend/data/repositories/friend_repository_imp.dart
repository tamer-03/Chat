import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/friend/data/datasource/friend_remote_socket_datasource.dart';
import 'package:chat_android/features/friend/data/models/get_friends_model.dart';
import 'package:chat_android/features/friend/domain/entites/friend_request_entity.dart';
import 'package:chat_android/features/friend/domain/entites/search_friend_entity.dart';
import 'package:chat_android/features/friend/domain/repositories/friend_repository.dart';
import 'dart:developer';

class FriendRepositoryImp implements FriendRepository {
  final FriendRemoteSocketDatasource friendRemoteSocketDatasource;

  FriendRepositoryImp(this.friendRemoteSocketDatasource);

  @override
  Future<BaseResponseModel<SearchFriendEntity>> searchFriend(
      String username) async {
    log('searchFriend called with username repositoryIpl: $username');
    try {
      final searchResponse =
          await friendRemoteSocketDatasource.searchFriend(username);

      log('searchResponse: $searchResponse');

      final baseResponse = BaseResponseModel<SearchFriendEntity>(
          message: searchResponse.message,
          status: searchResponse.status,
          data: searchResponse.data);

      return baseResponse;
    } catch (e) {
      throw Exception('Friend search failed in repository: $e');
    }
  }

  @override
  Future<BaseResponseModel> addFriend(int receiverId) async {
    final addFriendResponse =
        await friendRemoteSocketDatasource.addFriend(receiverId);

    return BaseResponseModel(
        message: addFriendResponse.message, status: addFriendResponse.status);
  }

  @override
  Future<BaseResponseModel<FriendRequestEntity>> getFriendRequest() async {
    final friendRequestResponse =
        await friendRemoteSocketDatasource.getFriendRequest();

    log('getFriendRequest baseResponse: ${friendRequestResponse.data}');
    log('getFriendRequest baseResponse: ${friendRequestResponse.message}');

    final baseResponse = BaseResponseModel<FriendRequestEntity>(
        message: friendRequestResponse.message,
        status: friendRequestResponse.status,
        data: friendRequestResponse.data);

    return baseResponse;
  }

  @override
  Future<BaseResponseModel> updateFriendRequest(
      int senderId, String status) async {
    final updateFriendRequestResponse = await friendRemoteSocketDatasource
        .updateFriendRequest(senderId, status);
    log('updateFriendRequestResponse: $updateFriendRequestResponse');
    log('updateFriendRequestResponse: ${updateFriendRequestResponse.message}');

    final baseResponse = BaseResponseModel(
        message: updateFriendRequestResponse.message,
        status: updateFriendRequestResponse.status,
        data: updateFriendRequestResponse.data);

    return baseResponse;
  }

  @override
  Future<BaseResponseModel<GetFriendsModel>> getFriends() async {
    final getFriendsResponse = await friendRemoteSocketDatasource.getFriends();
    log('getFriendsResponse: $getFriendsResponse');
    log('getFriendsResponse: ${getFriendsResponse.message}');

    final baseResponse = BaseResponseModel<GetFriendsModel>(
        message: getFriendsResponse.message,
        status: getFriendsResponse.status,
        data: getFriendsResponse.data);

    return baseResponse;
  }
}
