import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';

abstract class ChatEvent {}

class ChatCreateEvent extends ChatEvent {
  final int userId;
  ChatCreateEvent(this.userId);
}

class JoinChatEvent extends ChatEvent {
  final String chatId;
  JoinChatEvent({required this.chatId});
}

class GetAllMessageEvent extends ChatEvent {
  final String chatId;
  GetAllMessageEvent({required this.chatId});
}

class MessageReceivedEvent extends ChatEvent {
  final GetChatEntity message;
  MessageReceivedEvent({required this.message});
}

class GetLastMessageEvent extends ChatEvent {
  final String message;
  final String chatId;
  GetLastMessageEvent(this.message, this.chatId);
}

class GetLocalChatsEvent extends ChatEvent {}

class GetChatsEvent extends ChatEvent {}
