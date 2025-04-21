import 'package:chat_android/core/theme.dart';
import 'package:chat_android/features/chat/domain/entities/get_chat_entity.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_event.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_state.dart';
import 'package:chat_android/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  List<GetChatEntity> localChats = [];
  @override
  void initState() {
    super.initState();
    log('get chats called');
    getChats();
  }

  void getChats() {
    BlocProvider.of<ChatBloc>(context).add(GetChatsEvent());
  }

  void getLocalChats() {
    BlocProvider.of<ChatBloc>(context).add(GetLocalChatsEvent());
  }

  void joinChat(String chatId) {
    BlocProvider.of<ChatBloc>(context).add(JoinChatEvent(chatId: chatId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Recent',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Container(
            height: 100,
            padding: EdgeInsets.all(5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentContact('Tamer', context),
                _buildRecentContact('Tamer', context),
                _buildRecentContact('Tamer', context),
                _buildRecentContact('Tamer', context),
                _buildRecentContact('Tamer', context),
                _buildRecentContact('Tamer', context),
                _buildRecentContact('Tamer', context)
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      color: DefaultColors.messageListPage,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50))),
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is GetChatsSuccess) {
                        localChats = state.chats;
                        return _buildMessageTile(context, state.chats);
                      } else {
                        return Center(child: Text('Error'));
                      }
                    },
                  )))
        ],
      ),
    );
  }

  Widget _buildMessageTile(BuildContext context, List<GetChatEntity> chats) {
    return ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          GetChatEntity chat;
          // if (chats.isEmpty) {
          //   chat = localChats[index];
          // } else {
          //   chat = chats[index];
          // }

          chat = chats[index];

          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(chat.photoUrl),
            ),
            title: Text(
              chat.username,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              chat.message ?? 'null',
              style: TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
            // trailing: Text(
            //   chat.,
            //   style: TextStyle(color: Colors.grey),
            // ),
            onTap: () async {
              joinChat(chat.chatId);
              storage.write(key: 'chatId', value: chat.chatId);
              storage.write(key: 'username', value: chat.username);
              storage.write(key: 'to_userId', value: chat.userId.toString());
              await Navigator.pushNamed(context, '/chat');
              getChats();
              //getLocalChats();
              //getchats fonskyionu değiştirelecek localden çekielcek
            },
          );
        });
  }

  Widget _buildRecentContact(String name, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage("https://via.placeholder.com/150"),
          ),
          SizedBox(
            height: 5,
          ),
          Text(name, style: Theme.of(context).textTheme.bodyMedium)
        ],
      ),
    );
  }
}
