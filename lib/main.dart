import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'complete_profile_screen.dart';
import 'models/student_model.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'ui/app_design.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Register before running the app so background FCM works.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
  // Initialize after runApp so permission/network requests don't delay UI.
  // Notification setup errors should not stop the rest of LearnSpace.
  try {
    await NotificationService.initialize();
  } catch (error) {
    debugPrint('Notification initialization failed: $error');
  }
}

// Kept for compatibility with existing project files.
const Color primaryColor = AppColors.teal;
const Color backgroundColor = AppColors.canvas;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'LearnSpace',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.paleTeal,
        labelTextStyle: WidgetStateProperty.all(const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 12)),
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: AppColors.navy,
        displayColor: AppColors.navy,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: AppColors.muted),
        hintStyle: const TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    ),
    home: const AuthGate(),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const _LoadingScreen();
      }
      if (snapshot.hasError) return const _GateErrorScreen();
      final user = snapshot.data;
      if (user == null) return const LoginScreen();
      return _StudentGate(key: ValueKey(user.uid));
    },
  );
}

class _StudentGate extends StatefulWidget {
  const _StudentGate({super.key});

  @override
  State<_StudentGate> createState() => _StudentGateState();
}

class _StudentGateState extends State<_StudentGate> {
  late final Stream<StudentModel?> _profileStream;

  @override
  void initState() {
    super.initState();
    _profileStream = FirestoreService().watchStudentProfile();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<StudentModel?>(
    stream: _profileStream,
    builder: (context, snapshot) {
      if (snapshot.hasError) return const _GateErrorScreen();
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const _LoadingScreen();
      }
      if (snapshot.data == null) return const CompleteProfileScreen();
      return const HomeScreen();
    },
  );
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}

class _GateErrorScreen extends StatelessWidget {
  const _GateErrorScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_rounded, size: 54, color: AppColors.muted),
          const SizedBox(height: 16),
          const Text('We could not load your profile. Check your connection and Firestore rules.',
            textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text('Back to login'),
          ),
        ]),
      ),
    ),
  );
}
