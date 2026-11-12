import 'package:flutter/material.dart';

import 'edit_profile_screen.dart';
import 'models/student_model.dart';
import 'services/firestore_service.dart';
import 'ui/app_design.dart';

class StudentProfileScreen extends StatefulWidget {
  final bool embedded;
  const StudentProfileScreen({super.key, this.embedded = false});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _service = FirestoreService();
  late final Stream<StudentModel?> _studentStream;

  @override
  void initState() {
    super.initState();
    _studentStream = _service.watchStudentProfile();
  }

  Future<void> _edit(StudentModel student) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(student: student)),
    );
    if (!mounted || updated != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your profile has been updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: StreamBuilder<StudentModel?>(
        stream: _studentStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ScreenNotice(icon: Icons.cloud_off_outlined,
              message: 'Could not load your profile. Check the connection.');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final student = snapshot.data!;
          final initials = student.name.trim().isEmpty
              ? '?' : student.name.trim()[0].toUpperCase();
          return Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              children: [
                const PageIntro(eyebrow: 'Your account',
                  title: 'Student profile',
                  subtitle: 'Your personal learning space, all in one place.'),
                const SizedBox(height: 22),
                SurfaceCard(
                  child: Column(children: [
                    Container(
                      width: 76, height: 76,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.paleTeal,
                        borderRadius: BorderRadius.circular(24)),
                      child: Text(initials,
                        style: const TextStyle(color: AppColors.teal,
                          fontWeight: FontWeight.w900, fontSize: 30)),
                    ),
                    const SizedBox(height: 14),
                    Text(student.name, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 23,
                        fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(student.major, textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(color: AppColors.paleTeal,
                        borderRadius: BorderRadius.circular(30)),
                      child: Text('${student.selectedCourses.length} enrolled course(s)',
                        style: const TextStyle(color: AppColors.teal,
                            fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                const SectionHeading(title: 'Personal information'),
                const SizedBox(height: 13),
                SurfaceCard(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(children: [
                    _InfoLine(icon: Icons.person_outline_rounded,
                      label: 'Full name', value: student.name),
                    const Divider(color: AppColors.border),
                    _InfoLine(icon: Icons.mail_outline_rounded,
                      label: 'Email address', value: student.email),
                    const Divider(color: AppColors.border),
                    _InfoLine(icon: Icons.phone_outlined,
                      label: 'Phone number', value: student.phone),
                    const Divider(color: AppColors.border),
                    _InfoLine(icon: Icons.school_outlined,
                      label: 'Specialization', value: student.major),
                  ]),
                ),
                const SizedBox(height: 23),
                FilledButton.icon(
                  onPressed: () => _edit(student),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit my profile'),
                ),
              ],
            ),
          ));
        },
      ),
    );
    if (widget.embedded) return content;
    return Scaffold(appBar: AppBar(title: const Text('Profile')), body: content);
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoLine({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 13),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.canvas,
          borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: AppColors.teal)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
            fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 4),
          SelectableText(value, style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppColors.navy)),
        ],
      )),
    ]),
  );
}
