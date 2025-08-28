import 'package:dear_deer_demo/model/deardeer_profile.dart';

class DeardeerUser {
  int id;
  String? username;
  String? email;
  String? organization;
  // String? role;
  DeardeerProfile? profile;

  DeardeerUser({
    required this.id,
    required this.username,
    required this.email,
    this.organization,
    // this.role,
    this.profile,
  });

  factory DeardeerUser.fromJson(Map<String, dynamic> json) {
    DeardeerProfile? profile;
    if (json['profile'] != null) {
      profile =
          DeardeerProfile.fromJson(json['profile'] as Map<String, dynamic>);
    }

    return DeardeerUser(
      id: json['id'] as int,
      username: json['username'] as String?,
      email: json['email'] as String?,
      organization: json['organization'] as String?,
      // role: json['role'] as String?,
      profile: profile,
    );
  }
}
