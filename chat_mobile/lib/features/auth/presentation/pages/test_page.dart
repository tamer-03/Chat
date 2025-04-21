import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _storage = FlutterSecureStorage();
  String? token;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
              onPressed: () async {
                token = await _storage.read(key: 'token');
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(token ?? 'no token')));
              },
              child: Text('Clikc'))),
    );
  }
}
