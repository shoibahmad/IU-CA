import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iu_ca/loginpage.dart';
import 'package:iu_ca/model/user_model.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final _auth = FirebaseAuth.instance; // Firebase Authentication instance
  String? fullname;
  String? email;
  String? enrollmentNumber;
  String? course;
  String? year;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New User Registration'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          // Use Stack to overlay loading indicator
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.school_outlined,
                      color: Colors.black,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Full Name'),
                        cursorColor: Colors.amber,
                        cursorOpacityAnimates: true,
                        onChanged: (value) => fullname = value,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your gmail address';
                          }
                          if (!value.contains('@gmail.com')) {
                            return 'Please enter a valid gmail address';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'Gmail'),
                        cursorColor: Colors.amber,
                        cursorOpacityAnimates: true,
                        onChanged: (value) => email = value,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your enrollment number';
                          }
                          return null;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Enrollment No.'),
                        cursorColor: Colors.amber,
                        cursorOpacityAnimates: true,
                        maxLength: 10,
                        onChanged: (value) => enrollmentNumber = value,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your course';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'Course'),
                        cursorColor: Colors.amber,
                        cursorOpacityAnimates: true,
                        onChanged: (value) => course = value,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your year';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'Year'),
                        cursorColor: Colors.amber,
                        cursorOpacityAnimates: true,
                        onChanged: (value) => year = value,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        cursorColor: Colors.amber,
                        cursorOpacityAnimates: true,
                        maxLength: 9,
                        onChanged: (value) => password = value,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            // Create user with email and password
                            final credential =
                                await _auth.createUserWithEmailAndPassword(
                              email: email!,
                              password: password!,
                            );
                            final users = credential.user!;
                            UserModel(
                              fullName: fullname!,
                              email: email!,
                              enrollmentNumber: enrollmentNumber!,
                              course: course!,
                              year: year!,
                              password: password!,
                            ).toJson();

                            // Store user data in Firestore (excluding password)
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(users.uid)
                                .set({
                              'fullname': fullname,
                              'email': email,
                              'enrollmentNumber': enrollmentNumber,
                              'course': course,
                              'year': year,
                            });

                            // Navigate to LoginPage after successful registration
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          } on FirebaseAuthException catch (e) {
                            // Handle Firebase authentication errors
                            _showErrorDialog(context, e.message!);
                          } catch (e) {
                            // Handle other errors
                            _showErrorDialog(context,
                                'An error occurred during registration.');
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(75, 50),
                        backgroundColor: Colors.teal,

                        padding: const EdgeInsets.symmetric(horizontal: 30),
                      ),
                      child: const Text('Register', selectionColor: Colors.black),
                      



                    ),
                  ],
                ),
              ),
            ),
            // Loading indicator overlay
            if (isLoading)
              Container(
                color: Colors.black
                    .withOpacity(0.5), // Semi-transparent background
                child: const Center(
                  child: SpinKitPulse(
                    color: Colors.teal,
                    size: 50.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper function to show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          )
        ],
      ),
    );
  }
}
