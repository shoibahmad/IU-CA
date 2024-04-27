import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iu_ca/loginpage.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:iconsax/iconsax.dart';

class UrlRedirectScreen extends StatelessWidget {
  const UrlRedirectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 23),
        title: const Text('Home'),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white70,
                  icon: Icon(Icons.verified_user, color: Colors.black),
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
                        child: const Text('Logout',
                            selectionColor: Colors.teal,
                            style: TextStyle(color: Colors.black))),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  launchUrlString('https://www.iul.ac.in/');
                },
                icon: const Icon(Iconsax.user_add, color: Colors.white),
                label: const Text('Official Website'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 75, 92, 100),
                  padding: const EdgeInsets.all(67),
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 19, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  launchUrlString(
                      'https://sms.iul.ac.in/Student/Attendance.aspx');
                },
                icon: const Icon(Iconsax.calendar1, color: Colors.white),
                label: const Text('Attendance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 83, 24, 6),
                  padding: const EdgeInsets.all(67),
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 19, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  launchUrlString(
                      'https://sms.iul.ac.in/Student/ProgramWiseTimeTable.aspx');
                },
                icon: const Icon(Iconsax.timer_start, color: Colors.white),
                label: const Text('Timetable'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 59, 14),
                  padding: const EdgeInsets.all(67),
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 19, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  launchUrlString(
                      'https://drive.google.com/drive/folders/1Lmli5g69s9bwSezvDCbvHAvFglBtxB9e');
                },
                icon: const Icon(Iconsax.people, color: Colors.white),
                label: const Text('Coordinator List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(67),
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 19, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  launchUrlString(
                      'https://www.iul.ac.in/DepartmentsStudentZones.aspx');
                },
                icon: const Icon(Iconsax.book_square, color: Colors.white),
                label: const Text('Syllabus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 61, 40, 65),
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.all(67),
                  textStyle: const TextStyle(fontSize: 19, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  launchUrlString(
                      'https://results.iul.ac.in/StudentloginResult.aspx?exam=46&semester=0&branch=0&res=All');
                },
                icon:
                    const Icon(Iconsax.percentage_square4, color: Colors.white),
                label: const Text('Result'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 69, 53, 53),
                  padding: const EdgeInsets.all(67),
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 19, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
