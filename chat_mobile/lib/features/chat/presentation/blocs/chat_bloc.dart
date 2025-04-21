import 'dart:async';

import 'package:chat_android/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';
import 'package:chat_android/features/chat/domain/entities/local_all_messages_entity.dart';
import 'package:chat_android/features/chat/domain/usecasasses/create_chat_usecase.dart';
import 'package:chat_android/features/chat/domain/usecasasses/get_all_message_usecase.dart';
import 'package:chat_android/features/chat/domain/usecasasses/get_chats_usecase.dart';
import 'package:chat_android/features/chat/domain/usecasasses/get_last_message_usecase.dart';
import 'package:chat_android/features/chat/domain/usecasasses/join_chat_usecase.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_event.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  CreateChatUsecase createChatUsecase;
  GetChatsUsecase getChatsUsecase;
  JoinChatUsecase joinChatUsecase;
  GetLastMessageUsecase getLastMessageUsecase;
  GetAllMessageUsecase getAllMessageUsecase;
  ChatBloc(
      {required this.createChatUsecase,
      required this.getChatsUsecase,
      required this.joinChatUsecase,
      required this.getLastMessageUsecase,
      required this.getAllMessageUsecase})
      : super(ChatInitial()) {
    on<ChatCreateEvent>(_onCreateChat);
    on<GetChatsEvent>(_onGetChats);
    on<JoinChatEvent>(_onJoinChat);
    on<GetLocalChatsEvent>(_onGetLocalChats);
    on<GetLastMessageEvent>(_onGetLastMessage);
    on<GetAllMessageEvent>(_onGetAllMessage);
    on<MessageReceivedEvent>(_onMessageReceived);

    _onInitMessageListener();
  }
  List<GetChatEntity> chats = [];
  final List<String> _messages = [];
  List<LocalAllMessagesEntity> localAllMessages = [];
  StreamSubscription? _messageSubscription;
  ChatRemoteDataSource chatRemoteDataSource = ChatRemoteDataSource();

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }

  void _onInitMessageListener() {
    _messageSubscription = chatRemoteDataSource.messageStream.listen((message) {
      add(MessageReceivedEvent(message: message));
    });
  }

  void _onMessageReceived(MessageReceivedEvent event, Emitter<ChatState> emit) {
    _messages.add(event.message.message ?? '');
    log('message received: ${event.message}');
    emit(GetLastMessageSucces(messageEntity: event.message));
  }

  Future<void> _onGetAllMessage(
      GetAllMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      log('sended message in bloc: ${event.chatId}');
      final response = await getAllMessageUsecase.call(event.chatId);
      response.data?.forEach((element) {
        localAllMessages.add(LocalAllMessagesEntity(
            message: element.message,
            sendedAt: element.sendedAt,
            photo: element.photo,
            userId: element.userId));
      });
      if (response.status == 200) {
        log('chat response bloc: ${response.data}');
        emit(GetAllMessageSucces(messageEntity: response.data!));
      }
    } catch (err) {
      emit(ChatFailure(errorMessage: err.toString()));
    }
  }

  Future<void> _onGetLastMessage(
      GetLastMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      log('sended message: ${event.message}');

      await getLastMessageUsecase.call(event.message, event.chatId);

      _messages.add(event.message);
      // if (response.status == 200) {
      //   log('chat response bloc: ${response.data!.first}');

      //   emit(GetLastMessageSucces(messageEntity: response.data!.first));
      // } else {
      //   emit(ChatFailure(errorMessage: response.message));
      // }
    } catch (err) {
      emit(ChatFailure(errorMessage: err.toString()));
    }
  }

  void _onGetLocalChats(GetLocalChatsEvent event, Emitter<ChatState> emit) {
    emit(ChatLoading());
    try {
      log('chats: ${chats.length}');
      log(chats.toString());
      emit(GetChatsSuccess(message: '', chats: chats));
    } catch (err) {
      emit(ChatFailure(errorMessage: err.toString()));
    }
  }

  Future<void> _onJoinChat(JoinChatEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      await joinChatUsecase.call(event.chatId);
      log('chat joined');
    } catch (err) {
      emit(ChatFailure(errorMessage: err.toString()));
    }
  }

  Future<void> _onGetChats(GetChatsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final response = await getChatsUsecase.call();
      if (response.status == 200) {
        log('chat response bloc: ${response.data}');
        chats = response.data!;
        emit(GetChatsSuccess(message: response.message, chats: response.data!));
      } else {
        emit(ChatFailure(errorMessage: response.message));
      }
    } catch (err) {
      throw Exception('Chat create failed in repository: $err');
    }
  }

  Future<void> _onCreateChat(
      ChatCreateEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      log('bloc çalıştı');
      final response = await createChatUsecase.call(event.userId);
      log('response: ${response.toString()}');
      if (response.status == 200) {
        emit(ChatSuccess(message: response.message));
        log('chat olusturuldu');
      } else {
        emit(ChatFailure(errorMessage: response.message));
      }
    } catch (err) {
      throw Exception('Chat create failed in repository: $err');
    }
  }
}
