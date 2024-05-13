import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'dart:convert';

import 'package:iu_ca/urlredirect.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndGetToken();
    _checkUserAccess();
  }

  Future<void> _checkUserAccess() async {
    User? user = _auth.currentUser;
    if (user == null || user.email != 'hodca@iul.ac.in') {
      // Access denied - show alert and redirect
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Access Denied'),
          content:
              const Text('You do not have permission to access this page.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => UrlRedirectScreen())));
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _requestPermissionsAndGetToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token = await messaging.getToken();
      print('FirebaseMessaging token: $token');
      if (token != null) {
        _storeTokenInFirestore(token);
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _storeTokenInFirestore(String token) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'token': token,
      }, SetOptions(merge: true));
      print('Token stored successfully');
    } catch (e) {
      print('Error storing token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .where('active', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'Number of Active Users: ${snapshot.data!.size}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Notification Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Notification Body',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _sendNotificationToAllUsers();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 15.0,
                  ),
                  textStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                child: const Text(
                  'Send Notification',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          const url =
              'https://drive.google.com/drive/folders/1Lmli5g69s9bwSezvDCbvHAvFglBtxB9e'; // Replace with your desired URL
          // ignore: deprecated_member_use
          if (await canLaunch(url)) {
            // ignore: deprecated_member_use
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        },
        child: const Icon(
          Iconsax.arrow_up_1,
          color: Colors.white,
        ),
        backgroundColor: Colors.teal,
        hoverColor: Colors.amber,
        splashColor: Colors.black,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Position at bottom right
    );
  }

  Future<void> _sendNotificationToAllUsers() async {
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      for (QueryDocumentSnapshot userSnapshot in usersSnapshot.docs) {
        String userToken = userSnapshot.get('token');
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAUaxXpVc:APA91bEiVTOQufrhtrXNHXUaV2JVzg8sIs1t-fYIoeH8_WKoW-KQ6d3xUmP64JYbEmdstTYiUNDJz7o9w1hokRIb1tyRM0_7V1SSycs640EYT4dHffR79DR0TwCvLYNPl7D9_tpgjKw7',
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'body': _bodyController.text,
                'title': _titleController.text,
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done',
              },
              'to': userToken,
            },
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent!')),
      );
    } catch (e) {
      print('Error sending notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send notification: $e')),
      );
    }
  }
}
