class Comment {
  final String username;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.username,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      username: map['username'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}