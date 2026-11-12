import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/firestore_service.dart';
import 'ui/app_design.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _major = TextEditingController();
  final _service = FirestoreService();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _major.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'This field is required' : null;

  String? _validatePhone(String? value) {
    if (_required(value) != null) return 'Please enter your phone number';
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value!.trim())) {
      return 'Enter 10–15 digits (optional + at the start)';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || !_key.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _service.createStudentProfile(
        name: _name.text,
        phone: _phone.text,
        major: _major.text,
      );
      // AuthGate reads this document and opens HomeScreen automatically.
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not save your profile. Please try again.'),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AuthLayout(
      eyebrow: 'One last step',
      title: 'Make it yours.',
      subtitle: 'Tell us a little about yourself to set up your student profile.',
      child: Form(
        key: _key,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.paleTeal,
                borderRadius: BorderRadius.circular(13)),
              child: Row(children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.teal),
                const SizedBox(width: 10),
                Expanded(child: Text(FirebaseAuth.instance.currentUser?.email ?? '',
                  style: const TextStyle(color: AppColors.navy,
                    fontWeight: FontWeight.w700))),
              ]),
            ),
            const SizedBox(height: 22),
            const Text('Full name', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(controller: _name, validator: _required,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Your full name',
                prefixIcon: Icon(Icons.person_outline_rounded))),
            const SizedBox(height: 18),
            const Text('Phone number', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(controller: _phone, validator: _validatePhone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: '01012345678',
                prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 18),
            const Text('Specialization',
              style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(controller: _major, validator: _required,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                hintText: 'e.g. Computer Science',
                prefixIcon: Icon(Icons.school_outlined))),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.arrow_forward_rounded),
              label: Text(_saving ? 'Saving profile...' : 'Finish setup'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _saving ? null : () => FirebaseAuth.instance.signOut(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    ),
  );
}
