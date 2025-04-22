class UserModel {
  final String id;
  final String username;
  final String profileUrl;
  final String email;
  final String bio;
  final List<String> followers;
  final List<String> following;

  UserModel({
    required this.id,
    required this.username,
    required this.profileUrl,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      profileUrl: map['profileUrl'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'profileUrl': profileUrl,
      'email': email,
      'bio': bio,
      'followers': followers,
      'following': following,
    };
  }
}