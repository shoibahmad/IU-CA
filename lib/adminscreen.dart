import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _sendingNotification = false;
  final _customMessageController = TextEditingController();
  final _subjectController = TextEditingController();

  // @protected
  // static const String ADMIN_EMAIL = 'admin@gmail.com';
  // static const String ADMIN_PASSWORD = 'password';
  // @override
  // void initState() {
  //   super.initState();
  //   // Check if the current user is the admin user.
  //   FirebaseAuth.instance.currentUser?.reload();
  //   if (FirebaseAuth.instance.currentUser?.email != ADMIN_EMAIL) {
  //     // If the current user is not the admin user, show an error message and navigate to the login screen.
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Access denied.')),
  //     );
  //     Navigator.of(context).pop();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        backgroundColor: Colors.white24,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the number of currently logged in users
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
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
                      'Number of currently logged in users: ${snapshot.data!.size}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Send a customized notification to all logged in users
              ElevatedButton(
                onPressed: _sendingNotification
                    ? null
                    : () async {
                        setState(() {
                          _sendingNotification = true;
                        });
                        try {
                          await _sendNotificationToAllUsers();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification sent!')),
                          );
                        } catch (e) {
                          print('Error sending notification: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to send notification')),
                          );
                        } finally {
                          setState(() {
                            _sendingNotification = false;
                          });
                        }
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
                child: _sendingNotification
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Send Notification',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              const SizedBox(height: 30),

              // Text field for custom message
              TextField(
                controller: _customMessageController,
                decoration: const InputDecoration(
                  labelText: 'Custom Message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Text field for notification subject
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Notification Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Custom Messaging Button
              ElevatedButton(
                onPressed: () {
                  _sendCustomMessageNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Custom message sent to students!')),
                  );
                  _customMessageController.clear();
                  _subjectController.clear();
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
                  'Send Custom Message',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to send notification to all users
  Future<void> _sendNotificationToAllUsers() async {
    // ... (Implementation remains the same) ...
  }

  // Method to send custom message notification
  Future<void> _sendCustomMessageNotification() async {
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      for (QueryDocumentSnapshot userSnapshot in usersSnapshot.docs) {
        String userToken = userSnapshot.get('token');
        // Send notification using FCM
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'AAAAUaxXpVc:APA91bFniY1HTuuUoYX4JZ9QIHin50qloXVF4--YauRw0AP4bXy2QAo6zyBxdO063dxJ7WnrwiBbdp1rSRINPN2cCssKaIi3-I3IaT5XS6pDQcLbpveWs08cqKPpwkCE2Z8LZPzlA4aI',
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'body': _customMessageController.text,
                'title': _subjectController.text,
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done',
                'message': _customMessageController.text,
              },
              'to': userToken,
            },
          ),
        );
      }
    } catch (e) {
      print('Error sending notification: $e');
      rethrow; // Re-throw to allow UI error handling
    }
  }
}
