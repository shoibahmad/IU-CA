import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iu_ca/loginpage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
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
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _userData != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(_userData![
                              'profilePictureURL'] ??
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQt2PjOAntJbPl2_fEsHbvfk1zG0KruicRSWQ&s'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Name: ${_userData!['fullname']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${_userData!['email']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      elevation: 5,
                      surfaceTintColor: Colors.amber,
                      color: Colors.white70,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            _buildInfoRow(
                                icon: Icons.school,
                                text:
                                    'Enrollment No.: ${_userData!['enrollmentNumber']}'),
                            _buildInfoRow(
                                icon: Icons.book,
                                text: 'Course: ${_userData!['course']}'),
                            _buildInfoRow(
                                icon: Icons.calendar_today,
                                text: 'Year: ${_userData!['year']}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: Text('User data not found or loading...')),
    );
  }

  // Helper function to build rows with icons and text
  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
