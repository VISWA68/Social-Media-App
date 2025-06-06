import 'comment_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String description;
  final DateTime createdAt;
  final List<String> likes;
  final String username;
  final String? profileUrl;
  final List<Comment> comments;

  PostModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
    required this.likes,
    required this.username,
    this.profileUrl,
    required this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'username': username,
      'profileUrl': profileUrl,
      'comments': comments.map((comment) => comment.toMap()).toList(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      userId: map['userId'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      likes: List<String>.from(map['likes']),
      username: map['username'],
      profileUrl: map['profileUrl'],
      comments: map['comments'] != null
          ? List<Comment>.from(
              map['comments'].map((comment) => Comment.fromMap(comment)))
          : [],
    );
  }
}
