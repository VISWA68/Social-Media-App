import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/providers/auth_provider.dart';
import 'package:social_media_app/screens/create_post_screen.dart';
import 'package:social_media_app/screens/login_screen.dart';
import '../providers/post_provider.dart';
import 'feed_screen.dart';
import 'search_screen.dart';
import 'liked_screen.dart';
import 'profile_screen.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    SearchScreen(),
    SizedBox(),
    LikedScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<PostProvider>().listenToPosts();
  }

  void _onProfileLongPress() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListTile(
        leading: const Icon(Icons.logout),
        title: const Text("Logout"),
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ));
          context.read<AuthProvider>().logout();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo.jpeg',
            fit: BoxFit.cover,
          ),
        ),
        title: const Text('Velozity',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
            );
            return;
          }

          if (index == 4) {
            _onProfileLongPress();
          }

          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: ''),
          const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Likes'),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onLongPress: _onProfileLongPress,
              child: const Icon(Icons.person_outline),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
