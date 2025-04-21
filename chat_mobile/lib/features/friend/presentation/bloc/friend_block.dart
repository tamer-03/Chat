import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/friend/domain/entites/friend_request_entity.dart';
import 'package:chat_android/features/friend/domain/entites/search_friend_entity.dart';
import 'package:chat_android/features/friend/domain/usecasses/add_friend_usecassess.dart';
import 'package:chat_android/features/friend/domain/usecasses/firend_get_request_usecassess.dart';
import 'package:chat_android/features/friend/domain/usecasses/friend_update_request_usscasses.dart';
import 'package:chat_android/features/friend/domain/usecasses/get_friends_usecasses.dart';
import 'package:chat_android/features/friend/domain/usecasses/search_friend_usecasses.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_event.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

class FriendBlock extends Bloc<FriendEvent, FriendState> {
  final SearchFriendUsecasses searchFriendUsecasses;
  final AddFriendUsecassess addFriendUsecassess;
  final FirendGetRequestUsecassess firendGetRequestUsecassess;
  final FriendUpdateRequestUsscasses friendUpdateRequestUsscasses;
  final GetFriendsUsecasses getFriendsUsecasses;

  FriendBlock(
      {required this.searchFriendUsecasses,
      required this.addFriendUsecassess,
      required this.firendGetRequestUsecassess,
      required this.friendUpdateRequestUsscasses,
      required this.getFriendsUsecasses})
      : super(FriendInitial()) {
    on<SearchFriendEvent>(_onSearchFriend);
    on<AddFriendEvent>(_onAddFriend);
    on<FriendInitialEvent>(_onGetFriendRequest);
    on<UpdateFriendRequestEvent>(_onUpdateFriendRequest);
    on<GetFriendEvent>(_getFriends);
  }
  List<SearchFriendEntity> searchResults = [];
  List<FriendRequestEntity> friendRequests = [];
  BaseResponseModel<SearchFriendEntity> searchResult =
      BaseResponseModel(message: '', status: 0);
  Future<void> _getFriends(
      GetFriendEvent event, Emitter<FriendState> emit) async {
    emit(FriendLoading());
    try {
      final responseModel = await getFriendsUsecasses.call();
      if (responseModel.status == 200) {
        emit(GetFriendsSuccess(
          message: responseModel.message,
          friendRequests: responseModel.data!,
        ));
        log('👫 Arkadaşlar getirildi: ${responseModel.message}');
        log('👫 Arkadaşlar verisi Bloc: ${responseModel.data}');
      } else {
        emit(FriendFailure(errorMessage: responseModel.message));
      }
    } catch (err) {
      throw Exception('Friend get friends failed in repository: $err');
    }
  }

  Future<void> _onUpdateFriendRequest(
      UpdateFriendRequestEvent event, Emitter<FriendState> emit) async {
    emit(FriendLoading());
    try {
      final responseModel =
          await friendUpdateRequestUsscasses.call(event.senderId, event.status);
      if (responseModel.status == 200) {
        log('first friend request length: ${friendRequests.length.toString()}');
        friendRequests.removeWhere((user) => user.userId == event.senderId);
        log('later friend request length: ${friendRequests.length.toString()}');
        emit(FriendRequestSuccess(
            message: responseModel.message, friendRequests: friendRequests));
        log('👫 Arkadaşlık isteği güncellendi: ${responseModel.message}');
      } else {
        emit(FriendFailure(errorMessage: responseModel.message));
      }
    } catch (err) {
      throw Exception('Friend update request failed in repository: $err');
    }
  }

  Future<void> _onGetFriendRequest(
      FriendInitialEvent event, Emitter<FriendState> emit) async {
    emit(FriendLoading());

    try {
      final responseModel = await firendGetRequestUsecassess.call();
      friendRequests = responseModel.data!;
      if (responseModel.status == 200) {
        emit(FriendRequestSuccess(
            message: responseModel.message,
            friendRequests: responseModel.data!));
      } else {
        emit(FriendFailure(errorMessage: responseModel.message));
      }
    } catch (err) {
      throw Exception('Friend get request failed in repository: $err');
    }
  }

  Future<void> _onSearchFriend(
      SearchFriendEvent event, Emitter<FriendState> emit) async {
    emit(FriendLoading());

    try {
      log('🔎 Arama yapılıyor: ${event.username}');
      searchResult = await searchFriendUsecasses.call(event.username);
      searchResults = searchResult.data!;
      log(searchResults.length.toString());
      //final responseModel = await searchFriendUsecasses.call(event.username);
      //log('🔎 Arama sonucu: $responseModel');
      if (searchResult.status == 200) {
        log('datas: ${searchResult.data}');
        emit(FriendSearchSuccess(
            message: searchResult.message, searchResults: searchResult.data!));
      } else {
        emit(FriendFailure(errorMessage: searchResult.message));
      }
    } catch (err) {
      throw Exception('Friend search failed in repository: $err');
    }
  }

  Future<void> _onAddFriend(
      AddFriendEvent event, Emitter<FriendState> emit) async {
    emit(FriendLoading());
    log('searcresolt: ${searchResults.first.friendStatus}');
    try {
      final responseModel = await addFriendUsecassess.call(event.receiverId);
      if (responseModel.status == 200) {
        log('add response 200');
        final updatedResults = searchResults.map((user) {
          if (user.userId == event.receiverId) {
            log('userıd revicre eşit');
            return user.copyWith(friendStatus: 'WAITING');
          }
          log('userıd revicre eşit değiş');
          return user;
        }).toList();
        log(updatedResults.first.friendStatus);
        log(updatedResults.first.toString());
        emit(FriendSearchSuccess(
            message: responseModel.message, searchResults: updatedResults));
      } else {
        emit(FriendFailure(errorMessage: responseModel.message));
      }
    } catch (err) {
      throw Exception('Friend add failed in repository: $err');
    }
  }
}
