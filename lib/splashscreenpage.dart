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
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
            const Icon(Icons.school_sharp, size: 100),
            const SizedBox(height: 5),
            // Text
            const Text(
              'Integral University',
              style: TextStyle(
                fontSize: 34,
                color: Colors.black // Customize text color
              ),
            ),
            const Text(
              'IU CA Department',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green, // Customize text color
              ),
            ),
            const SizedBox(height: 50),
            // Progress Bar
            CircularProgressIndicator(
    backgroundColor: Colors.grey[200],
    value: _progress, // Set the progress value
    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue), // Customize progress bar color
),
          ],
        ),
      ),
    );
  }
}
