import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../service/auth_service.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.getCurrentUserId();
    final isLiked = post.likes.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: post.profileUrl != null
                    ? NetworkImage(post.profileUrl!)
                    : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
              ),
              const SizedBox(width: 8),
              Text(post.username),
            ],
          ),

          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/default_avatar.png'),
            ),
            subtitle: Text(
              _formatDate(post.createdAt),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.more_vert),
          ),

          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
            child: Image.network(
              post.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),

          // Like & Comment Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: () {
                    context.read<PostProvider>().toggleLike(post);
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    // Navigate to comments
                  },
                ),
              ],
            ),
          ),

          // Caption
          if (post.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                post.description,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
