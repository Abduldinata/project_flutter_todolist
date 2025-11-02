class Profile {
  final String id;
  final String username;
  final String? email;
  final String? hobby;
  final String? avatarUrl;
  final DateTime? updatedAt;
  final String? bio;

  Profile({
    required this.id,
    required this.username,
    this.email,
    this.hobby,
    this.avatarUrl,
    this.updatedAt,
    this.bio,
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
    };
  }
}
