import 'package:flutter/material.dart';

import 'models/student_model.dart';
import 'services/firestore_service.dart';
import 'ui/app_design.dart';

class EditProfileScreen extends StatefulWidget {
  final StudentModel student;
  const EditProfileScreen({super.key, required this.student});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirestoreService();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _major;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.student.name);
    _phone = TextEditingController(text: widget.student.phone);
    _major = TextEditingController(text: widget.student.major);
  }

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
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _service.updateStudentProfile(
        name: _name.text, phone: _phone.text, major: _major.text);
      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save changes. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageIntro(eyebrow: 'Account settings',
                title: 'Update your details',
                subtitle: 'Keep your profile accurate and up to date.'),
              const SizedBox(height: 24),
              SurfaceCard(child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Email address', style: TextStyle(
                      fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: widget.student.email,
                      readOnly: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        helperText: 'Your email is managed by Firebase Auth.'),
                    ),
                    const SizedBox(height: 17),
                    const Text('Full name', style: TextStyle(
                      fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextFormField(controller: _name, validator: _required,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline_rounded))),
                    const SizedBox(height: 17),
                    const Text('Phone number', style: TextStyle(
                      fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextFormField(controller: _phone,
                      validator: _validatePhone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined))),
                    const SizedBox(height: 17),
                    const Text('Specialization', style: TextStyle(
                      fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextFormField(controller: _major, validator: _required,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.school_outlined))),
                    const SizedBox(height: 26),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_rounded),
                      label: Text(_saving ? 'Saving...' : 'Save changes'),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ))),
    ),
  );
}
