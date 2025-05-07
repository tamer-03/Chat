import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';
import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class GetChatsSuccess extends ChatState {
  final String message;
  final List<GetChatEntity> chats;
  GetChatsSuccess({required this.chats, required this.message});
}

class GetAllMessageSucces extends ChatState {
  final List<GetLastMessageEntity> messageEntity;

  GetAllMessageSucces(this.messageEntity);
}

class GetLastMessageSucces extends ChatState with EquatableMixin {
  final List<GetLastMessageEntity> messageEntity;
  GetLastMessageSucces({required this.messageEntity});

  @override
  List<Object?> get props => [messageEntity];
}

class MessageDeleteSuccess extends ChatState {
  final String isDeleted;
  MessageDeleteSuccess({required this.isDeleted});
}

class ChatUpdate extends ChatState {
  final List<Stream> message;
  ChatUpdate({required this.message});
}

class ChatSuccess extends ChatState {
  final String message;
  ChatSuccess({required this.message});
}

class ChatFailure extends ChatState {
  final String errorMessage;
  ChatFailure({required this.errorMessage});
}
