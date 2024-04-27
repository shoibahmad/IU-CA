import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ... (import your login page here) ...

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      await _fetchUserData();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final snapshot =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (snapshot.exists) {
        _userData = snapshot.data();
      } else {
        // Handle case where user document doesn't exist
        print('User document not found');
      }
    } catch (e) {
      // Handle errors fetching user data
      print('Error fetching user data: $e');
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    // Navigate back to login page or handle the sign-out flow
    // ... (your navigation code here) ...
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('User not logged in'),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login page
                  // ... (your navigation code here) ...
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    // User is logged in and data is (hopefully) fetched
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _userData != null
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${_currentUser!.displayName}'),
                  Text('Email: ${_currentUser!.email}'),
                  // Access and display user data from _userData map
                  Text('Enrollment Number: ${_userData!['enrollmentNumber']}'),
                  // ... (other fields from _userData) ...
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Logout'),
                  ),
                ],
              ),
            )
          : const Center(child: Text('User data not found or loading...')),
    );
  }
}
