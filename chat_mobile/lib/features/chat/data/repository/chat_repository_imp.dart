import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';
import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';
import 'package:chat_android/features/chat/domain/repository/chat_repository.dart';
import 'dart:developer';

class ChatRepositoryImp implements ChatRepository {
  final ChatRemoteDataSource chatRemoteDataSource;
  ChatRepositoryImp({required this.chatRemoteDataSource});
  @override
  Future<BaseResponseModel> createChat(int userId) async {
    log('userId: $userId');
    log('repositoryıomplaa');
    final response = await chatRemoteDataSource.createChat(userId);
    return BaseResponseModel(
        message: response.message,
        status: response.status,
        data: response.data);
  }

  @override
  Future<BaseResponseModel<GetChatEntity>> getChats() async {
    final response = await chatRemoteDataSource.getChats();
    return BaseResponseModel<GetChatEntity>(
        message: response.message,
        status: response.status,
        data: response.data);
  }

  @override
  Future<void> joinChat(String chatId) async {
    await chatRemoteDataSource.joinChat(chatId);
  }

  @override
  Future<void> getLastMessage(String? message, String chatId,
      String messageType, String? chatMessageId, String? chatType) async {
    // final response =
    await chatRemoteDataSource.getLastMessage(
        message, chatId, messageType, chatMessageId, chatType);
    // log('repository get last message: ${response.data?.first.message}');
    // log('repository get last message: ${response.status}');
    // return BaseResponseModel<GetChatEntity>(
    //     message: response.message,
    //     status: response.status,
    //     data: response.data);
  }

  @override
  Future<BaseResponseModel<GetLastMessageEntity>> getAllMessage(
      String chatId) async {
    final response = await chatRemoteDataSource.getAllMessage(chatId);
    log('repository  ${response.data!.length}');
    return BaseResponseModel<GetLastMessageEntity>(
        message: response.message,
        status: response.status,
        data: response.data);
  }
}
