class User {
  final String id;
  final String email;
  final String userType;
  final Profile? profile;

  User({
    required this.id,
    required this.email,
    required this.userType,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      userType: json['userType'] ?? '',
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
    );
  }
}

class Profile {
  final String? firstName;
  final String? lastName;
  final String? company;
  final String? phone;

  Profile({
    this.firstName,
    this.lastName,
    this.company,
    this.phone,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      firstName: json['firstName'],
      lastName: json['lastName'],
      company: json['company'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'company': company,
      'phone': phone,
    };
  }
}
