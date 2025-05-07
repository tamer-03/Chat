import 'package:chat_android/features/chat/domain/repository/chat_repository.dart';

class GetLastMessageUsecase {
  ChatRepository chatRepository;
  GetLastMessageUsecase(this.chatRepository);
  Future<void> call(String? message, String chatId, String messageType,
      String? chatMessageId, String? chatType) async {
    return chatRepository.getLastMessage(
        message, chatId, messageType, chatMessageId, chatType);
  }
}
