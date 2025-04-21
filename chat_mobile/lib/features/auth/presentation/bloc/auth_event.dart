abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String password1;
  final String phone;

  RegisterEvent(
      {required this.username,
      required this.email,
      required this.password,
      required this.password1,
      required this.phone});
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({
    required this.email,
    required this.password,
  });
}
