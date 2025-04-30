import 'package:chat_android/core/constant/chat_types.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_event.dart';
import 'package:chat_android/features/chat/presentation/blocs/chat_state.dart';
import 'package:chat_android/features/friend/data/datasource/friend_remote_socket_datasource.dart';
import 'package:chat_android/features/friend/domain/entites/get_friends_entity.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_block.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_event.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirendListPage extends StatefulWidget {
  const FirendListPage({super.key});

  @override
  State<FirendListPage> createState() => _FirendListPageState();
}

class _FirendListPageState extends State<FirendListPage> {
  final TextEditingController searchController = TextEditingController();
  late FriendRemoteSocketDatasource _friendRemoteSocketDatasource;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  late int selectedId;

  @override
  void initState() {
    _friendRemoteSocketDatasource = FriendRemoteSocketDatasource();
    _getFriends();
    super.initState();
    _connectSocket();
  }

  Future<void> _connectSocket() async {
    bool isConnected = await _friendRemoteSocketDatasource.connect();
    if (isConnected) {
      log('socket baglandi');
    } else {
      log('socket baglanamadi');
    }
  }

  void _createChat(int userId) {
    BlocProvider.of<ChatBloc>(context).add(ChatCreateEvent(userId));
  }

  void _getFriends() {
    BlocProvider.of<FriendBlock>(context).add(GetFriendEvent());
  }

  void _getChats() {
    BlocProvider.of<ChatBloc>(context).add(GetChatsEvent());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is GetChatsSuccess) {
                log('getchats success');
                final chatUserId =
                    state.chats.firstWhere((chat) => chat.userId == selectedId);
                log('chatId: ${chatUserId.chatId}');
                _storage.write(
                    key: 'chatId', value: chatUserId.chatId.toString());
                _storage.write(
                    key: 'chat_type', value: chatUserId.chatType.toString());

                Navigator.pushNamed(context, '/chat');
              } else if (state is ChatSuccess) {
                _getChats();
              }
            },
          )
        ],
        child: BlocBuilder<FriendBlock, FriendState>(builder: (context, state) {
          if (state is FriendLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GetFriendsSuccess) {
            return _buildFriendListWidget(context, state.friendRequests);
          } else if (state is FriendFailure) {
            return Center(child: Text(state.errorMessage));
          }
          return Container();
        }),
      ),
    );
  }

  Widget _buildFriendListWidget(
      BuildContext context, List<GetFriendsEntity> getFriends) {
    return ListView.builder(
        itemCount: getFriends.length,
        itemBuilder: (context, index) {
          final friend = getFriends[index];
          return Column(children: [
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage("https://via.placeholder.com/150"),
              ),
              title: Text(friend.username),
              subtitle: Text(friend.email),
              onTap: () {
                setState(() {
                  selectedId = friend.userId;
                });
                log('selectedId ${selectedId.toString()}');
                _createChat(friend.userId);
                _storage.write(
                    key: 'username', value: friend.username.toString());
              },
            ),
          ]);
        });
  }
}
