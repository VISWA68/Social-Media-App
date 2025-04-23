import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import 'edit_profile.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final myPosts = context.watch<PostProvider>().myPosts;

    final profileImageUrl = user?.profileImageUrl;
    final username = user?.username ?? 'No username';
    final email = user?.email ?? 'Anonymous';

    void _onLogOut() {
      showModalBottomSheet(
        backgroundColor: Colors.grey[900],
        context: context,
        builder: (_) => ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text("Logout", style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ));
            context.read<AuthProvider>().logout();
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _onLogOut),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blueAccent,
              backgroundImage:
                  profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(profileImageUrl)
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(username,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(email, style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Edit Profile',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.grey),
            const Align(
              alignment: Alignment.center,
              child: Text('My Posts',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
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
                      return PostCard(
                        post: myPosts[index],
                        isMyPost: true,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
