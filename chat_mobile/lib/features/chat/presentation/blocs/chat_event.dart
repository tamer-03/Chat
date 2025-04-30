import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';
import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';

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
  final GetLastMessageEntity message;
  MessageReceivedEvent({required this.message});
}

class GetLastMessageEvent extends ChatEvent {
  final String message;
  final String chatId;
  final String messageType;
  final String chatType;
  GetLastMessageEvent(
      this.message, this.chatId, this.messageType, this.chatType);
}

class GetLocalChatsEvent extends ChatEvent {}

class GetChatsEvent extends ChatEvent {}
