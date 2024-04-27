import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  final CollectionReference userReference = FirebaseFirestore.instance.collection('users');
}

