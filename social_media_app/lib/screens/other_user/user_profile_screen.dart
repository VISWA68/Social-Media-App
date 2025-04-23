import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/screens/other_user/user_model.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
    _loadUserPosts();
  }

  List<PostModel> _userPosts = [];
  bool _isLoadingPosts = true;

  Future<void> _loadUserPosts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _userPosts =
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList();
        _isLoadingPosts = false;
      });
    } catch (e) {
      print("Error loading user posts: $e");
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  Future<UserModel> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    Map<String, dynamic> data = doc.data()!;
    data['id'] = doc.id;
    return UserModel.fromMap(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<UserModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70)),
            );
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.blueAccent,
                  backgroundImage: user.profileUrl.isNotEmpty
                      ? NetworkImage(user.profileUrl)
                      : null,
                  child: user.profileUrl.isEmpty
                      ? const Icon(Icons.person, size: 55, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(user.username,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(user.bio.isNotEmpty ? user.bio : "No bio yet",
                    style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat(context, 'Followers', user.followers.length),
                    _buildStat(context, 'Following', user.following.length),
                  ],
                ),
                const SizedBox(height: 30),
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blueAccent,
                        tabs: const [
                          Tab(text: "Info"),
                          Tab(text: "Posts"),
                        ],
                      ),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            _buildInfoTab(user),
                            _buildPostsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, int count) {
    return Column(
      children: [
        Text('$count',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildInfoTab(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Username: ${user.username}",
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text("Bio: ${user.bio.isNotEmpty ? user.bio : 'No bio available.'}",
              style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text("Followers: ${user.followers.length}",
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text("Following: ${user.following.length}",
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_isLoadingPosts) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent));
    }

    if (_userPosts.isEmpty) {
      return const Center(
        child: Text("No posts yet", style: TextStyle(color: Colors.white70)),
      );
    }

    return GridView.builder(
      itemCount: _userPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return GestureDetector(
          onTap: () {},
          child: Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                  child: CircularProgressIndicator(color: Colors.grey));
            },
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }
}
