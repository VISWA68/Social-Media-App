import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/providers/auth_provider.dart';
import 'package:social_media_app/screens/create_post_screen.dart';
import 'package:social_media_app/screens/login_screen.dart';
import '../providers/post_provider.dart';
import 'feed_screen.dart';
import 'other_user/search_screen.dart';
import 'liked_screen.dart';
import 'profile_screen.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    UserSearchScreen(),
    const SizedBox(),
    const LikedScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<PostProvider>().listenToPosts();
    Future.microtask(() {
    Provider.of<PostProvider>(context, listen: false).init();
  });
  }

  void _onProfileLongPress() {
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

  DateTime? _lastBackPressed;

  Future<bool> _handleBackPress() async {
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back button again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldExit = await _handleBackPress();
          if (shouldExit) {
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else {
              exit(0);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
          title: const Text('Velozity',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 220, 208, 208))),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.message_outlined,
                color: Color.fromARGB(255, 220, 208, 208),
              ),
              onPressed: () {},
            )
          ],
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey[900],
          currentIndex: _currentIndex,
          selectedItemColor: Color.fromARGB(255, 219, 202, 202),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
              color: Color.fromARGB(255, 219, 202, 202),
              fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          selectedIconTheme: const IconThemeData(
              color: Color.fromARGB(255, 219, 202, 202), size: 28),
          unselectedIconTheme:
              const IconThemeData(color: Colors.grey, size: 24),
          type: BottomNavigationBarType.fixed,
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
            const BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.search), label: 'Search'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined), label: 'Create'),
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
      ),
    );
  }
}
