import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF142337);
  static const teal = Color(0xFF087F8C);
  static const sea = Color(0xFF10ADAD);
  static const canvas = Color(0xFFF5F7FB);
  static const muted = Color(0xFF728195);
  static const border = Color(0xFFE4EAF0);
  static const paleTeal = Color(0xFFE1F5F3);
  static const orange = Color(0xFFF5A45B);
}

class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(size * .29),
        ),
        child: Icon(Icons.auto_stories_rounded,
            color: Colors.white, size: size * .55),
      );
}

class SectionHeading extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? action;
  const SectionHeading({super.key, required this.title, this.description, this.action});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(description!,
                      style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ],
            ),
          ),
          ?action,
        ],
      );
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const SurfaceCard({super.key, required this.child,
      this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: Color(0x090D2338), blurRadius: 22, offset: Offset(0, 8)),
          ],
        ),
        child: child,
      );
}

class PageIntro extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  const PageIntro({super.key, required this.eyebrow, required this.title,
    required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(eyebrow.toUpperCase(),
          style: const TextStyle(color: AppColors.teal,
              fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
      const SizedBox(height: 10),
      Text(title, style: const TextStyle(color: AppColors.navy,
          fontSize: 30, fontWeight: FontWeight.w900, height: 1.15)),
      const SizedBox(height: 8),
      Text(subtitle, style: const TextStyle(
          color: AppColors.muted, height: 1.5, fontSize: 14)),
    ],
  );
}

class CourseArt extends StatelessWidget {
  final String title;
  final double size;
  const CourseArt({super.key, required this.title, this.size = 58});

  @override
  Widget build(BuildContext context) {
    final lower = title.toLowerCase();
    final isFirebase = lower.contains('firebase');
    final isDesign = lower.contains('design') || lower.contains('ui');
    final icon = isFirebase
        ? Icons.local_fire_department_rounded
        : isDesign
            ? Icons.palette_outlined
            : Icons.layers_rounded;
    final colors = isFirebase
        ? [const Color(0xFFFFD99D), const Color(0xFFFFB65F)]
        : isDesign
            ? [const Color(0xFFEADFFF), const Color(0xFFCDC0F5)]
            : [const Color(0xFFCFF6F3), const Color(0xFF8DE0DA)];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft,
            end: Alignment.bottomRight, colors: colors),
        borderRadius: BorderRadius.circular(size * .27),
      ),
      child: Icon(icon, color: AppColors.navy, size: size * .46),
    );
  }
}

class ScreenNotice extends StatelessWidget {
  final IconData icon;
  final String message;
  const ScreenNotice({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 45, color: AppColors.muted),
        const SizedBox(height: 14),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, height: 1.5)),
      ]),
    ),
  );
}

class AuthLayout extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;
  const AuthLayout({super.key, required this.eyebrow, required this.title,
    required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BrandMark(size: 56),
                const SizedBox(height: 30),
                PageIntro(eyebrow: eyebrow, title: title, subtitle: subtitle),
                const SizedBox(height: 28),
                SurfaceCard(child: child),
                const SizedBox(height: 20),
                const Text('LEARNSPACE  •  YOUR LEARNING HUB',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted,
                        fontSize: 10, fontWeight: FontWeight.w700,
                        letterSpacing: 1.4)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
