abstract class ProfileEvent {}

class ProfileGetEvent extends ProfileEvent {}

class UpdateProfilEvent extends ProfileEvent {
  final String username;
  final String email;
  final String phone;

  UpdateProfilEvent({
    required this.email,
    required this.phone,
    required this.username,
  });
}
