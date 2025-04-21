import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';
import 'package:chat_android/features/chat/domain/repository/chat_repository.dart';

class GetLastMessageUsecase {
  ChatRepository chatRepository;
  GetLastMessageUsecase(this.chatRepository);
  Future<void> call(String message, String chatId) {
    return chatRepository.getLastMessage(message, chatId);
  }
}
