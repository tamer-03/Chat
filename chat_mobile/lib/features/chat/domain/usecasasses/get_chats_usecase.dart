import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';
import 'package:chat_android/features/chat/domain/repository/chat_repository.dart';

class GetChatsUsecase {
  final ChatRepository chatRepository;

  GetChatsUsecase({required this.chatRepository});
  Future<BaseResponseModel<GetChatEntity>> call() {
    return chatRepository.getChats();
  }
}
