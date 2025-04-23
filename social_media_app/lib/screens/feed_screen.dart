import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isFirstLoad) {
      Provider.of<PostProvider>(context, listen: false).init();
      _isFirstLoad = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts;

    return Scaffold(
      backgroundColor: Colors.black,
      body: posts.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : ListView.builder(
              itemCount: posts.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (_, index) => PostCard(post: posts[index]),
            ),
    );
  }
}
