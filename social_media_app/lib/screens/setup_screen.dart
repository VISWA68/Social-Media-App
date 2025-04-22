import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/screens/home_screen.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  File? _profileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() => _profileImage = File(pickedFile.path));
                }
              },
              child: CircleAvatar(
                radius: 40,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null ? const Icon(Icons.add_a_photo) : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                String? profileUrl;
                if (_profileImage != null) {
                  final ref = FirebaseStorage.instance
                      .ref()
                      .child('profile_pics/${user!.uid}.jpg');
                  await ref.putFile(_profileImage!);
                  profileUrl = await ref.getDownloadURL();
                }

                await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
                  'username': _usernameController.text,
                  'profileUrl': profileUrl,
                  'email': user.email,
                  'uid': user.uid,
                });

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeWrapper()),
                );
              },
              child: const Text('Continue'),
            )
          ],
        ),
      ),
    );
  }
}
