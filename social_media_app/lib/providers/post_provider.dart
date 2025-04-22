import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';
import '../service/auth_service.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<PostModel> _posts = [];
  final List<PostModel> _myPosts = [];

  List<PostModel> get posts => _posts;
  List<PostModel> get myPosts => _myPosts;

  void listenToPosts() {
    _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final allPosts =
          snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList();

      _posts.clear();
      _posts.addAll(allPosts);

      final currentUserId = AuthService.getCurrentUserId();
      _myPosts.clear();
      _myPosts.addAll(allPosts.where((post) => post.userId == currentUserId));

      notifyListeners();
    });
  }

  Future<void> createPost(File imageFile, String description) async {
    final currentUserId = AuthService.getCurrentUserId();
    final postId = const Uuid().v4();
    final imageUrl = await _uploadImage(imageFile, postId);

    final newPost = PostModel(
      id: postId,
      userId: currentUserId,
      imageUrl: imageUrl,
      description: description,
      createdAt: DateTime.now(),
      likes: [],
    );

    await _firestore.collection('posts').doc(postId).set(newPost.toMap());

    _posts.insert(0, newPost);
    _myPosts.insert(0, newPost);
    notifyListeners();
  }

  Future<String> _uploadImage(File imageFile, String postId) async {
    final ref = _storage.ref().child('post_images').child('$postId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> toggleLike(PostModel post) async {
    final userId = AuthService.getCurrentUserId();
    final isLiked = post.likes.contains(userId);

    if (isLiked) {
      post.likes.remove(userId);
    } else {
      post.likes.add(userId);
    }

    notifyListeners(); // Update UI immediately

    // Update in Firestore
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .update({'likes': post.likes});
  }
}
