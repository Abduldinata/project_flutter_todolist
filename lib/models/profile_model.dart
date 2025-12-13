class Profile {
  final String id;
  final String username;
  final String? email;
  final String? hobby;
  final String? avatarUrl;
  final DateTime? updatedAt;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? phone;

  Profile({
    required this.id,
    required this.username,
    this.email,
    this.hobby,
    this.avatarUrl,
    this.updatedAt,
    this.bio,
    this.dateOfBirth,
    this.phone,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      hobby: json['hobby'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      bio: json['bio'] ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'hobby': hobby,
      'avatar_url': avatarUrl,
      'updated_at': updatedAt?.toIso8601String(),
      'bio': bio,
      'date_of_birth': dateOfBirth?.toIso8601String().split(
        'T',
      )[0], // Format: YYYY-MM-DD
      'phone': phone,
    };
  }
}
