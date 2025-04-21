import 'package:chat_android/core/theme.dart';
import 'package:flutter/material.dart';

class AuthPasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final bool isPasswordVisible;
  final String hint;
  final VoidCallback togglePasswordVisibility;
  final String? Function(String?)? validator;
  const AuthPasswordInput({
    super.key,
    required this.controller,
    required this.icon,
    required this.isPasswordVisible,
    required this.hint,
    required this.togglePasswordVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.sentMessageInput, // Background color
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: !isPasswordVisible, // Şifreyi gizle/göster
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
              validator: validator, // Şifre doğrulaması
            ),
          ),
          GestureDetector(
            onTap: togglePasswordVisibility,
            child: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
