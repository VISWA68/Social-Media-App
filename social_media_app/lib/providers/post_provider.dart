import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> createPost(File imageFile, String description) async {
    final post = await uploadPost(imageFile, description);
    _posts.insert(0, post);
    _myPosts.insert(0, post);
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

    notifyListeners();

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .update({'likes': post.likes});
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
    );

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .set(post.toMap());

    return post;
  }
}
