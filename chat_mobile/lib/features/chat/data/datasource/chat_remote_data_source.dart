import 'dart:async';

import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/core/constant/message_types.dart';
import 'package:chat_android/core/constant/storage_keys.dart';
import 'package:chat_android/features/chat/data/models/get_chat_model.dart';
import 'package:chat_android/features/chat/data/models/get_last_message_model.dart';
import 'package:chat_android/features/chat/data/models/get_seem_message_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:developer';

class MessageChangeControllerModel {
  String messageId;
  String? message;
  MessageChangeControllerModel({
    required this.messageId,
    this.message,
  });
}

class ChatRemoteDataSource {
  static final ChatRemoteDataSource _instance =
      ChatRemoteDataSource._internal();
  factory ChatRemoteDataSource() => _instance;
  ChatRemoteDataSource._internal();

  io.Socket? _socket;

  final StreamController<GetLastMessageModel> _messageController =
      StreamController<GetLastMessageModel>.broadcast();
  final StreamController<List<GetSeemMessageModel>> _messageSeemController =
      StreamController<List<GetSeemMessageModel>>.broadcast();
  final StreamController<MessageChangeControllerModel>
      _messageChangeController =
      StreamController<MessageChangeControllerModel>.broadcast();

  Stream<List<GetSeemMessageModel>> get messageSeenStream =>
      _messageSeemController.stream;
  Stream<GetLastMessageModel> get messageStream => _messageController.stream;
  Stream<MessageChangeControllerModel> get messageChangeStream =>
      _messageChangeController.stream;

  final _storage = FlutterSecureStorage();
  final _baseUrl = dotenv.env['BASE_URL'];
  BaseResponseModel<GetLastMessageModel> localAllMessage =
      BaseResponseModel<GetLastMessageModel>(
          message: 'no data', status: 400, data: null);
  String _deleteChatMessageId = '';
  String _message = '';
  final List<GetSeemMessageModel> _isSeenLocal = [];

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

  Future<void> messageSeen(String chatMessageId, String chatId) async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }
    log('message seen: $chatMessageId');
    log('chatId: $chatId');

    _socket?.emit('message_seen', {
      'chat_message_id': chatMessageId,
      'chat_id': chatId,
    });
    log('message seen request sent');

    _socket?.off('messages_seemed_result');
    _socket?.on('messages_seemed_result', (data) {
      log('message seen result: $data');
      if (data != null && data is Map<String, dynamic>) {
        try {
          final responseModel = BaseResponseModel.fromJson(
            data,
            (json) => GetSeemMessageModel.fromJson(json),
          );
          if (responseModel.status == 200 && responseModel.data != null) {
            // Add new seen messages without clearing the list
            for (var message in responseModel.data!) {
              if (!_isSeenLocal
                  .any((m) => m.chatMessageId == message.chatMessageId)) {
                _isSeenLocal.add(message);
              }
            }

            // Emit updated seen messages
            _messageSeemController.add(_isSeenLocal);
            log('Updated seen messages: ${_isSeenLocal.length}');
          }
        } catch (err) {
          log('❌ JSON dönüşüm hatası message seen: $err');
        }
      }
    });
  }

  Future<BaseResponseModel<GetLastMessageModel>> getAllMessage(
      String chatId) async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }

    log('datasource gets message');
    Completer<BaseResponseModel<GetLastMessageModel>> completer = Completer();

    BaseResponseModel<GetLastMessageModel> responseModel;

    _socket?.emit('get_chat_messages', {'chat_id': chatId});

    _socket?.off('get_chat_messages_result');
    _socket?.on('get_chat_messages_result', (data) {
      log('data getAllMesage datasource : $data');

      if (data != null && data is Map<String, dynamic>) {
        responseModel = BaseResponseModel.fromJson(
          data,
          (json) => GetLastMessageModel.fromJson(json),
        );

        if (responseModel.status == 200) {
          final messages = responseModel.data;

          if (!completer.isCompleted) {
            // Store current seen messages
            final currentSeenMessages =
                List<GetSeemMessageModel>.from(_isSeenLocal);

            localAllMessage = responseModel;

            // Restore seen messages
            _isSeenLocal.clear();
            _isSeenLocal.addAll(currentSeenMessages);

            completer.complete(responseModel);
            log('localAllMessage: ${localAllMessage.data}');
            return;
          }

          log('chatMessageId: $_deleteChatMessageId');
          if (localAllMessage.data != null && messages != null) {
            log('localAllMessage: ${localAllMessage.data!.length}');
            log('messages: ${messages.length}');
            if (localAllMessage.data!.length > messages.length &&
                _deleteChatMessageId == '') {
              log('message ekelndi');
              _messageController.add(messages.first);
              localAllMessage.data!.add(messages.first);
            } else if (_deleteChatMessageId != '') {
              if (_message.isNotEmpty) {
                log('message not empty');
                MessageChangeControllerModel messageChange =
                    MessageChangeControllerModel(
                  messageId: _deleteChatMessageId,
                  message: _message,
                );
                _deleteChatMessageId = '';
                _message = '';
                _messageChangeController.add(messageChange);
              } else {
                MessageChangeControllerModel messageChange =
                    MessageChangeControllerModel(
                  messageId: _deleteChatMessageId,
                );
                _messageChangeController.add(messageChange);
                localAllMessage.data!.removeWhere(
                    (element) => element.chatMessageId == _deleteChatMessageId);
                _deleteChatMessageId = '';
                log('message silindi');
                log('chatMessageId: $_deleteChatMessageId');
              }
            }
          }
        } else {
          if (!completer.isCompleted) {
            completer.completeError(responseModel.message);
          }
        }
      }
    });

    return completer.future;
  }

  Future<void> getLastMessage(String? message, String chatId,
      String messageType, String? chatMessageId, String? chatType) async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }

    Completer<BaseResponseModel<GetChatModel>> completer = Completer();
    log(messageType);
    switch (messageType) {
      case MessageTypes.text:
        _socket?.emit('send_chat_message', {
          'message': message,
          'chat_id': chatId,
          'message_type': messageType,
          'chat_type': chatType
        });

        log('mesaj gönderme isteği yollandı');
        _socket?.once(
          'notification_channel',
          (data) {
            if (data != null && data is Map<String, dynamic>) {
              try {
                final responseModel = BaseResponseModel.fromJson(
                  data,
                  (json) => (json),
                );
                log('response value: ${responseModel.data?.length}');
                if (responseModel.status == 400) {
                  completer.completeError(Exception(
                      'JSON Parsing Error: ${responseModel.message}'));
                }
              } catch (err) {
                log('❌ JSON dönüşüm hatası: $err');
              }
            }
          },
        );
        break;
      case MessageTypes.image:
        log('image message');
        break;
      case MessageTypes.edit:
        _socket?.emit('send_chat_message', {
          'chat_id': chatId,
          'message_type': messageType,
          'chat_message_id': chatMessageId,
          'message': message,
        });

        _message = message!;
        _deleteChatMessageId = chatMessageId!;
        log('edit message');
        _getEditChatMessages();
        break;
      case MessageTypes.delete:
        _socket?.emit('send_chat_message', {
          'chat_message_id': chatMessageId,
          'chat_id': chatId,
          'message_type': messageType,
        });
        _deleteChatMessageId = chatMessageId!;
        log('localAllMessage: ${localAllMessage.data!.length}');
        _getChatMessages();
        break;
      default:
        log('unknown message type');
    }
  }

  void _getEditChatMessages() {
    Completer<BaseResponseModel> completer = Completer();
    _socket?.once('edit_chat_message_result', (data) {
      log('delete chat message result: $data');
      if (data != null && data is Map<String, dynamic>) {
        try {
          final responseModel = BaseResponseModel.fromJson(
            data,
            (json) => (json),
          );
          if (responseModel.status == 200) {
            completer.complete(responseModel);
            log('message güncellendi');
          }
        } catch (err) {
          log('❌ JSON dönüşüm hatası: $err');
        }
      }
    });
  }

  void _getChatMessages() {
    Completer<BaseResponseModel> completer = Completer();
    _socket?.once('delete_chat_message_result', (data) {
      log('delete chat message result: $data');
      if (data != null && data is Map<String, dynamic>) {
        try {
          final responseModel = BaseResponseModel.fromJson(
            data,
            (json) => (json),
          );
          if (responseModel.status == 200) {
            completer.complete(responseModel);
            log('message silindi');
          }
        } catch (err) {
          log('❌ JSON dönüşüm hatası: $err');
        }
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
    _isSeenLocal.clear();
    Completer<BaseResponseModel<GetChatModel>> completer = Completer();
    _socket?.emit('get_chats', {});
    _socket?.on('get_chats_result', (data) {
      _socket?.off('get_chats_result');
      log('data $data');
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
