import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/screens/other_user/user_model.dart';

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
                  backgroundImage: NetworkImage(user.profileUrl),
                  onBackgroundImageError: (_, __) {
                    // Handle error loading image
                  },
                  child:
                      user.profileUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(user.bio),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          user.followers.length.toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text('Followers'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          user.following.length.toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text('Following'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
