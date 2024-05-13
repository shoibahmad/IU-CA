import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'loginpage.dart';
import 'model/user_model.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final _auth = FirebaseAuth.instance; 
  String? fullname;
  String? email;
  String? enrollmentNumber;
  String? course;
  String? year; 
  String? password;

  // List of years for the dropdown
  final List<String> _years = ['1', '2', '3', '4'];

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
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.school_outlined,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 20),

                    // Text fields without the Card widget
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      cursorColor: Colors.amber,
                      cursorOpacityAnimates: true,
                      onChanged: (value) => fullname = value,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!value.contains('@') ||
                            !value.contains('.') ||
                            !(value.endsWith('@gmail.com') ||
                                value.endsWith('@student.iul.ac.in') ||
                                value.endsWith('@iul.ac.in'))) {
                          return 'Please enter a valid email address (e.g., @gmail.com, @student.iul.ac.in, @iul.ac.in)';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      cursorColor: Colors.amber,
                      cursorOpacityAnimates: true,
                      onChanged: (value) => email = value,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your enrollment number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Enrollment No.',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      cursorColor: Colors.amber,
                      cursorOpacityAnimates: true,
                      maxLength: 10,
                      onChanged: (value) => enrollmentNumber = value,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your course';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Course',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      cursorColor: Colors.amber,
                      cursorOpacityAnimates: true,
                      onChanged: (value) => course = value,
                    ),
                    const SizedBox(height: 20),

                    // Dropdown for year selection
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Year',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      value: year, // Set the initial value
                      items: _years.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          year = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      obscureText: true,
                      cursorColor: Colors.amber,
                      cursorOpacityAnimates: true,
                      maxLength: 15,
                      onChanged: (value) => password = value,
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
                                    email: email!, password: password!);
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
                              // Do not store the password
                            });

                            // Navigate to LoginPage after successful registration
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            _showErrorDialog(context, e.message!);
                          } catch (e) {
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
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(45, 45),
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                      ),
                      child: const Text(
                        'Register',
                        selectionColor: Colors.black,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading indicator overlay
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                // Semi-transparent background
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