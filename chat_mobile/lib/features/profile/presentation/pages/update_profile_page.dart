import 'package:chat_android/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:chat_android/features/profile/presentation/blocs/profile_event.dart';
import 'package:chat_android/features/profile/presentation/blocs/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _getProfille();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getProfille();
  }

  void _updateProfile() {
    log('updage fonksiyon çağrıldı');
    log('emailcontroller ${emailController.text}');
    BlocProvider.of<ProfileBloc>(context).add(
      UpdateProfilEvent(
          email: emailController.text,
          phone: phoneController.text,
          username: usernameController.text),
    );
  }

  void _getProfille() {
    BlocProvider.of<ProfileBloc>(context).add(ProfileGetEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
            if (state is ProfileLoading) {
              return const CircularProgressIndicator();
            } else if (state is ProfileLoaded) {
              usernameController.text = state.username;
              emailController.text = state.email;
              phoneController.text = state.phone;
            }
            return Container();
          }),
          _buildTextField(usernameController.text, usernameController),
          _buildTextField(emailController.text, emailController),
          _buildTextField(phoneController.text, phoneController),
          _updateButton()
        ],
      ),
    );
  }

  Widget _updateButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const CircularProgressIndicator();
          } else if (state is ProfileLoaded) {
            return ElevatedButton(
              onPressed: () {
                _updateProfile();
              },
              child: Text('Update'),
            );
          } else if (state is ProfileSucces) {
            _getProfille();
          }
          return Container();
        },
        listener: (context, state) {
          if (state is ProfileSucces) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Profil güncellendi')));
          }
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
