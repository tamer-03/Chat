import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';
import 'package:chat_android/features/chat/domain/entities/get_seem_message_entity.dart';

abstract class ChatEvent {}

class ChatCreateEvent extends ChatEvent {
  final int userId;
  ChatCreateEvent(this.userId);
}

class MessageSeenEvent extends ChatEvent {
  final String chatMessageId;
  final String chatId;
  MessageSeenEvent({required this.chatMessageId, required this.chatId});
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

class MessageChangeEvent extends ChatEvent {
  final String chatMessageId;
  final String? message;
  MessageChangeEvent({required this.chatMessageId, this.message});
}

class MessageSeenListenerEvent extends ChatEvent {
  final List<GetSeemMessageEntity> isSeen;
  MessageSeenListenerEvent({required this.isSeen});
}

class GetLastMessageEvent extends ChatEvent {
  final String message;
  final String chatId;
  final String messageType;
  final String chatType;
  final String? chatMessageId;
  GetLastMessageEvent(this.message, this.chatId, this.messageType,
      this.chatType, this.chatMessageId);
}

class GetLocalChatsEvent extends ChatEvent {}

class GetChatsEvent extends ChatEvent {}
