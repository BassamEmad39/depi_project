import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'courses_screen.dart';
import 'models/course_model.dart';
import 'models/student_model.dart';
import 'services/firestore_service.dart';
import 'student_profile_screen.dart';
import 'ui/app_design.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _service = FirestoreService();
  late final Stream<StudentModel?> _studentStream;
  late final Stream<List<CourseModel>> _courseStream;
  int _tab = 0;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _studentStream = _service.watchStudentProfile();
    _courseStream = _service.watchCourses();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can come back to your courses anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Stay here')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _signingOut = true);
    try {
      await _auth.logout();
      // AuthGate handles navigation when Firebase auth state changes.
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 70,
      titleSpacing: 24,
      title: const Row(children: [
        BrandMark(size: 38),
        SizedBox(width: 11),
        Text('learnspace', style: TextStyle(
            fontWeight: FontWeight.w900, fontSize: 21, letterSpacing: -0.7)),
        Text('.', style: TextStyle(color: AppColors.teal,
            fontSize: 23, fontWeight: FontWeight.w900)),
      ]),
      actions: [
        IconButton(
          tooltip: 'Sign out',
          onPressed: _signingOut ? null : _logout,
          icon: _signingOut
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.logout_rounded),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: switch (_tab) {
      1 => const CoursesScreen(embedded: true),
      2 => const StudentProfileScreen(embedded: true),
      _ => _Dashboard(
          studentStream: _studentStream,
          courseStream: _courseStream,
          onBrowse: () => setState(() => _tab = 1),
          onProfile: () => setState(() => _tab = 2),
        ),
    },
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (index) => setState(() => _tab = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.space_dashboard_outlined),
          selectedIcon: Icon(Icons.space_dashboard_rounded), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.auto_stories_outlined),
          selectedIcon: Icon(Icons.auto_stories_rounded), label: 'Courses'),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    ),
  );
}

class _Dashboard extends StatelessWidget {
  final Stream<StudentModel?> studentStream;
  final Stream<List<CourseModel>> courseStream;
  final VoidCallback onBrowse;
  final VoidCallback onProfile;

  const _Dashboard({required this.studentStream, required this.courseStream,
      required this.onBrowse, required this.onProfile});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: StreamBuilder<StudentModel?>(
      stream: studentStream,
      builder: (context, studentSnapshot) {
        if (studentSnapshot.hasError) {
          return const ScreenNotice(icon: Icons.error_outline,
              message: 'Could not load your dashboard. Please check your connection.');
        }
        if (!studentSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final student = studentSnapshot.data!;
        final firstName = student.name.trim().split(RegExp(r'\s+')).first;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              children: [
                Text('YOUR LEARNING DASHBOARD',
                    style: TextStyle(color: AppColors.teal,
                        fontSize: 11, fontWeight: FontWeight.w800,
                        letterSpacing: 1.6)),
                const SizedBox(height: 8),
                Text('Hello, $firstName 👋',
                    style: const TextStyle(color: AppColors.navy,
                        fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('Pick up where you left off, or discover something new.',
                    style: TextStyle(color: AppColors.muted, fontSize: 14)),
                const SizedBox(height: 23),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navy, Color(0xFF244A60)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Stack(children: [
                    Positioned(right: -35, top: -35,
                      child: Container(width: 170, height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0x3346D4CD), width: 27),
                        )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BUILD YOUR NEXT SKILL',
                              style: TextStyle(color: Color(0xFF78DFDA),
                                  fontSize: 11, fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5)),
                          const SizedBox(height: 12),
                          const Text('Small steps.\nBig progress.',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 28, height: 1.15,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          const Text('Find a course that matches your goals.',
                              style: TextStyle(color: Color(0xFFC7D7E1),
                                  fontSize: 13)),
                          const SizedBox(height: 19),
                          FilledButton.icon(
                            onPressed: onBrowse,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.navy,
                              minimumSize: const Size(0, 44)),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                            label: const Text('Explore courses'),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _StatCard(
                    icon: Icons.bookmark_added_outlined,
                    count: '${student.selectedCourses.length}',
                    label: 'Enrolled courses')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    icon: Icons.school_outlined,
                    count: 'My', label: 'Learning profile',
                    onTap: onProfile)),
                ]),
                const SizedBox(height: 28),
                SectionHeading(title: 'Available courses',
                  description: 'Learn something worth building',
                  action: TextButton(onPressed: onBrowse,
                    child: const Text('View all →'))),
                const SizedBox(height: 16),
                StreamBuilder<List<CourseModel>>(
                  stream: courseStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const SurfaceCard(child: Text(
                        'Courses could not be loaded. Check your connection.',
                        style: TextStyle(color: AppColors.muted)));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator()));
                    }
                    final courses = [...snapshot.data!]
                      ..sort((a, b) => a.title.compareTo(b.title));
                    if (courses.isEmpty) {
                      return const SurfaceCard(child: Text(
                        'No courses available yet. Add them in Firebase Console.',
                        style: TextStyle(color: AppColors.muted)));
                    }
                    return Column(children: [
                      for (final course in courses.take(3)) ...[
                        InkWell(
                          onTap: onBrowse,
                          borderRadius: BorderRadius.circular(22),
                          child: SurfaceCard(
                            padding: const EdgeInsets.all(15),
                            child: Row(children: [
                              CourseArt(title: course.title),
                              const SizedBox(width: 14),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 5),
                                  Text('${course.instructor}  ·  ${course.duration}',
                                      maxLines: 2,
                                      style: const TextStyle(color: AppColors.muted,
                                          fontSize: 12)),
                                ],
                              )),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.muted),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 11),
                      ],
                    ]);
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final VoidCallback? onTap;
  const _StatCard({required this.icon, required this.count,
    required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.paleTeal,
              borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.teal, size: 22)),
          const SizedBox(height: 13),
          Text(count, style: const TextStyle(fontSize: 24,
              fontWeight: FontWeight.w900, color: AppColors.navy)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(
              fontSize: 12, color: AppColors.muted)),
        ],
      ),
    ),
  );
}
