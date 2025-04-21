import 'package:chat_android/features/friend/data/datasource/friend_remote_socket_datasource.dart';
import 'package:chat_android/features/friend/domain/entites/search_friend_entity.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_block.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_event.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_state.dart';
import 'package:chat_android/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

class FirendSearchPage extends StatefulWidget {
  const FirendSearchPage({super.key});

  @override
  State<FirendSearchPage> createState() => _FirendSearchPageState();
}

class _FirendSearchPageState extends State<FirendSearchPage> {
  final SocketServices socketServices = SocketServices();
  final TextEditingController searchController = TextEditingController();
  late FriendRemoteSocketDatasource _friendRemoteSocketDatasource;

  @override
  void initState() {
    super.initState();
    _friendRemoteSocketDatasource = FriendRemoteSocketDatasource();
    _connectSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchFriend(context);
  }

  Future<void> _connectSocket() async {
    bool isConnected = await _friendRemoteSocketDatasource.connect();
    if (isConnected) {
      log('socket baglandi');
    } else {
      log('socket baglanamadi');
    }
  }

  void _addFriend(BuildContext context, int receiverId) {
    BlocProvider.of<FriendBlock>(context)
        .add(AddFriendEvent(receiverId: receiverId));
    log('👫 Arkadaş ekleme isteği gönderildi: $receiverId');
  }

  void _searchFriend(BuildContext context) {
    // BuildContext al
    String searchQuery = searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      if (!_friendRemoteSocketDatasource.isConnected()) {
        //yeniden bağlan
        _friendRemoteSocketDatasource.connect();
      }
      log("🔎 Arama yapılıyor: $searchQuery");
      BlocProvider.of<FriendBlock>(context).add(
          SearchFriendEvent(username: searchQuery)); // BLoC event'i dispatch et
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
            onSubmitted: (_) => _searchFriend(context),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 70,
          actions: [
            IconButton(
              onPressed: () {
                _searchFriend(context);
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
          } else if (state is FriendSearchSuccess) {
            return _buildFriendListWidget(context, state.searchResults);
          } else if (state is FriendFailure) {
            return Center(
              child: Text(state.errorMessage),
            );
          }
          return Container();
        }));
  }

  Widget _buildFriendListWidget(
      BuildContext context, List<SearchFriendEntity> searchResult) {
    log('searchResult: $searchResult');
    return ListView.builder(
        itemCount: searchResult.length,
        itemBuilder: (context, index) {
          final firend = searchResult[index];
          return Column(children: [
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage("https://via.placeholder.com/150"),
              ),
              title: Text(firend.userName),
              subtitle: Text(firend.email),
              trailing: Column(
                children: [
                  (firend.friendStatus == 'FRIEND')
                      ? Text('Arkadaş')
                      : (firend.friendStatus == 'WAITING')
                          ? Text('Beklemede')
                          : ElevatedButton(
                              onPressed: () {
                                _addFriend(context, firend.userId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Friend request sent')));
                              },
                              child: Icon(Icons.person_add)),
                ],
              ),
            ),
          ]);
        });
  }
}
