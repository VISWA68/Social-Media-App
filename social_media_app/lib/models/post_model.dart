class PostModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String caption;
  final DateTime createdAt;
  final List<String> likes;

  PostModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    required this.likes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': createdAt,
      'likes': likes,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      userId: map['userId'],
      imageUrl: map['imageUrl'],
      caption: map['caption'],
      createdAt: map['createdAt'].toDate(),
      likes: List<String>.from(map['likes']),
    );
  }
}
