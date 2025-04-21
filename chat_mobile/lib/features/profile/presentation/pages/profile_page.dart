import 'package:chat_android/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:chat_android/features/profile/presentation/blocs/profile_event.dart';
import 'package:chat_android/features/profile/presentation/blocs/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    _getProfile();
    super.initState();
  }

  void _getProfile() {
    BlocProvider.of<ProfileBloc>(context).add(ProfileGetEvent());
  }

  @override
  void didChangeDependencies() {
    log('didchange called');
    super.didChangeDependencies();
    _getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 36, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage("https://via.placeholder.com/150"),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                    if (state is ProfileLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is ProfileLoaded) {
                      return Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.username),
                          Text(state.email),
                          Text(state.phone),
                        ],
                      );
                    } else if (state is ProfileFailure) {
                      return Text(state.errorMessage);
                    }
                    return Container();
                  }),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/updateProfile');
                      },
                      child: Text('Update Profile'))
                ],
              )
            ],
          ),
        ));
  }
}
