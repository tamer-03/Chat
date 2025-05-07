import 'dart:async';

import 'package:chat_android/core/constant/message_types.dart';
import 'package:chat_android/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';
import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';
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
    on<MessageChangeEvent>(_onMessageChanged);

    _onInitMessageListener();
    _onChangeMessageListener();
  }
  List<GetChatEntity> chats = [];
  final List<String> _messages = [];
  StreamSubscription? _messageSubscription;
  StreamSubscription? _changeMessageSubscription;
  List<GetLastMessageEntity> localMessages = [];
  ChatRemoteDataSource chatRemoteDataSource = ChatRemoteDataSource();

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _changeMessageSubscription?.cancel();
    localMessages.clear();
    return super.close();
  }

  void _onInitMessageListener() {
    _messageSubscription = chatRemoteDataSource.messageStream.listen((message) {
      add(MessageReceivedEvent(message: message));
      log('init message listener ${message.message}');
    });
  }

  void _onMessageReceived(MessageReceivedEvent event, Emitter<ChatState> emit) {
    log('local message lenght: ${localMessages.length}');

    localMessages.add(event.message);
    log('local message lenght: ${localMessages.length}');

    log('message received listner: ${event.message.message}');
    emit(GetLastMessageSucces(messageEntity: List.from(localMessages)));
  }

  void _onChangeMessageListener() {
    _changeMessageSubscription =
        chatRemoteDataSource.messageChangeStream.listen((chatMessageId) {
      log('delete message listener');
      if (chatMessageId.message == null) {
        log('delete message listener message null');
        add(
          MessageChangeEvent(
            chatMessageId: chatMessageId.messageId,
          ),
        );
      } else {
        log('delete message listener message not null');
        add(MessageChangeEvent(
          chatMessageId: chatMessageId.messageId,
          message: chatMessageId.message,
        ));
      }
    });
  }

  void _onMessageChanged(MessageChangeEvent event, Emitter<ChatState> emit) {
    log('event null int onmessage deleted bloc');
    if (event.chatMessageId.isNotEmpty) {
      log('event not null ${event.chatMessageId}');
      log('local message lenght: ${localMessages.length}');
      if (event.message != null) {
        localMessages
            .firstWhere(
                (messgeId) => messgeId.chatMessageId == event.chatMessageId)
            .message = event.message;
      } else {
        log('event message null');
        localMessages.removeWhere((message) {
          log('message chat id: ${message.chatMessageId}');
          log('event chat id: ${event.chatMessageId}');
          return message.chatMessageId == event.chatMessageId;
        });
      }

      log('local message lenght: ${localMessages.length}');
      emit(GetLastMessageSucces(messageEntity: localMessages));
    }
  }

  Future<void> _onGetAllMessage(
      GetAllMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      log('sended message in bloc: ${event.chatId}');
      final response = await getAllMessageUsecase.call(event.chatId);

      if (response.status == 200) {
        if (response.data == null || response.data!.isEmpty) {
          emit(GetAllMessageSucces([]));
          return;
        }
        var reversedList = response.data?.reversed.toList();
        reversedList?.forEach((element) {
          log(' reversed list message: ${element.message}');
        });
        log('GetAllMessageSucces emit edilmeden önce');
        if (reversedList != null) {
          localMessages.clear();
          localMessages.addAll(reversedList);
          emit(GetAllMessageSucces(localMessages));
        }
        log('BlocListener state değişimi: ${state.runtimeType}');
        log('GetAllMessageSucces emit edildi');
      }
    } catch (err) {
      log('GetAllMessageEvent error: ${err.toString()}');
      emit(ChatFailure(errorMessage: err.toString()));
    }
  }

  Future<void> _onGetLastMessage(
      GetLastMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      log('sended message: ${event.message}');
      log('sended message type: ${event.messageType}');
      log('chat type: ${event.chatType}');
      switch (event.messageType) {
        case MessageTypes.text:
          await getLastMessageUsecase.call(
            event.message,
            event.chatId,
            event.messageType,
            '',
            event.chatType,
          );
          break;
        case MessageTypes.delete:
          await getLastMessageUsecase.call(
            '',
            event.chatId,
            event.messageType,
            event.chatMessageId,
            '',
          );
          break;
        case MessageTypes.edit:
          await getLastMessageUsecase.call(
            event.message,
            event.chatId,
            event.messageType,
            event.chatMessageId,
            '',
          );
      }

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
        log('chat response bloc: $response');
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
