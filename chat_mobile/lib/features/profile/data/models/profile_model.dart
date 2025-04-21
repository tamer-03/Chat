import 'package:chat_android/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.userId,
    required super.username,
    required super.email,
    required super.phone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
