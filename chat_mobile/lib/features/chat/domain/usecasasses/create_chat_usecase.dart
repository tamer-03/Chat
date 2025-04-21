import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/chat/domain/repository/chat_repository.dart';

class CreateChatUsecase {
  final ChatRepository chatRepository;

  CreateChatUsecase(this.chatRepository);

  Future<BaseResponseModel> call(int userId) {
    return chatRepository.createChat(userId);
  }
}
