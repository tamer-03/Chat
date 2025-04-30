import 'package:chat_android/core/constant/chat_types.dart';
import 'package:chat_android/core/constant/message_types.dart';
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
  late String _chatType;
  List<GetLastMessageEntity> localMessages = [];
  List<LocalAllMessagesEntity> localAllMessages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _loadUserInfo();

    // _storage.read(key: 'username').then((value) {
    //   setState(() {
    //     _username = value!;
    //   });
    // });
    // _storage.read(key: 'to_userId').then((value) => setState(() {
    //       _toUserId = int.parse(value!);
    //     }));

    // _storage.read(key: 'chatId').then((value) => setState(() {
    //       _chatId = value!;
    //     }));

    // _storage.read(key: 'chat_type').then((value) => setState(() {
    //       _chatType = value!;
    //     }));
    // Future.delayed(Duration(seconds: 1), () {
    //   log(_chatId);
    //   getAllMessage(_chatId);
    // });
  }

  Future<void> _loadUserInfo() async {
    final response = await Future.wait([
      _storage.read(key: 'username'),
      _storage.read(key: 'chatId'),
      _storage.read(key: 'to_userId'),
      _storage.read(key: 'chat_type'),
    ]);
    setState(() {
      _username = response[0]!;
      _chatId = response[1]!;
      _toUserId = int.parse(response[2]!);
      _chatType = response[3]!;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      log('chatId (after load): $_chatId');
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
    _storage.delete(key: 'chat_type');
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

  void sendMessageAndGetLastMessage(
      String message, String chatId, String messageType, String chatType) {
    log('sendMessageAndGetLastMessage $message');
    BlocProvider.of<ChatBloc>(context)
        .add(GetLastMessageEvent(message, chatId, messageType, chatType));
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
        body: BlocConsumer<ChatBloc, ChatState>(builder: (context, state) {
          if (state is ChatLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ChatFailure) {
            return Center(child: Text(state.errorMessage));
          }
          return Column(children: [
            Expanded(child: _buildListMessages(localAllMessages)),
            _buildMessageInput()
          ]);
        }, listener: (context, state) {
          log('BlocListener state değişimi: ${state.runtimeType}');
          if (state is GetLastMessageSucces) {
            setState(() {
              localAllMessages.add(LocalAllMessagesEntity(
                  message: state.messageEntity.message ?? '',
                  sendedAt: DateTime.now(),
                  photo: state.messageEntity.photo,
                  userId: state.messageEntity.userId));
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
            //getAllMessage(_chatId);
          } else if (state is GetAllMessageSucces) {
            log(' getAllMessageSucces UI ');
            setState(() {
              log('getAllMessageSucces $localAllMessages');
              localAllMessages.addAll(state.messageEntity.map((e) {
                return LocalAllMessagesEntity(
                    message: e.message,
                    sendedAt: e.sendedAt,
                    photo: e.photo,
                    userId: e.userId);
              }).toList());
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              });
            });
          }
        }));
  }

  Widget _buildListMessages(List<LocalAllMessagesEntity> messages) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        if (message.userId == _toUserId) {
          return _buildReceivedMessage(
              context, message.message, message.sendedAt);
        } else {
          return _buildSentMessage(context, message.message, message.sendedAt);
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
              log('chat_type: $_chatType');
              if (_chatType == ChatTypes.personal) {
                sendMessageAndGetLastMessage(_messageController.text, _chatId,
                    MessageTypes.text, _chatType);
                _messageController.clear();
              } else if (_chatType == ChatTypes.group) {
                sendMessageAndGetLastMessage(_messageController.text, _chatId,
                    MessageTypes.text, _chatType);
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(
      BuildContext context, String message, DateTime date) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: EdgeInsets.only(left: 16, top: 4, bottom: 4, right: 60),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: DefaultColors.senderMessage,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2),
            bottomLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 3),
            Text(_formatMessageTime(date),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage(
      BuildContext context, String message, DateTime date) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: EdgeInsets.only(right: 16, top: 4, bottom: 4, left: 60),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: DefaultColors.senderMessage,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(18),
            topLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 3),
            Text(_formatMessageTime(date),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
