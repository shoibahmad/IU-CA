import 'package:uuid/uuid.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;

  AppNotification({
    required this.title,
    required this.body, required String id, required DateTime timestamp,
  })  : id = const Uuid().v4(),
        timestamp = DateTime.now();
        
        Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.millisecondsSinceEpoch, 
      };
}