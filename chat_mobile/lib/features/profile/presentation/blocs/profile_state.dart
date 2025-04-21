abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String message;
  final int userId;
  final String username;
  final String email;
  final String phone;

  ProfileLoaded({
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    required this.message,
  });
}

class ProfileSucces extends ProfileState {
  final String message;

  ProfileSucces({required this.message});
}

class ProfileFailure extends ProfileState {
  final String errorMessage;

  ProfileFailure({required this.errorMessage});
}
