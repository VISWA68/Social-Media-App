import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/screens/other_user/user_model.dart';
// Import the screens if needed later
// import 'package:social_media_app/screens/other_user/followers_list_screen.dart';
// import 'package:social_media_app/screens/other_user/following_list_screen.dart';
// import 'package:social_media_app/screens/other_user/user_posts_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  UserProfileScreen({
    Key? key,
    required this.userId,
  })  : assert(userId.isNotEmpty),
        super(key: key);

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
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (!doc.exists) {
      throw Exception('User not found');
    }

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return UserModel.fromMap(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (_) => UserPostsScreen(userId: widget.userId),
              // ));
            },
          ),
        ],
      ),
      body: FutureBuilder<UserModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.profileUrl.isNotEmpty
                      ? NetworkImage(user.profileUrl)
                      : null,
                  child: user.profileUrl.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(user.bio.isNotEmpty ? user.bio : 'No bio yet'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(
                        //   builder: (_) => FollowersListScreen(followerIds: user.followers),
                        // ));
                      },
                      child: Column(
                        children: [
                          Text(
                            user.followers.length.toString(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Text('Followers'),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(
                        //   builder: (_) => FollowingListScreen(followingIds: user.following),
                        // ));
                      },
                      child: Column(
                        children: [
                          Text(
                            user.following.length.toString(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Text('Following'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('View Posts'),
                  onPressed: () {
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (_) => UserPostsScreen(userId: widget.userId),
                    // ));
                  },
                ),
                const SizedBox(height: 20),
                // Tab Navigation
                DefaultTabController(
                  length: 2, // Two tabs: Info and Posts
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: "Info"),
                          Tab(text: "Posts"),
                        ],
                      ),
                      Container(
                        height: 400, // Height for the tab content
                        child: TabBarView(
                          children: [
                            // Info Tab
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Username: ${user.username}"),
                                  const SizedBox(height: 8),
                                  Text(
                                      "Bio: ${user.bio.isNotEmpty ? user.bio : 'No bio available.'}"),
                                  const SizedBox(height: 8),
                                  Text("Followers: ${user.followers.length}"),
                                  const SizedBox(height: 8),
                                  Text("Following: ${user.following.length}"),
                                ],
                              ),
                            ),
                            // Posts Tab (Placeholder, add your posts logic here)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text("User's posts will appear here."),
                                  // Future builder or list view for posts here
                                ],
                              ),
                            ),
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
}
