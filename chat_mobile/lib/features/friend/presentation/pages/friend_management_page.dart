import 'package:chat_android/features/friend/presentation/bloc/friend_block.dart';
import 'package:chat_android/features/friend/presentation/bloc/friend_event.dart';
import 'package:chat_android/features/friend/presentation/pages/firend_list_page.dart';
import 'package:chat_android/features/friend/presentation/pages/firend_search_page.dart';
import 'package:chat_android/features/friend/presentation/pages/friend_request_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendManagementPage extends StatefulWidget {
  const FriendManagementPage({super.key});

  @override
  State<FriendManagementPage> createState() => _FriendManagementPageState();
}

class _FriendManagementPageState extends State<FriendManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        BlocProvider.of<FriendBlock>(context).add(FriendInitialEvent());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Arkadaşlar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            backgroundColor: Colors.transparent,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: 'Arkadaşlarım',
                ),
                Tab(
                  text: 'Arkadaşlık İstekleri',
                ),
                Tab(
                  text: 'Arkadaş Ekle',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              FirendListPage(),
              FriendRequestPage(),
              FirendSearchPage(),
            ],
          ),
        ));
  }
}
