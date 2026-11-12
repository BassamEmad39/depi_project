import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String instructor;
  final String duration;

  const CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.duration,
  });

  factory CourseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw StateError('Course document does not exist.');
    }

    return CourseModel(
      id: document.id,
      title: data['title'] as String? ?? '',
      instructor: data['instructor'] as String? ?? '',
      duration: data['duration'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'instructor': instructor,
      'duration': duration,
    };
  }
}
