import 'package:cloud_firestore/cloud_firestore.dart';

// Create a FirebaseFirestore instance
FirebaseFirestore firestore = FirebaseFirestore.instance;

class User {
  String fullName;
  String email;
  String enrollmentNumber;
  String course;
  String year;
  String password;

  User({
    required this.fullName,
    required this.email,
    required this.enrollmentNumber,
    required this.course,
    required this.year,
    required this.password,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'enrollmentNumber': enrollmentNumber,
      'course': course,
      'year': year,
      'password': password,
    };
  }
}

// Create a collection reference for the users collection
CollectionReference usersCollection = firestore.collection('users');

// Add a new user document to the collection
User users = User(
  fullName: 'Ada Lovelace',
  email: 'ada.lovelace@example.com',
  enrollmentNumber: '1234567890',
  course: 'Computer Science',
  year: '3',
  password: 'password',
);

Future<DocumentReference> addUser() async {
  return await usersCollection.add(users.toFirestore());
}
