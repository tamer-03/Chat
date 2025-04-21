import 'dart:convert';
import 'dart:developer';
import 'package:chat_android/core/base_response.dart';
import 'package:chat_android/features/auth/data/models/token_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl = '${dotenv.env['BASE_URL']}/api/v1/auth';

  Future<BaseResponseModel<TokenModel>> login(
      {required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sign-in'),
      body: jsonEncode(
        {'email': email, 'password': password},
      ),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'MyApp-Mobile'
      },
    );

    return BaseResponseModel.fromJson(
        jsonDecode(response.body), (data) => TokenModel.fromJson(data));
  }

  Future<BaseResponseModel<TokenModel>> register(
      {required String username,
      required String email,
      required String password,
      required String password1,
      required String phone}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sign-up'),
      body: jsonEncode(
        {
          'username': username,
          'email': email,
          'password': password,
          'passwordAgain': password1,
          'phone': phone
        },
      ),
      headers: {'Content-Type': 'application/json'},
    );

    log(response.body);
    return BaseResponseModel.fromJson(
        jsonDecode(response.body), (data) => TokenModel.fromJson(data));
  }
}
