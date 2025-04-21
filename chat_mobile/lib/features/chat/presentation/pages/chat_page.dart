import 'package:chat_android/core/theme.dart';
import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';
import 'package:chat_android/features/chat/domain/entities/local_all_messages_entity.dart';
import 'package:chat_android/features/chat/domain/usecasasses/create_chat_usecase.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_event.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  late String _username;
  late String _chatId;
  late int _toUserId;
  List<GetLastMessageEntity> localMessages = [];
  final List<LocalAllMessagesEntity> localAllMessages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _storage.read(key: 'username').then((value) {
      setState(() {
        _username = value!;
      });
    });
    _storage.read(key: 'to_userId').then((value) => setState(() {
          _toUserId = int.parse(value!);
        }));

    _storage.read(key: 'chatId').then((value) => setState(() {
          _chatId = value!;
        }));
    Future.delayed(Duration(seconds: 1), () {
      log(_chatId);
      getAllMessage(_chatId);
    });
  }

  @override
  void dispose() {
    log('dispose called');
    _messageController.dispose();
    _storage.delete(key: 'username');
    _storage.delete(key: 'chatId');
    _storage.delete(key: 'to_userId');
    localAllMessages.clear();
    super.dispose();
  }

  void getAllMessage(String chatId) {
    BlocProvider.of<ChatBloc>(context).add(GetAllMessageEvent(chatId: chatId));
  }

  void getChats() {
    log('get chats called with dispose');
    BlocProvider.of<ChatBloc>(context).add(GetChatsEvent());
  }

  // void createChat(int userId) {
  //   BlocProvider.of<ChatBloc>(context).add(ChatCreateEvent(userId));
  //   log('userId: $userId');
  //   log('creating chat');
  // }

  void sendMessageAndGetLastMessage(String message, String chatId) {
    log('sendMessageAndGetLastMessage $message');
    BlocProvider.of<ChatBloc>(context)
        .add(GetLastMessageEvent(message, chatId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage("https://placehold.co/600x400"),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              _username,
              style: Theme.of(context).textTheme.titleMedium,
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is GetLastMessageSucces) {
                setState(() {
                  localAllMessages.add(LocalAllMessagesEntity(
                      message: state.messageEntity.message ?? '',
                      sendedAt: DateTime.now(),
                      photo: state.messageEntity.photoUrl,
                      userId: state.messageEntity.userId));
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
                });
                //getAllMessage(_chatId);
              } else if (state is GetAllMessageSucces) {
                setState(() {
                  localAllMessages.clear();
                  localAllMessages.addAll(state.messageEntity.map((e) {
                    return LocalAllMessagesEntity(
                        message: e.message,
                        sendedAt: e.sendedAt,
                        photo: e.photo,
                        userId: e.userId);
                  }).toList());
                });
              }
            },
          ),
        ],
        child: Column(
          children: [
            Expanded(child:
                BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
              if (state is ChatLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ChatFailure) {
                return Center(child: Text(state.errorMessage));
              }
              return _buildListMessages(localAllMessages);
            })),
            _buildMessageInput()
          ],
        ),
      ),
    );
  }

  Widget _buildListMessages(List<LocalAllMessagesEntity> messages) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        if (message.userId == _toUserId) {
          return _buildReceivedMessage(context, message.message);
        } else {
          return _buildSentMessage(context, message.message);
        }
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.sentMessageInput,
        borderRadius: BorderRadius.circular(25),
      ),
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          GestureDetector(
            child: Icon(
              Icons.camera_alt,
              color: Colors.grey,
            ),
            onTap: () {},
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                  hintText: "Message",
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            child: Icon(
              Icons.send,
              color: Colors.grey,
            ),
            onTap: () {
              sendMessageAndGetLastMessage(
                _messageController.text,
                _chatId,
              );
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(right: 30, top: 5, bottom: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: DefaultColors.receiverMessage,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20))),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildSentMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(right: 30, top: 5, bottom: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: DefaultColors.senderMessage,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topLeft: Radius.circular(20))),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
