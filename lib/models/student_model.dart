import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String major;
  final List<String> selectedCourses;

  const StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.major,
    this.selectedCourses = const [],
  });

  factory StudentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw StateError('Student document does not exist.');
    }

    return StudentModel(
      uid: document.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      major: data['major'] as String? ?? '',
      selectedCourses: List<String>.from(
        data['selectedCourses'] ?? const <String>[],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'major': major,
      'selectedCourses': selectedCourses,
    };
  }
}
