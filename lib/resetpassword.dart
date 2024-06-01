import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:email_validator/email_validator.dart'; // Add this for email validation
import 'loginpage.dart'; // Assuming you have a LoginPage widget

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
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          // Wrap with Form widget
          key: _formKey,
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
                    if (!EmailValidator.validate(value)) {
                      // Use EmailValidator
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
                    setState(() {}); // Show loading indicator
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
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: _emailController.text,
                      );
                      Navigator.pop(context); // Hide loading indicator

                      // Show success message and navigate to login
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password reset email sent. Please check your inbox.',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      Navigator.pop(context); // Hide loading indicator

                      // Handle specific error types for better user feedback
                      String errorMessage;
                      switch (e.code) {
                        case 'user-not-found':
                          errorMessage = 'No user found with this email.';
                          break;
                        case 'invalid-email':
                          errorMessage = 'Invalid email address.';
                          break;
                        default:
                          errorMessage =
                              'An error occurred. Please try again later.';
                      }

                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    } finally {
                      setState(() {}); // Reset state after operation
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
            ],
          ),
        ),
      ),
    );
  }
}
