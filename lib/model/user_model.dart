
class UserModel {
  String fullName;
  String email;
  String enrollmentNumber;
  String course;
  String year;
  String password;

  UserModel({
    required this.fullName,
    required this.email,
    required this.enrollmentNumber,
    required this.course,
    required this.year,
    required this.password,
  });

  toJson() {
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
