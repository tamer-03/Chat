import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/chat/domain/entities/get_seem_message_entity.dart';
import 'package:chat_android/features/chat/domain/repository/chat_repository.dart';

class MessageSeenUsecase {
  ChatRepository repository;
  MessageSeenUsecase({required this.repository});

  Future<void> call(String chatMessageId, String chatId) =>
      repository.messageSeen(chatMessageId, chatId);
}
