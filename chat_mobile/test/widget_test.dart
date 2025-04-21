// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:chat_android/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:chat_android/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chat_android/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:chat_android/features/chat/data/repository/chat_repository_imp.dart';
import 'package:chat_android/features/chat/domain/repository/chat_repository.dart';
import 'package:chat_android/features/friend/data/datasource/friend_remote_socket_datasource.dart';
import 'package:chat_android/features/friend/data/repositories/friend_repository_imp.dart';
import 'package:chat_android/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:chat_android/features/profile/data/repository/profile_repository_imp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chat_android/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final authRepository =
        AuthRepositoryImpl(authRemoteDataSource: AuthRemoteDataSource());
    final friendRepository =
        FriendRepositoryImp(FriendRemoteSocketDatasource());
    final profileRepository = ProfileRepositoryImp(
        profileRemoteDataSource: ProfileRemoteDataSource());
    final chatRepository =
        ChatRepositoryImp(chatRemoteDataSource: ChatRemoteDataSource());
    await tester.pumpWidget(MyApp(
      authRepository: authRepository,
      friendRepository: friendRepository,
      profileRepository: profileRepository,
      chatRepository: chatRepository,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
