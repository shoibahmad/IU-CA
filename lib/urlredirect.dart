import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iu_ca/loginpage.dart'; // Assuming this is your login page file
import 'package:url_launcher/url_launcher_string.dart';
import 'package:iconsax/iconsax.dart'; // Added the iconsax package

class UrlRedirectScreen extends StatefulWidget {
  const UrlRedirectScreen({super.key});

  @override
  _UrlRedirectScreenState createState() => _UrlRedirectScreenState();
}

class _UrlRedirectScreenState extends State<UrlRedirectScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
              20.0), // Increased padding for better spacing
          child: Column(
            children: [
              _buildButton(
                'Official Website',
                'https://www.iul.ac.in/',
                Colors.yellow[100]!,
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
      padding:
          const EdgeInsets.symmetric(vertical: 10.0), // Added vertical padding
      child: ElevatedButton(
        onPressed: () {
          launchUrlString(url);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.all(
              25.0), // Increased padding for larger button size
          minimumSize:
              const Size(double.infinity, 160), // Increased button height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
          ),
          textStyle: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              decorationColor: Colors.white // Set text color to white
              ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }
}
