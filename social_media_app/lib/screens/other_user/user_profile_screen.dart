import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  }

  Future<UserModel> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
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
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)),
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
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
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
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
                  label: const Text('View Posts', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 20),
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
        Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
          Text("Username: ${user.username}", style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text("Bio: ${user.bio.isNotEmpty ? user.bio : 'No bio available.'}", style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text("Followers: ${user.followers.length}", style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text("Following: ${user.following.length}", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return const Center(
      child: Text("User's posts will appear here.", style: TextStyle(color: Colors.white70)),
    );
  }
}
