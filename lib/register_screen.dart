
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'ui/app_design.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Return to AuthGate, which will check Firestore and show
      // CompleteProfileScreen for a new student.
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = switch (e.code) {
        'email-already-in-use' =>
          'This email is already registered.',
        'invalid-email' =>
          'Please enter a valid email.',
        'weak-password' =>
          'Your password is too weak.',
        'operation-not-allowed' =>
          'Email/password sign-up is not enabled in Firebase.',
        'network-request-failed' =>
          'Check your internet connection.',
        _ => e.message ?? 'Registration failed. Please try again.',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
    eyebrow: 'Start learning today',
    title: 'Create your account.',
    subtitle: 'Join LearnSpace and find courses built for curious minds.',
    child: Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Email address', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          validator: _validateEmail,
          decoration: const InputDecoration(
            hintText: 'you@example.com', prefixIcon: Icon(Icons.email_outlined)),
        ),
        const SizedBox(height: 18),
        const Text('Password', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter a password';
            if (value.length < 6) return 'Use at least 6 characters';
            return null;
          },
          decoration: InputDecoration(
            hintText: 'At least 6 characters',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () => setState(() =>
                  _obscurePassword = !_obscurePassword),
              icon: Icon(_obscurePassword
                  ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Confirm password',
          style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _register(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) return 'Passwords do not match';
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Repeat your password',
            prefixIcon: const Icon(Icons.verified_user_outlined),
            suffixIcon: IconButton(
              onPressed: () => setState(() =>
                  _obscureConfirmPassword = !_obscureConfirmPassword),
              icon: Icon(_obscureConfirmPassword
                  ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _isLoading ? null : _register,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
              : const Text('Create account'),
        ),
        const SizedBox(height: 13),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Already registered? Sign in'),
        ),
      ]),
    ),
  );
}
