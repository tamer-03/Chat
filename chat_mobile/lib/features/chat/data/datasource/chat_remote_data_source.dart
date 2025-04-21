import 'dart:async';

import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/core/constant/storage_keys.dart';
import 'package:chat_android/features/chat/data/models/get_chat_model.dart';
import 'package:chat_android/features/chat/data/models/get_last_message_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:developer';

class ChatRemoteDataSource {
  static final ChatRemoteDataSource _instance =
      ChatRemoteDataSource._internal();
  factory ChatRemoteDataSource() => _instance;
  ChatRemoteDataSource._internal();
  io.Socket? _socket;
  final StreamController<GetChatModel> _messageController =
      StreamController<GetChatModel>.broadcast();

  Stream<GetChatModel> get messageStream => _messageController.stream;

  final _storage = FlutterSecureStorage();
  final _baseUrl = dotenv.env['BASE_URL'];

  Future<bool> connect() async {
    if (_socket != null && _socket!.connected) {
      log('Zaten bağlı');
      return true;
    }
    String? token = await _storage.read(key: StorageKeys.token);

    if (token == null) {
      log('bağlanilamadi');
      return false;
    }
    log(_baseUrl!);
    try {
      _socket = io.io(
          _baseUrl,
          io.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .setAuth({'token': token})
              .build());

      _socket?.connect();
      log('Socket connecting...');
      _socket?.onConnect((_) {
        log('connected');
      });

      return true;
    } catch (err) {
      log('error : $err');
      return false;
    }
  }

  Future<BaseResponseModel<GetLastMessageModel>> getAllMessage(
      String chatId) async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }
    log('datasource gets message');
    Completer<BaseResponseModel<GetLastMessageModel>> completer = Completer();
    _socket?.emit('get_chat_messages', {'chat_id': chatId});
    _socket?.on('get_chat_messages_result', (data) {
      log('data : $data');
      _socket?.off('get_chat_messages_result');
      if (data != null && data is Map<String, dynamic>) {
        final responseModel = BaseResponseModel.fromJson(
          data,
          (json) => GetLastMessageModel.fromJson(json),
        );
        log('gelen yanıt ${responseModel.data}');
        if (responseModel.status == 200) {
          completer.complete(responseModel);
        } else {
          completer.completeError(responseModel.message);
        }
      }
    });
    return completer.future;
  }

  Future<void> getLastMessage(String message, String chatId) async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }

    Completer<BaseResponseModel<GetChatModel>> completer = Completer();
    _socket?.emit('send_chat_message', {'message': message, 'chat_id': chatId});
    log('mesaj gönderme isteği yollandı');
    _socket?.on(
      'send_chat_message_result',
      (data) {
        _socket?.off('send_chat_message_result');
        if (data != null && data is Map<String, dynamic>) {
          try {
            final responseModel = BaseResponseModel.fromJson(
              data,
              (json) => (json),
            );
            log('response value: ${responseModel.data?.length}');
            if (responseModel.status == 400) {
              completer.completeError(
                  Exception('JSON Parsing Error: ${responseModel.message}'));
            }
          } catch (err) {
            log('❌ JSON dönüşüm hatası: $err');
          }
        }
      },
    );
    _listenIncomingMessage();
  }

  void _listenIncomingMessage() {
    _socket?.off('get_chat_messages_result');

    _socket?.on('get_chat_messages_result', (data) {
      //_socket?.off('get_chat_messages_result');
      if (data != null && data is Map<String, dynamic>) {
        log('data not null');
        try {
          final responseModel = BaseResponseModel.fromJson(
            data,
            (json) => GetChatModel.fromJson(json),
          );
          if (responseModel.status == 200) {
            log('gelen mesaj: ${responseModel.data?.first.message}');
            log('mdeol: $responseModel');
            final lastMessage = responseModel.data?.first;
            if (lastMessage != null) {
              _messageController.add(lastMessage);
            }
          }
        } catch (err) {
          log('❌ JSON dönüşüm hatası: $err');
        }
      } else {
        log('❌ data is null or not Map<String, dynamic>');
      }
    });
  }

  Future<void> joinChat(String chatId) async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }

    _socket?.emit('join_chat_room', {'chat_id': chatId});
    log('odaya bagalnılıyor: $chatId');
  }

  Future<BaseResponseModel<GetChatModel>> getChats() async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }
    Completer<BaseResponseModel<GetChatModel>> completer = Completer();
    _socket?.emit('get_chats', {});
    _socket?.on('get_chats_result', (data) {
      log('data $data');
      _socket?.off('get_chats_result');
      if (data != null && data is Map<String, dynamic>) {
        try {
          BaseResponseModel<GetChatModel> responseModel =
              BaseResponseModel.fromJson(
                  data, (json) => GetChatModel.fromJson(json));
          if (responseModel.status == 200) {
            completer.complete(responseModel);
            log('Get chat response: ${responseModel.data}');
          } else {
            completer.completeError(Exception(responseModel.message));
          }
        } catch (err) {
          log('❌ JSON dönüşüm hatası: $err');
          completer.completeError(Exception('JSON Parsing Error: $err'));
        }
      } else {
        log('❌ data is null or not Map<String, dynamic>');
      }
    });
    return completer.future;
  }

  Future<BaseResponseModel> createChat(int userId) async {
    log('userId: $userId');
    log('datasource çalışıyor');
    if (_socket == null || !_socket!.connected) {
      await connect();
    }
    Completer<BaseResponseModel> completer = Completer();
    _socket?.emit('create_chat', {'to_user_id': userId});
    _socket?.on('create_chat_result', (data) {
      log('data $data');
      _socket?.off('create_chat_result');
      if (data != null && data is Map<String, dynamic>) {
        try {
          BaseResponseModel responseModel =
              BaseResponseModel.fromJson(data, (json) => json);
          if (responseModel.status == 200) {
            completer.complete(responseModel);
            log('Chat olusturuldu: ${responseModel.message}');
          } else {
            completer.completeError(Exception(responseModel.message));
          }
        } catch (err) {
          log('❌ JSON dönüşüm hatası: $err');
          completer.completeError(Exception('JSON Parsing Error: $err'));
        }
      } else {
        log('❌ data is null or not Map<String, dynamic>');
      }
    });
    return completer.future;
  }
}
