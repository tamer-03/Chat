import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';
import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';
import 'package:chat_android/features/chat/domain/entities/get_seem_message_entity.dart';
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
  final List<String> isSeenMessage;
  GetAllMessageSucces(this.messageEntity, this.isSeenMessage);
}

class MessageSeenSuccess extends ChatState {
  final List<String> isSeenMessage;
  final List<GetLastMessageEntity> messageEntity;
  MessageSeenSuccess(
      {required this.isSeenMessage, required this.messageEntity});
}

class GetLastMessageSucces extends ChatState with EquatableMixin {
  final List<GetLastMessageEntity> messageEntity;
  final List<String> isSeenMessage;
  GetLastMessageSucces(
      {required this.messageEntity, required this.isSeenMessage});

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
