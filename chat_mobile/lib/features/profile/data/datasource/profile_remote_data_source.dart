import 'dart:convert';

import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/core/constant/storage_keys.dart';
import 'package:chat_android/features/profile/data/models/profile_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class ProfileRemoteDataSource {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/v1/profile';
  final _storage = FlutterSecureStorage();

  Future<BaseResponseModel> updateProfile(
      {required String username,
      required String email,
      required String phone}) async {
    log('name: $username, email: $email, phone: $phone');
    String? token = await _storage.read(key: StorageKeys.token);
    log('token : $token');
    final response = await http.put(Uri.parse('$baseUrl/update'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'MyApp-Mobile',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'username': username,
            'email': email,
            'phone': phone,
          },
        ));
    log('profile update request sended');
    final responeModel =
        BaseResponseModel.fromJson(jsonDecode(response.body), (data) => data);
    log('profiledatasource basresponsemodel: ${responeModel.toString()}');
    return responeModel;
  }

  Future<BaseResponseModel<ProfileModel>> getProfile() async {
    String? token = await _storage.read(key: StorageKeys.token);
    final response = await http.get(
      Uri.parse('$baseUrl/get'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'MyApp-Mobile',
        'Authorization': 'Bearer $token',
      },
    );
    log('profiledatasource response: ${response.body}');

    final baseResponseModel = BaseResponseModel.fromJson(
        jsonDecode(response.body), (data) => ProfileModel.fromJson(data));
    log('profiledatasource basresponsemodel: ${baseResponseModel.toString()}');
    return baseResponseModel;
  }
}
