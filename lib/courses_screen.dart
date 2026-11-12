import 'package:flutter/material.dart';

import 'models/course_model.dart';
import 'models/student_model.dart';
import 'services/firestore_service.dart';
import 'ui/app_design.dart';

class CoursesScreen extends StatefulWidget {
  final bool embedded;
  const CoursesScreen({super.key, this.embedded = false});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final _service = FirestoreService();
  final _search = TextEditingController();
  late final Stream<List<CourseModel>> _coursesStream;
  late final Stream<StudentModel?> _profileStream;
  final Set<String> _busyIds = {};
  String _query = '';

  @override
  void initState() {
    super.initState();
    _coursesStream = _service.watchCourses();
    _profileStream = _service.watchStudentProfile();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _toggle(String courseId, bool selected) async {
    if (_busyIds.contains(courseId)) return;
    setState(() => _busyIds.add(courseId));
    try {
      if (selected) {
        await _service.unselectCourse(courseId);
      } else {
        await _service.selectCourse(courseId);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(selected ? 'Course removed from your list.' : 'Course added to your list!'),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not update this course. Please try again.')));
    } finally {
      if (mounted) setState(() => _busyIds.remove(courseId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: StreamBuilder<StudentModel?>(
            stream: _profileStream,
            builder: (context, profileSnapshot) {
              if (profileSnapshot.hasError) {
                return const ScreenNotice(icon: Icons.cloud_off_outlined,
                    message: 'Could not load your selected courses. Check your connection.');
              }
              if (!profileSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final selected = profileSnapshot.data!.selectedCourses.toSet();
              return StreamBuilder<List<CourseModel>>(
                stream: _coursesStream,
                builder: (context, coursesSnapshot) {
                  if (coursesSnapshot.hasError) {
                    return const ScreenNotice(icon: Icons.cloud_off_outlined,
                        message: 'Could not load courses. Check your connection and Firestore rules.');
                  }
                  if (!coursesSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = [...coursesSnapshot.data!]
                    ..sort((a, b) => a.title.compareTo(b.title));
                  final filtered = all.where((course) {
                    final term = _query.trim().toLowerCase();
                    return course.title.toLowerCase().contains(term) ||
                        course.instructor.toLowerCase().contains(term);
                  }).toList();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                    children: [
                      const PageIntro(
                        eyebrow: 'Course catalog',
                        title: 'Explore & enroll',
                        subtitle: 'Choose courses that move you closer to your goals.',
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _search,
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          hintText: 'Search courses or instructors',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: _CatalogMetric(
                          icon: Icons.auto_stories_rounded,
                          count: '${all.length}', label: 'Available')),
                        const SizedBox(width: 12),
                        Expanded(child: _CatalogMetric(
                          icon: Icons.bookmark_added_rounded,
                          count: '${selected.length}', label: 'Enrolled')),
                      ]),
                      const SizedBox(height: 28),
                      SectionHeading(title: 'All courses',
                        description: '${filtered.length} result${filtered.length == 1 ? '' : 's'}'),
                      const SizedBox(height: 16),
                      if (filtered.isEmpty)
                        SurfaceCard(child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(children: [
                            const Icon(Icons.search_off_rounded,
                              size: 42, color: AppColors.muted),
                            const SizedBox(height: 10),
                            Text(all.isEmpty
                                ? 'There are no courses yet. Add documents to the courses collection.'
                                : 'No courses match your search.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.muted)),
                          ]),
                        )),
                      for (final course in filtered) ...[
                        _CourseCard(
                          course: course,
                          selected: selected.contains(course.id),
                          isBusy: _busyIds.contains(course.id),
                          onToggle: () => _toggle(
                              course.id, selected.contains(course.id)),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
    if (widget.embedded) return content;
    return Scaffold(appBar: AppBar(title: const Text('Courses')), body: content);
  }
}

class _CatalogMetric extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  const _CatalogMetric({required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.paleTeal,
          borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.teal, size: 21)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count, style: const TextStyle(fontSize: 21,
            fontWeight: FontWeight.w900, color: AppColors.navy)),
          Text(label, style: const TextStyle(
            fontSize: 12, color: AppColors.muted)),
        ],
      )),
    ]),
  );
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final bool selected;
  final bool isBusy;
  final VoidCallback onToggle;
  const _CourseCard({required this.course, required this.selected,
    required this.isBusy, required this.onToggle});

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CourseArt(title: course.title, size: 68),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.title, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900,
                color: AppColors.navy)),
            const SizedBox(height: 7),
            Text('With ${course.instructor}', style: const TextStyle(
                color: AppColors.muted, fontSize: 13)),
          ],
        )),
      ]),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _InfoChip(icon: Icons.schedule_rounded, text: course.duration),
        if (selected)
          const _InfoChip(icon: Icons.check_circle_rounded,
              text: 'Enrolled', highlight: true),
      ]),
      const SizedBox(height: 17),
      SizedBox(width: double.infinity, height: 48,
        child: selected
          ? OutlinedButton.icon(
              onPressed: isBusy ? null : onToggle,
              icon: isBusy
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.remove_circle_outline_rounded),
              label: const Text('Remove from my courses'),
            )
          : FilledButton.icon(
              onPressed: isBusy ? null : onToggle,
              icon: isBusy
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.add_rounded),
              label: const Text('Enroll in course'),
            )),
    ]),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlight;
  const _InfoChip({required this.icon, required this.text, this.highlight = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: highlight ? AppColors.paleTeal : AppColors.canvas,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: highlight ? AppColors.teal : AppColors.muted),
      const SizedBox(width: 5),
      Text(text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12,
        color: highlight ? AppColors.teal : AppColors.muted)),
    ]),
  );
}
