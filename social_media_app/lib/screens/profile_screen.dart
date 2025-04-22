import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/screens/edit_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final myPosts = context.watch<PostProvider>().myPosts;

    final profileImageUrl = user?.profileImageUrl;
    final username = user?.username ?? 'No username';
    final email = user?.email ?? 'Anonymous';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  );
                },
                child: const Text("Edit Profile"),
              ),
              const SizedBox(height: 8),
              Text(
                username,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Divider(),
              // My Posts Section
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'My Posts',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              // Posts Display
              myPosts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 48.0),
                      child: Text(
                        'No posts yet!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: myPosts.length,
                      itemBuilder: (context, index) {
                        return PostCard(post: myPosts[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
