class AppUser {
  final String uid;
  final String email;
  final String? username;
  final String? profileImageUrl;

  AppUser({
    required this.uid,
    required this.email,
    this.username,
    this.profileImageUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],
      profileImageUrl: map['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'profileImageUrl': profileImageUrl,
    };
  }
}
