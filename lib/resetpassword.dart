import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iu_ca/loginpage.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 23),
        title: const Text('Password Reset'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 70),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {});

                  // Show a SpinKit progress indicator for 3 seconds
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: SpinKitDancingSquare(
                          color: Colors.green,
                          size: 50.0,
                        ),
                      );
                    },
                  );

                  try {
                    // Send the password reset email
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: _emailController.text,
                    );

                    // Hide the loading indicator
                    Navigator.pop(context);

                    // Show a success snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset email sent',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    );

                    // Navigate to the login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  } on FirebaseAuthException catch (e) {
                    // Hide the loading indicator
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);

                    // Show an error snackbar
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.message!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } finally {
                    setState(() {});
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(45, 45),
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  decorationColor: Colors.amber,
                ),
              ),
              child: const Text(
                'Reset Password',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            // Text field for writing a custom message
          ],
        ),
      ),
    );
  }
}
