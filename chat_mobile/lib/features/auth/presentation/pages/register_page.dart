import 'package:chat_android/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_android/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_android/features/auth/presentation/bloc/auth_satate.dart';
import 'package:chat_android/features/auth/presentation/widgets/auth_button.dart';
import 'package:chat_android/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:chat_android/features/auth/presentation/widgets/auth_password_input.dart';
import 'package:chat_android/features/auth/presentation/widgets/auth_promt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController1 = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isPasswordVisible1 = false;

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Parolalar eşleşmiyor.';
    }
    if (value == null || value.isEmpty) {
      return 'Parola boş bırakılamaz.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parola boş bırakılamaz.';
    }
    if (value.length < 9) {
      return 'Parola en az 9 karakter ve en az 1 tane rakam büyük küçük harf ve özel karakter içermelidir.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Parola en az bir büyük harf içermelidir.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Parola en az bir küçük harf içermelidir.';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Parola en az bir rakam içermelidir.';
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return 'Parola en az bir özel karakter içermelidir.';
    }
    return null;
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void togglePasswordVisibility1() {
    setState(() {
      isPasswordVisible1 = !isPasswordVisible1;
    });
  }

  void _onRegister() {
    print('faild');
    if (_formkey.currentState?.validate() == true) {
      print('validet');
      BlocProvider.of<AuthBloc>(context).add(
        RegisterEvent(
            username: _usernameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            password1: _passwordController1.text,
            phone: _phoneController.text),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doğru doldurun.')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _passwordController1.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthInputField(
                  hint: 'username',
                  controller: _usernameController,
                  icon: Icons.person,
                ),
                SizedBox(
                  height: 10,
                ),
                AuthInputField(
                  hint: 'Email',
                  controller: _emailController,
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta adresi zorunludur';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                AuthInputField(
                  hint: 'Phone',
                  controller: _phoneController,
                  icon: Icons.phone,
                ),
                SizedBox(
                  height: 10,
                ),
                AuthPasswordInput(
                  controller: _passwordController,
                  icon: Icons.lock,
                  isPasswordVisible: isPasswordVisible,
                  hint: 'Password',
                  togglePasswordVisibility: togglePasswordVisibility,
                  validator: _validatePassword,
                ),
                SizedBox(
                  height: 10,
                ),
                AuthPasswordInput(
                  controller: _passwordController1,
                  icon: Icons.lock,
                  isPasswordVisible: isPasswordVisible1,
                  hint: 'Password',
                  togglePasswordVisibility: togglePasswordVisibility1,
                  validator: _validateConfirmPassword,
                ),
                SizedBox(
                  height: 10,
                ),
                BlocConsumer<AuthBloc, AuthSatate>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return AuthButton(onPressed: _onRegister, text: 'Register');
                  },
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushReplacementNamed(context, '/login');
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                AuthPromt(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  text: 'Already have an account?',
                  clickableText: 'Click here to login',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
