import 'dart:developer';
import 'package:chat_android/features/friend/data/datasource/friend_remote_socket_datasource.dart';
import 'package:chat_android/features/friend/domain/entites/friend_request_entity.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_block.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_event.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendRequestPage extends StatefulWidget {
  const FriendRequestPage({super.key});

  @override
  State<FriendRequestPage> createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  final TextEditingController searchController = TextEditingController();
  late FriendRemoteSocketDatasource _friendRemoteSocketDatasource;

  @override
  void initState() {
    _friendRemoteSocketDatasource = FriendRemoteSocketDatasource();
    super.initState();
    _connectSocket();
    // _getFriendRequest();
  }

  Future<void> _connectSocket() async {
    bool isConnected = await _friendRemoteSocketDatasource.connect();
    if (isConnected) {
      log('socket baglandi');
    } else {
      log('socket baglanamadi');
    }
  }

  // void _getFriendRequest() {
  //   BlocProvider.of<FriendBlock>(context).add(FriendInitialEvent());
  // }

  void _updateFriendRequest(int senderId, String status) {
    BlocProvider.of<FriendBlock>(context)
        .add(UpdateFriendRequestEvent(senderId: senderId, status: status));
    log('istek guncellendi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Search',
          ),
          //onSubmitted: (_) => gelen istekleri ara _searchFriend(context),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          IconButton(
            onPressed: () {
              //gelen istekleri ara _searchFriend(context),
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: BlocBuilder<FriendBlock, FriendState>(builder: (context, state) {
        if (state is FriendLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is FriendRequestSuccess) {
          return _buildFriendListWidget(context, state.friendRequests);
        } else if (state is FriendFailure) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        return Container();
      }),
    );
  }

  Widget _buildFriendListWidget(
      BuildContext context, List<FriendRequestEntity> friendRequests) {
    return ListView.builder(
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          final firend = friendRequests[index];
          return Column(children: [
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage("https://via.placeholder.com/150"),
              ),
              title: Text(firend.username),
              subtitle: Text(firend.email),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _updateFriendRequest(firend.userId, 'Accepted');

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('arkadaşlık isteği kabul edildi'),
                            ),
                          );
                        },
                        child: Text('Accept')),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _updateFriendRequest(firend.userId, 'Rejected');

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('reddedildi'),
                            ),
                          );
                        },
                        child: Text('Decline'))
                  ],
                ))
          ]);
        });
  }
}
