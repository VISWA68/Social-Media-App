import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/comment_model.dart';
import '../models/post_model.dart';
import '../service/auth_service.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<PostModel> _posts = [];
  final List<PostModel> _myPosts = [];

  List<PostModel> get posts => _posts;
  List<PostModel> get myPosts => _myPosts;

  final List<PostModel> _likedPosts = [];
  List<PostModel> get likedPosts => _likedPosts;

  bool _hasInitialized = false;

  void init() {
    if (_hasInitialized) return;
    _hasInitialized = true;
    listenToPosts();
  }

  void listenToPosts() {
    _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final allPosts =
          snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList();

      _posts
        ..clear()
        ..addAll(allPosts);

      final currentUserId = AuthService.getCurrentUserId();
      _myPosts
        ..clear()
        ..addAll(allPosts.where((post) => post.userId == currentUserId));

      notifyListeners();
    });
  }

  Future<void> fetchLikedPosts() async {
    try {
      final userId = AuthService.getCurrentUserId();
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('posts')
          .where('likes', arrayContains: userId)
          .get();

      _likedPosts.clear();

      final posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data()))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _likedPosts.addAll(posts);
      notifyListeners();
    } catch (e) {
      print('Error fetching liked posts: $e');
    }
  }

  Future<void> fetchMyPosts(String userId) async {
    final snapshot = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    _myPosts.clear();
    _myPosts.addAll(
        snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());

    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      myPosts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } catch (e) {
      print('Failed to delete post: $e');
    }
  }

  Future<void> createPost(File imageFile, String description) async {
    await uploadPost(imageFile, description);
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

    notifyListeners();

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .update({'likes': post.likes});
  }

  Future<void> addComment(PostModel post, String commentText) async {
    final currentUserId = AuthService.getCurrentUserId();

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    final username = userDoc['username'];

    final comment = Comment(
      username: username,
      text: commentText,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('posts').doc(post.id).update({
      'comments': FieldValue.arrayUnion([comment.toMap()]),
    });

    post.comments.add(comment);
    notifyListeners();
  }

  Future<PostModel> uploadPost(File imageFile, String description) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child('${DateTime.now().millisecondsSinceEpoch}_${user.uid}.jpg');

    final uploadTask = await storageRef.putFile(imageFile);
    final downloadUrl = await storageRef.getDownloadURL();
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final username = userDoc['username'];
    final profileUrl = userDoc['profileUrl'];

    final postId = FirebaseFirestore.instance.collection('posts').doc().id;
    final post = PostModel(
      id: postId,
      userId: user.uid,
      imageUrl: downloadUrl,
      description: description,
      createdAt: DateTime.now(),
      likes: [],
      username: username,
      profileUrl: profileUrl,
      comments: [],
    );

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .set(post.toMap());

    return post;
  }
}
