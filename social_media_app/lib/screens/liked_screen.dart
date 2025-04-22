import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../models/post_model.dart';

class LikedScreen extends StatefulWidget {
  const LikedScreen({super.key});

  @override
  State<LikedScreen> createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikedScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<PostProvider>().fetchLikedPosts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Posts'),
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          final likedPosts = postProvider.likedPosts;

          if (likedPosts.isEmpty) {
            return const Center(
              child: Text('No liked posts yet'),
            );
          }

          return ListView.builder(
            itemCount: likedPosts.length,
            itemBuilder: (context, index) {
              final post = likedPosts[index];
              return PostCard(post: post);
            },
          );
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.profileUrl!),
            ),
            title: Text(post.username),
            subtitle: Text(post.description),
          ),
          Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                Text('${post.likes.length} likes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
