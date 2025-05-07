import 'package:chat_android/core/constant/chat_types.dart';
import 'package:chat_android/core/constant/message_types.dart';
import 'package:chat_android/core/theme.dart';
import 'package:chat_android/features/chat/domain/entities/get_last_message_entity.dart';
import 'package:chat_android/features/chat/domain/entities/local_all_messages_entity.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_event.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  List<LocalAllMessagesEntity> localAllMessages = [];
  final ScrollController _scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
  bool _isEditing = false;
  String _editingMessageId = '';

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
    _focusNode.dispose();
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

  void sendMessageAndGetLastMessage(String message, String chatId,
      String messageType, String chatMessageId, String chatType) {
    log('sendMessageAndGetLastMessage $message');
    BlocProvider.of<ChatBloc>(context).add(GetLastMessageEvent(
        message, chatId, messageType, chatType, chatMessageId));
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
          } else if (state is GetLastMessageSucces) {
            return Column(children: [
              Expanded(
                child: _buildListMessages(state.messageEntity),
              ),
              _buildMessageInput()
            ]);
          } else if (state is GetAllMessageSucces) {
            return Column(children: [
              Expanded(child: _buildListMessages(state.messageEntity)),
              _buildMessageInput()
            ]);
          }

          return Column(
            children: [
              Center(
                child: Text('hata'),
              )
            ],
          );
        }, listener: (context, state) {
          log('BlocListener state değişimi: ${state.runtimeType}');
          if (state is GetLastMessageSucces) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
            //getAllMessage(_chatId);
          } else if (state is GetAllMessageSucces) {
            log(' getAllMessageSucces UI ');
            setState(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              });
            });
          } else if (state is MessageDeleteSuccess) {
            log('message delete success');
            setState(() {
              localAllMessages.removeWhere(
                  (element) => element.chatMessageId == state.isDeleted);
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
          }
        }));
  }

  Widget _buildListMessages(List<GetLastMessageEntity> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          if (message.userId == _toUserId) {
            return _buildReceivedMessage(
              context,
              message.message,
              message.sendedAt,
            );
          } else {
            return _buildSentMessage(
              context,
              message.message,
              message.sendedAt,
              message.chatId,
              message.chatMessageId,
            );
          }
        },
      );
    }
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
              final messageInput = _messageController.text;
              if (messageInput.isEmpty) return;
              if (_isEditing) {
                sendMessageAndGetLastMessage(
                  messageInput,
                  _chatId,
                  MessageTypes.edit,
                  _editingMessageId,
                  '',
                );
                setState(() {
                  _isEditing = false;
                  _editingMessageId = '';
                });
                return;
              }
              log('chat_type: $_chatType');
              if (_chatType == ChatTypes.personal) {
                sendMessageAndGetLastMessage(_messageController.text, _chatId,
                    MessageTypes.text, '', _chatType);
                _messageController.clear();
              } else if (_chatType == ChatTypes.group) {
                sendMessageAndGetLastMessage(_messageController.text, _chatId,
                    MessageTypes.text, '', _chatType);
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSentMessage(BuildContext context, String? message, DateTime date,
      String chatId, String chatMessageId) {
    if (message != null) {
      return Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onLongPress: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(1000, 500, 10, 0),
              items: [
                PopupMenuItem(
                  value: MessageTypes.delete,
                  child: Text('Delete'),
                ),
                PopupMenuItem(
                  value: MessageTypes.edit,
                  child: Text('Edit'),
                )
              ],
            ).then(
              (value) {
                if (value == MessageTypes.delete) {
                  log('delete message');
                  sendMessageAndGetLastMessage(
                      '', chatId, MessageTypes.delete, chatMessageId, '');
                } else if (value == MessageTypes.edit) {
                  setState(() {
                    _messageController.text = message;
                    _isEditing = true;
                    _editingMessageId = chatMessageId;
                  });
                  log('edit message');
                  //var editMessage = _messageController.text;
                  _focusNode.requestFocus();
                  // sendMessageAndGetLastMessage(
                  //     editMessage, chatId, '', chatMessageId, '');
                  //editing message
                }
              },
            );
          },
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
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildReceivedMessage(
    BuildContext context,
    String? message,
    DateTime date,
  ) {
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
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
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
