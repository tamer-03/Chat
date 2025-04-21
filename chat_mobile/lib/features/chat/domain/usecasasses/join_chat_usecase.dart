import 'package:chat_android/features/chat/domain/repository/chat_repository.dart';

class JoinChatUsecase {
  final ChatRepository repository;

  JoinChatUsecase({required this.repository});

  Future<void> call(String chatId) => repository.joinChat(chatId);
}
