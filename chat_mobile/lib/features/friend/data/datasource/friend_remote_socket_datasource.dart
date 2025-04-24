import 'dart:async';

import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/core/constant/storage_keys.dart';
import 'package:chat_android/features/friend/data/models/friend_request_model.dart';
import 'package:chat_android/features/friend/data/models/get_friends_model.dart';
import 'package:chat_android/features/friend/data/models/search_friend_models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:developer';

class FriendRemoteSocketDatasource {
  static final FriendRemoteSocketDatasource _instance =
      FriendRemoteSocketDatasource._internal();

  factory FriendRemoteSocketDatasource() => _instance;
  FriendRemoteSocketDatasource._internal();
  io.Socket? _socket;
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
    log('token $token');
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

  bool isConnected() {
    return _socket != null && _socket!.connected;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  Future<BaseResponseModel<GetFriendsModel>> getFriends() async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }
    Completer<BaseResponseModel<GetFriendsModel>> completer = Completer();
    _socket?.emit('get_friends');
    _socket?.on('get_friends_result', (data) {
      _socket?.off('get_friends_result');
      if (data != null && data is Map<String, dynamic>) {
        try {
          BaseResponseModel<GetFriendsModel> responseModel =
              BaseResponseModel.fromJson(
            data,
            (json) => GetFriendsModel.fromJson(json),
          );
          if (responseModel.status == 200) {
            log('👫 Arkadaşlar listelendi datasource ${responseModel.message}');
            for (var model in responseModel.data!) {
              log('👫 Arkadaşlar listelendi datasource ${model.username}');
            }
            log('👫 Arkadaşlar verisi datasource ${responseModel.data}');
            completer.complete(responseModel);
          } else {
            completer.completeError(Exception(responseModel.message));
          }
        } catch (err) {
          log('❌ JSON dönüşüm hatası: $err');
          completer.completeError(Exception('JSON Parsing Error: $err'));
        }
      }
    });
    return completer.future;
  }

  Future<BaseResponseModel> updateFriendRequest(
      int senderId, String status) async {
    if (_socket == null || !_socket!.connected) {
      await connect();
    }
    log('updateFriendRequest called with senderId: $senderId, status: $status');
    Completer<BaseResponseModel> completer = Completer();
    _socket?.emit('update_friend_request', {
      'sender_id': senderId,
      'status': status,
      'friend_status_type': status
    });
    _socket?.on('update_friend_request_result', (data) {
      _socket?.off('update_friend_request_result');
      if (data != null && data is Map<String, dynamic>) {
        log('update_friend_request_result event received: $data');
        try {
          BaseResponseModel responseModel = BaseResponseModel.fromJson(
            data,
            (json) => (json),
          );
          if (responseModel.status == 200) {
            log('👫 Arkadaşlık isteği güncellendi: ${responseModel.message}');
            completer.complete(responseModel);
          } else {
            completer.completeError(Exception(responseModel.message));
          }
        } catch (err) {
          log('❌ JSON dönüşüm hatası: $err');
          completer.completeError(Exception('JSON Parsing Error: $err'));
        }
      }
    });

    return completer.future;
  }

  Future<BaseResponseModel<FriendRequestModel>> getFriendRequest() async {
    if (_socket == null || !_socket!.connected) {
      //yeniden baglaniliyor
      await connect();
    }
    Completer<BaseResponseModel<FriendRequestModel>> completer = Completer();
    _socket?.emit('get_friend_requests');

    _socket?.on('get_friend_requests_result', (data) {
      _socket?.off('get_friend_requests_result');
      if (data != null && data is Map<String, dynamic>) {
        try {
          log(data.toString());
          BaseResponseModel<FriendRequestModel> responseModel =
              BaseResponseModel.fromJson(
                  data, (json) => FriendRequestModel.fromJson(json));
          if (responseModel.status == 200) {
            log('responsemodel ${responseModel.data}');
            completer.complete(responseModel);
          } else {
            completer.completeError(Exception(responseModel.message));
          }
        } catch (err) {
          log('❌ JSON dönüşüm hatası: $err');
          completer.completeError(Exception('JSON Parsing Error: $err'));
        }
      } else {
        completer
            .completeError(Exception('Search failed with no response data'));
      }
    });

    log('👫 Arkadaşlık istekleri alınıyor... getfirendRequest complater');
    return completer.future;
  }

  Future<BaseResponseModel> addFriend(int receiverId) async {
    if (_socket == null || !_socket!.connected) {
      //yeniden baglaniliyor
      await connect();
    }
    Completer<BaseResponseModel> completer = Completer();
    _socket?.emit('friend_request', {'receiver_id': receiverId});

    log('👫 Arkadaşlık isteği gönderildi: $receiverId');

    _socket?.once('friend_request_result', (data) {
      _socket?.off('search_friend_result');
      if (data != null && data is Map<String, dynamic>) {
        try {
          BaseResponseModel responseModel =
              BaseResponseModel.fromJson(data, (json) => json);
          if (responseModel.status == 200) {
            completer.complete(responseModel);
          } else {
            completer.completeError(Exception(responseModel.message));
          }
        } catch (err) {
          log('❌ JSON dönüşüm hatası: $err');
          completer.completeError(Exception('JSON Parsing Error: $err'));
        }
      } else {
        completer
            .completeError(Exception('Search failed with no response data'));
      }
    });

    return completer.future;
  }

  Future<BaseResponseModel<SearchFriendModels>> searchFriend(
      String username) async {
    log('searchFriend called with username repositoryIpl: $username');
    if (_socket == null || !_socket!.connected) {
      log("⚠️ Socket bağlı değil, yeniden bağlanılıyor...");
      await connect(); // Eğer socket bağlı değilse önce bağlan
    }

    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    Completer<BaseResponseModel<SearchFriendModels>> completer = Completer();

    _socket?.emit('search_user', {'username': username});

    _socket?.on('search_user_result', (data) {
      _socket?.off('search_user_result');
      log('search_user_result event received in datasource: $data');

      if (data != null && data is Map<String, dynamic>) {
        try {
          log('data null ve map olmalı');
          // Status ve message kontrolü BaseResponseModel içinde yapılır
          BaseResponseModel<SearchFriendModels> response =
              BaseResponseModel.fromJson(
                  data, (json) => SearchFriendModels.fromJson(json));
          log(response.data.toString());
          if (response.status == 200) {
            completer.complete(
                response); // Başarılı sonuç olarak BaseResponseModel dön
          } else {
            completer.completeError(Exception(
                response.message)); // Hata mesajını exception olarak fırlat
          }
        } catch (e, stackTrace) {
          log('❌ JSON dönüşüm hatası: $e');
          log('📌 Stack Trace: $stackTrace');
          completer.completeError(Exception('JSON Parsing Error: $e'));
        }
      } else {
        completer
            .completeError(Exception('Search failed with no response data'));
      }
    });

    return completer.future; // Completer.future'ı dön
  }
}
