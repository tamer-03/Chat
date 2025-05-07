import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';
import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';

abstract class ChatRepository {
  Future<BaseResponseModel> createChat(int userId);
  Future<BaseResponseModel<GetChatEntity>> getChats();
  Future<void> joinChat(String chatId);
  Future<void> getLastMessage(String? message, String chatId,
      String messageType, String? chatMessageId, String? chatType);
  Future<BaseResponseModel<GetLastMessageEntity>> getAllMessage(String chatId);
}
