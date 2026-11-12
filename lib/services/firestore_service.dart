import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/course_model.dart';
import '../models/student_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User get _signedInUser {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must sign in first.');
    }
    return user;
  }

  DocumentReference<Map<String, dynamic>> get _studentRef =>
      _firestore.collection('students').doc(_signedInUser.uid);

  // Complete Profile: create the student document after registration.
  Future<void> createStudentProfile({
    required String name,
    required String phone,
    required String major,
  }) async {
    final user = _signedInUser;
    final student = StudentModel(
      uid: user.uid,
      name: name.trim(),
      email: user.email ?? '',
      phone: phone.trim(),
      major: major.trim(),
    );

    await _firestore.collection('students').doc(user.uid).set(student.toMap());
  }

  // Returns null when the user has not completed their profile yet.
  Future<StudentModel?> getStudentProfile() async {
    final document = await _studentRef.get();
    if (!document.exists) return null;
    return StudentModel.fromFirestore(document);
  }

  // Live profile updates, useful for Student Profile Screen.
  Stream<StudentModel?> watchStudentProfile() {
    return _studentRef.snapshots().map(
      (document) => document.exists
          ? StudentModel.fromFirestore(document)
          : null,
    );
  }

  // Edit Profile: only change the fields editable in the assignment.
  Future<void> updateStudentProfile({
    required String name,
    required String phone,
    required String major,
  }) async {
    await _studentRef.update({
      'name': name.trim(),
      'phone': phone.trim(),
      'major': major.trim(),
    });
  }

  // Available Courses Screen (live data from Firestore).
  Stream<List<CourseModel>> watchCourses() {
    return _firestore.collection('courses').snapshots().map(
      (snapshot) => snapshot.docs
          .map((document) => CourseModel.fromFirestore(document))
          .toList(),
    );
  }

  // Store course DOCUMENT IDs in selectedCourses, e.g. 'flutter'.
  Future<void> selectCourse(String courseId) async {
    await _studentRef.update({
      'selectedCourses': FieldValue.arrayUnion([courseId]),
    });
  }

  Future<void> unselectCourse(String courseId) async {
    await _studentRef.update({
      'selectedCourses': FieldValue.arrayRemove([courseId]),
    });
  }
}
