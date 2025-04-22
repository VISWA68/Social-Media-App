import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../service/auth_service.dart';
import 'comment_sheet.dart'; // Your previous comment sheet

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.getCurrentUserId();
    final isLiked = post.likes.contains(currentUserId);

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.profileUrl != null
                  ? NetworkImage(post.profileUrl!)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
              radius: 22,
            ),
            title: Text(
              post.username,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Text(
              _formatDate(post.createdAt),
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              post.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    context.read<PostProvider>().toggleLike(post);
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.comment_outlined,
                      color: Colors.white, size: 28),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommentSheet(post: post),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${post.likes.length} likes',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          if (post.description.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
              child: Text(
                post.description,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
