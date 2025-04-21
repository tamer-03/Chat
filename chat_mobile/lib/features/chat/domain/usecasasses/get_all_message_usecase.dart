import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';
import 'package:chat_android/features/chat/domain/repository/chat_repository.dart';

class GetAllMessageUsecase {
  final ChatRepository repository;
  GetAllMessageUsecase({required this.repository});
  Future<BaseResponseModel<GetLastMessageEntity>> call(String chatId) {
    return repository.getAllMessage(chatId);
  }
}
