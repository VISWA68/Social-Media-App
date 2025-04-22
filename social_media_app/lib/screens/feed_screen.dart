import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts;

    return Scaffold(
      backgroundColor: Colors.black,
      body: posts.isEmpty
          ? const Center(
              child: Text(
                "No posts yet",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: posts.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (_, index) => PostCard(post: posts[index]),
            ),
    );
  }
}
