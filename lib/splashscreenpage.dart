import 'package:flutter/material.dart';
import 'package:iu_ca/loginpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    while (_progress < 1.0) {
      _progress += 0.01;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 50));
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54, // Customize background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/IntegralUniversityLogo.png',
              height: 400,
              width: 400,
            ),
            Icon(Icons.school_sharp, size: 100),
            SizedBox(height: 5),
            // Text
            Text(
              'Integral University',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(
                    255, 29, 89, 31), // Customize text color
              ),
            ),
            Text(
              'IU CA Department',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black, // Customize text color
              ),
            ),
            SizedBox(height: 50),
            // Progress Bar
            CircularProgressIndicator(
              backgroundColor: Colors.grey[200],
              value: _progress, // Set the progress value
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.teal), // Customize progress bar color
            ),
          ],
        ),
      ),
    );
  }
}
