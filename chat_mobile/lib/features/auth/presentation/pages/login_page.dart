import 'package:chat_android/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_android/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_android/features/auth/presentation/bloc/auth_satate.dart';
import 'package:chat_android/features/auth/presentation/widgets/auth_button.dart';
import 'package:chat_android/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:chat_android/features/auth/presentation/widgets/auth_password_input.dart';
import 'package:chat_android/features/auth/presentation/widgets/auth_promt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void _onLogin() {
    BlocProvider.of<AuthBloc>(context).add(
      LoginEvent(
          email: _emailController.text, password: _passwordController.text),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthInputField(
                  hint: 'Email',
                  controller: _emailController,
                  icon: Icons.email),
              SizedBox(
                height: 10,
              ),
              AuthPasswordInput(
                controller: _passwordController,
                icon: Icons.lock,
                isPasswordVisible: isPasswordVisible,
                hint: 'Password',
                togglePasswordVisibility: togglePasswordVisibility,
              ),
              SizedBox(
                height: 20,
              ),
              BlocConsumer<AuthBloc, AuthSatate>(builder: (context, state) {
                if (state is AuthLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return AuthButton(
                  onPressed: _onLogin,
                  text: 'Login',
                );
              }, listener: (context, state) {
                if (state is AuthSuccess) {
                  Navigator.pushNamed(context, '/home');
                } else if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                    ),
                  );
                }
              }),
              SizedBox(
                height: 20,
              ),
              AuthPromt(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  text: 'Dont you have an account?',
                  clickableText: 'Click here to register')
            ],
          ),
        ),
      ),
    );
  }
}
