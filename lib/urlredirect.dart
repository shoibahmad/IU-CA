import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iu_ca/loginpage.dart'; // Replace with your actual login page path
import 'package:url_launcher/url_launcher_string.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppNotification {
  final String title;
  final String body;
  final DateTime timestamp;
  final String id;
  bool read;

  AppNotification({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.id,
    this.read = false,
  });
}

class UrlRedirectScreen extends StatefulWidget {
  const UrlRedirectScreen({super.key});

  @override
  _UrlRedirectScreenState createState() => _UrlRedirectScreenState();
}

class _UrlRedirectScreenState extends State<UrlRedirectScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  late final Stream<QuerySnapshot> _notificationsStream;
  String? fullname, email, enrollmentNumber, course, year, profilePictureUrl;
  int _unreadNotificationsCount = 0;
  bool _showNotifications = false; 

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _setupFCM();
    _notificationsStream = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
    _notificationsStream.listen((snapshot) {
      setState(() {
        _unreadNotificationsCount = snapshot.docs
            .where((doc) => (doc.data() as Map<String, dynamic>)['read'] == false)
            .length;
      });
    });
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // Request permission and get token
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
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
    // Handle incoming messages while in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Store notification data in Firestore
        _storeNotificationData(
            message.notification!.title, message.notification!.body);
      }
    });
    // Handle messages when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Got a message whilst in the background!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _storeNotificationData(
            message.notification!.title, message.notification!.body);
      }
    });
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users') // Replace 'users' with your actual collection name
          .doc(user.uid)
          .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          fullname = data['fullname'];
          email = data['email'];
          enrollmentNumber = data['enrollmentNumber'];
          course = data['course'];
          year = data['year'];
          profilePictureUrl = data['profilePictureUrl'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Store notification data in Firestore
  Future<void> _storeNotificationData(String? title, String? body) async {
    if (title != null && body != null) {
      try {
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': title,
          'body': body,
          'timestamp': Timestamp.now(),
          'read': false,
        });
      } catch (e) {
        print('Error storing notification data: $e');
      }
    }
  }

  // Show the notification bottom sheet
  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final notifications = snapshot.data!.docs;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification =
                    notifications[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(notification['title']),
                  subtitle: Text(notification['body']),
                  onTap: () {
                    FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(notifications[index].id)
                        .update({'read': true});
                    setState(() {});
                  },
                  // Highlight unread notifications
                  tileColor: !notification['read']
                      ? Colors.grey[200]
                      : Colors.white,
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 23),
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white24,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.black),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text('Signed in as: ${user.email}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Full Name: $fullname'),
                      Text('Email: $email'),
                      Text('Enrollment No: $enrollmentNumber'),
                      Text('Course: $course'),
                      Text('Year: $year'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        // Log the user out
                        await FirebaseAuth.instance.signOut();
                        // Navigate to the login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _showNotifications = !_showNotifications;
                  });
                  if (_showNotifications) {
                    _showNotificationsBottomSheet(context);
                  }
                },
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$_unreadNotificationsCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Column(
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$fullname',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: profilePictureUrl != null
                        ? CachedNetworkImageProvider(profilePictureUrl!)
                        : const NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQt2PjOAntJbPl2_fEsHbvfk1zG0KruicRSWQ&s')
                            as ImageProvider, // Replace with your default image path
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // User Data Card
              Card(
                color: Colors.teal[50],
                shadowColor: Colors.black,
                surfaceTintColor: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Full Name:'),
                        subtitle: Text('$fullname'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email:'),
                        subtitle: Text('$email'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: const Text('Enrollment No:'),
                        subtitle: Text('$enrollmentNumber'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.book),
                        title: const Text('Course:'),
                        subtitle: Text('$course'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Year:'),
                        subtitle: Text('$year'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // URL Redirect Buttons
              _buildButton(
                'IUSMS',
                'https://sms.iul.ac.in/Student/login.aspx',
                const Color.fromARGB(255, 57, 83, 95),
                Iconsax.people5,
              ),
              _buildButton(
                'Student LMS',
                'https://ilizone.iul.ac.in/',
                const Color.fromARGB(255, 72, 110, 110),
                Iconsax.record_circle,
              ),
              _buildButton(
                'Official Website',
                'https://www.iul.ac.in/',
                const Color.fromARGB(255, 98, 95, 67),
                Iconsax.global,
              ),
              _buildButton(
                'Attendance',
                'https://sms.iul.ac.in/Student/Attendance.aspx',
                const Color.fromARGB(255, 148, 114, 103),
                Iconsax.document,
                requiresIUSMSLogin: true, // Requires IUSMS login
              ),
              _buildButton(
                'Timetable',
                'https://sms.iul.ac.in/Student/ProgramWiseTimeTable.aspx',
                const Color.fromARGB(255, 120, 162, 122),
                Iconsax.clock,
                requiresIUSMSLogin: true, // Requires IUSMS login
              ),
              _buildButton(
                'Coordinator List',
                'https://drive.google.com/drive/folders/1Lmli5g69s9bwSezvDCbvHAvFglBtxB9e',
                Colors.orange,
                Iconsax.document_text,
              ),
              _buildButton(
                'Syllabus',
                'https://www.iul.ac.in/DepartmentsStudentZones.aspx',
                const Color.fromARGB(255, 151, 128, 157),
                Iconsax.book5,
              ),
              _buildButton(
                'Result',
                'https://results.iul.ac.in/StudentloginResult.aspx?exam=46&semester=0&branch=0&res=All',
                const Color.fromARGB(255, 173, 138, 138),
                Iconsax.receipt,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, String url, Color backgroundColor, IconData iconData,
      {bool requiresIUSMSLogin = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: () {
          if (requiresIUSMSLogin) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("IUSMS Login Required"),
                  content: const Text(
                      "This feature requires you to be logged in to IUSMS. Please log in to IUSMS first."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        launchUrlString(
                            'https://sms.iul.ac.in/Student/login.aspx');
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          } else {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => const AlertDialog(
                backgroundColor: Colors.white,
                contentPadding:
                    EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                content: Row(
                  children: [
                    SpinKitThreeBounce(
                      color: Colors.teal,
                      size: 20.0,
                    ),
                    SizedBox(
                      width: 20,
                      height: BorderSide.strokeAlignCenter,
                    ),
                    Text('Loading... Please wait')
                  ],
                ),
              ),
            );
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.pop(context);
              launchUrlString(url);
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.all(25.0),
          minimumSize: const Size(double.infinity, 160),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          textStyle: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              decorationColor: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}