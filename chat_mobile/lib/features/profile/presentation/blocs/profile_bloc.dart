import 'dart:developer';

import 'package:chat_android/features/profile/domain/usecasses/get_profile_usecasse.dart';
import 'package:chat_android/features/profile/domain/usecasses/update_profile_usecase.dart';
import 'package:chat_android/features/profile/presentation/blocs/profile_event.dart';
import 'package:chat_android/features/profile/presentation/blocs/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecasse getProfileUsecasses;
  final UpdateProfileUsecase updateProfileUsecase;
  ProfileBloc(
      {required this.getProfileUsecasses, required this.updateProfileUsecase})
      : super(ProfileInitial()) {
    on<ProfileGetEvent>(_onGetProfile);
    on<UpdateProfilEvent>(_onUpdateProfile);
  }
  Future<void> _onUpdateProfile(
      UpdateProfilEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      log('username: ${event.username}');
      final response = await updateProfileUsecase.call(
          event.username, event.email, event.phone);
      log('blocdaki response : ${response.toString()}');
      if (response.status == 200) {
        emit(ProfileSucces(message: response.message));
        log('profile updated');
      }
    } catch (err) {
      emit(ProfileFailure(errorMessage: err.toString()));
    }
  }

  Future<void> _onGetProfile(
      ProfileGetEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await getProfileUsecasses.call();
      if (response.status == 200) {
        emit(ProfileLoaded(
          message: response.message,
          userId: response.data!.first.userId,
          username: response.data!.first.username,
          email: response.data!.first.email,
          phone: response.data!.first.phone,
        ));
      } else {
        emit(ProfileFailure(errorMessage: response.message));
      }
    } catch (err) {
      throw Exception('Profile get profile failed in repository: $err');
    }
  }
}
