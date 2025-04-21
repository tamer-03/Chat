abstract class AuthSatate {}

class AuthInitial extends AuthSatate {}

class AuthLoading extends AuthSatate {}

class AuthSuccess extends AuthSatate {
  final String message;

  AuthSuccess({required this.message});
}

class AuthFailure extends AuthSatate {
  final String error;

  AuthFailure({required this.error});
}
