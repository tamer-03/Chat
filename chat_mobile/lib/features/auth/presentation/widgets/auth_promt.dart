import 'package:flutter/material.dart';

class AuthPromt extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final String clickableText;
  const AuthPromt(
      {super.key,
      required this.onTap,
      required this.text,
      required this.clickableText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            text: text,
            style: TextStyle(color: Colors.grey),
            children: [
              TextSpan(
                text: clickableText,
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
