import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iu_ca/navigation_menu.dart'; // Replace with your actual import path
import 'package:iu_ca/registrationpage.dart'; // Replace with your actual import path
import 'package:iu_ca/resetpassword.dart'; // Replace with your actual import path
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
// Add this import

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false; // Add this for show/hide password

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
              clientId:
                  '350783776087-pq6fr71vcopetmnda5k7bpkrlummoetv.apps.googleusercontent.com')
          .signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Handle specific error messages
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'An account already exists with the same email address but different sign-in credentials.';
          break;
        default:
          errorMessage = 'An error occurred during sign in.';
      }
      print(errorMessage);
      // Show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return null;
    } catch (e) {
      print('Failed to sign in with Google: $e');
      return null;
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to home page on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific error messages with user-friendly messages
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        // ... handle other error codes
        default:
          errorMessage = 'An error occurred during sign in.';
      }
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      print('Failed to sign in: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 23),
        backgroundColor: Colors.teal, // Changed app bar color
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.school_sharp,
                size: 100,
                color: Colors.teal, // Changed icon color
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 300, // Adjust width as needed
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        cursorColor: Colors.teal, // Changed cursor color
                        controller: _emailController,
                        cursorErrorColor: Colors.red,
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
                          // Add email validation (optional)
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        cursorColor: Colors.teal, // Changed cursor color
                        cursorErrorColor: Colors.red,
                        controller: _passwordController,
                        obscureText:
                            !_showPassword, // Toggle password visibility
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          helperText:
                              'Password should be at least 8 characters long',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          // Add password strength validation

                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await _signInWithEmailAndPassword();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.teal, // Changed button color
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        child: _isLoading
                            ? const SpinKitFadingCircle(
                                color: Colors.white,
                                size: 20,
                              )
                            : const Text(
                                'Log In',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : signInWithGoogle,
                        icon: const Icon(Iconsax.login_14, color: Colors.white),
                        label: const Text('Sign in with Google',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegistrationPage(),
                                ),
                              );
                            },
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Sign up',
                                    style: TextStyle(
                                        color:
                                            Colors.teal)), // Changed link color
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PasswordResetScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                              color: Colors.teal), // Changed link color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
