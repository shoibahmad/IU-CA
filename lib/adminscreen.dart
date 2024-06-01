import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:iu_ca/urlredirect.dart'; // Replace with your actual import
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  int _loggedInUserCount = 0;
  bool _showNotifications = false;

  // Initialize local notifications
  late FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndGetToken();
    _checkUserAccess();
    _listenForLoggedInUsers();

    // Initialize local notifications
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _requestIOSPermissions();
    _initNotificationChannel();

    // Listen for messages received in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _storeNotificationInFirestore(
          message.notification?.title ?? '', message.notification?.body ?? '');

      // Show local notification
      _showLocalNotification(
        message.notification?.title ?? '',
        message.notification?.body ?? '',
      );
    });

    // Listen for messages received in the background or when the app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle message click event here
      print('Message clicked: ${message.notification?.body}');
    });
  }

  // Request permissions for iOS
  Future<void> _requestIOSPermissions() async {
    // Request permission to display notifications
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  // Create a notification channel
  void _initNotificationChannel() {
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );
    _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Show local notification
  Future<void> _showLocalNotification(String title, String body) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Your channel description',
      importance: Importance.high,
      priority: Priority.high,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _checkUserAccess() async {
    User? user = _auth.currentUser;
    if (user == null || user.email != 'headca@iul.ac.in') {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Iconsax.warning_2,
            color: Colors.white,
          ),
          backgroundColor: const Color.fromARGB(255, 151, 42, 40),
          title: const Text('Access Denied'),
          titleTextStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          content:
              const Text('You do not have permission to access this page.'),
          contentTextStyle: const TextStyle(color: Colors.white),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UrlRedirectScreen(),
                  ),
                );
              },
              child: const Text('OK',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _listenForLoggedInUsers() {
    final userCollection = FirebaseFirestore.instance.collection('users');
    userCollection.snapshots().listen((snapshot) {
      setState(() {
        _loggedInUserCount = snapshot.docs.length;
      });
    });
  }

  Future<void> _storeTokenInFirestore(String token) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({'token': token}, SetOptions(merge: true));
      print('Token stored successfully');
    } catch (e) {
      print('Error storing token: $e');
    }
  }

  Future<void> _storeNotificationInFirestore(String title, String body) async {
    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error storing notification: $e');
    }
  }

  // Function to show the bottom sheet with user data
  void _showUserDataBottomSheet(BuildContext context) {
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
          stream: _firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final userData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return Card(
                  elevation: 2,
                  surfaceTintColor: Colors.teal,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.teal,
                      child: Text(
                        (userData['fullname'] ?? 'N/A')
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(userData['fullname'] ?? 'N/A'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Enrollment No: ${userData['enrollmentNumber'] ?? 'N/A'}'),
                        Text('Course: ${userData['course'] ?? 'N/A'}'),
                        Text('Gmail: ${userData['email'] ?? 'N/A'}'),
                        Text('Year: ${userData['year'] ?? 'N/A'}'),
                      ],
                    ),
                    trailing: Icon(
                      userData['active'] == true
                          ? Icons.check_circle
                          : Icons.remove_circle,
                      color: userData['active'] == true
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
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
      appBar: AppBar(
        title: const Text('Admin Panel'),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 23),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showNotifications = !_showNotifications;
              });
              if (_showNotifications) {
                _showNotificationsBottomSheet(context);
              }
            },
            icon: const Icon(Iconsax.notification, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Align children to center
          children: [
            // Active Users Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Number of Active Users:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$_loggedInUserCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Send Notification Section
            const Text(
              'Send Notification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Notification Body',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
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
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Floating action button for user data
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showUserDataBottomSheet(context); // Show bottom sheet on tap
        },
        child: const Icon(
          Iconsax.user,
          color: Colors.white,
        ),
        backgroundColor: Colors.teal,
        hoverColor: Colors.amber,
        splashColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

      // Upload button at the bottom right
      persistentFooterButtons: [
        FloatingActionButton(
          onPressed: () async {
            const url =
                'https://drive.google.com/drive/folders/1Lmli5g69s9bwSezvDCbvHAvFglBtxB9e';
            try {
              await launchUrl(Uri.parse(url));
            } catch (e) {
              // Handle URL launch errors
              print('Error launching URL: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to open URL: $e')));
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
      ],
    );
  }

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
          stream: _firestore
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
                final notificationId = notifications[index].id;
                return Dismissible(
                  key: Key(notificationId),
                  onDismissed: (direction) {
                    _deleteNotification(notificationId);
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  child: ListTile(
                    title: Text(notification['title']),
                    subtitle: Text(notification['body']),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      print('Notification deleted successfully');
      // Optionally show a snackbar to confirm deletion
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Notification deleted!')));
    } catch (e) {
      print('Error deleting notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notification: $e')));
    }
  }

  Future<void> _sendNotificationToAllUsers() async {
    // Check if title and body are empty
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Notification title and body cannot be empty!')));
      return;
    }

    try {
      // Send the notification to all users
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      for (QueryDocumentSnapshot userSnapshot in usersSnapshot.docs) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        if (userData.containsKey('token')) {
          String userToken = userData['token'];

          await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAAUaxXpVc:APA91bEiVTOQufrhtrXNHXUaV2JVzg8sIs1t-fYIoeH8_WKoW-KQ6d3xUmP64JYbEmdstTYiUNDJz7o9w1hokRIb1tyRM0_7V1SSycs640EYT4dHffR79DR0TwCvLYNPl7D9_tpgjKw7', // Replace with your actual server key
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

          _showLocalNotification(_titleController.text, _bodyController.text);

          // Store the notification in Firestore
          await _storeNotificationInFirestore(
              _titleController.text, _bodyController.text);

          _titleController.clear();
          _bodyController.clear();

          return;
        } else {
          print("User document missing 'token' field: ${userSnapshot.id}");
        }
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Notification sent!')));
    } catch (e) {
      print('Error sending notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send notification: $e')));
    }
  }
}