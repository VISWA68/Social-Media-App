import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  File? _newProfilePic;
  String? currentProfileUrl;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((doc) {
      _usernameController.text = doc['username'];
      currentProfileUrl = doc['profileUrl'];
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() => _newProfilePic = File(pickedFile.path));
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _newProfilePic != null
                    ? FileImage(_newProfilePic!)
                    : currentProfileUrl != null
                        ? NetworkImage(currentProfileUrl!) as ImageProvider
                        : null,
                child: _newProfilePic == null && currentProfileUrl == null
                    ? const Icon(Icons.person)
                    : null,
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
                final user = FirebaseAuth.instance.currentUser!;
                String? updatedUrl = currentProfileUrl;

                if (_newProfilePic != null) {
                  final ref = FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');
                  await ref.putFile(_newProfilePic!);
                  updatedUrl = await ref.getDownloadURL();
                }

                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                  'username': _usernameController.text,
                  'profileUrl': updatedUrl,
                });

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
