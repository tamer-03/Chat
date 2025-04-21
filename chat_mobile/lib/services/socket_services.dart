import 'dart:developer';

import 'package:chat_android/core/constant/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketServices {
  late io.Socket socket;
  final _storage = FlutterSecureStorage();

  Future<void> connect() async {
    String? token = await _storage.read(key: StorageKeys.token);
    log('connect started');
    if (token == null) {
      log('bağlanilamadi');
      return;
    }
    log('token not null');

    try {
      socket = io.io(
          'http://192.168.1.105:8080',
          io.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .setAuth({'token': token})
              .build());
      log('socekt is come');
    } catch (err) {
      log('error : $err');
    }

    log(socket.toString());
    socket.connect();
    log('Socket connected: ${socket.connected}');

    socket.onConnect((_) {
      log('connected');

      getFriend();
    });

    socket.on('get_friends_result', (data) {
      log('arkadaşlık isteği $data');
    });

    socket.onDisconnect((_) {
      log('disconnected');
    });

    socket.onError((data) {
      log('Hata: $data');
    });
  }

  void getFriend() {
    log('🔄 get_friends eventi gönderildi.');
    socket.emit('get_friends', {});
  }

  void disconnect() {
    socket.disconnect();
  }
}
