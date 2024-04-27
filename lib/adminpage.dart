import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _sendingNotification = false; // Track notification sending state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              return Text(
                'Number of currently logged in users: ${snapshot.data!.size}',
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
                        SnackBar(content: Text('Notification sent!')),
                      );
                    } catch (e) {
                      print('Error sending notification: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to send notification')),
                      );
                    } finally {
                      setState(() {
                        _sendingNotification = false;
                      });
                    }
                  },
            child: _sendingNotification
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text('Send Notification'),
          ),
          SizedBox(height: 20),
          // Display a list of all notifications sent to the user
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users/${_auth.currentUser!.uid}/notifications')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No notifications yet.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.size,
                  itemBuilder: (context, index) {
                    final notification = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(notification.get('title')),
                      subtitle: Text(notification.get('body')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to send notification to all users
  Future<void> _sendNotificationToAllUsers() async {
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
                'key=AAAAUaxXpVc:APA91bEiVTOQufrhtrXNHXUaV2JVzg8sIs1t-fYIoeH8_WKoW-KQ6d3xUmP64JYbEmdstTYiUNDJz7o9w1hokRIb1tyRM0_7V1SSycs640EYT4dHffR79DR0TwCvLYNPl7D9_tpgjKw7', // Replace with your FCM server key
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'body': 'This is a test notification!',
                'title': 'Admin Notification',
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
    } catch (e) {
      print('Error sending notification: $e');
      rethrow; // Re-throw to allow UI error handling
    }
  }
}
