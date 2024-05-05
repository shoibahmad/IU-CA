import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:iu_ca/loginpage.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:iconsax/iconsax.dart'; 
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:iu_ca/appnotificationmodel.dart';
import 'dart:convert';

class UrlRedirectScreen extends StatefulWidget {
  const UrlRedirectScreen({super.key});

  @override
  _UrlRedirectScreenState createState() => _UrlRedirectScreenState();
}

class _UrlRedirectScreenState extends State<UrlRedirectScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  late final List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();

    // Show the alert dialog after the user has logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          iconColor: Colors.amber,
          surfaceTintColor: Colors.black,
          shadowColor: Colors.green,
          title: const Text('IUSMS Login Required'),
          content: const Text(
              'To access the attendance and timetable, you need to login first in your IUSMS through the browser.',
              selectionColor: Colors.amberAccent),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                selectionColor: Colors.teal,
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            title: Text(notification.title),
            subtitle: Text(
              notification.body +
                  '\n' +
                  DateFormat('yyyy-MM-dd HH:mm').format(notification.timestamp),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      appBar: AppBar(
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 23),
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
                  backgroundColor: Colors.white70,
                  title: Text(
                      'Signed in as: ${user.email},\nName: ${user.displayName}, \nVerified Email: ${user.emailVerified}'),
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
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.black,
            ),
            onPressed: _showNotifications,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildButton(
                'IUSMS',
                'https://sms.iul.ac.in/Student/login.aspx',
                Color.fromARGB(255, 57, 83, 95),
                Iconsax.people5,
              ),
              _buildButton(
                'Student LMS',
                'https://ilizone.iul.ac.in/',
                Color.fromARGB(255, 72, 110, 110),
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
              ),
              _buildButton(
                'Timetable',
                'https://sms.iul.ac.in/Student/ProgramWiseTimeTable.aspx',
                const Color.fromARGB(255, 120, 162, 122),
                Iconsax.clock,
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
      String text, String url, Color backgroundColor, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: () {
          launchUrlString(url);
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
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
