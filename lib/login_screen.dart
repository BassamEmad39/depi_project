import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart'
    show OAuthProviderButton;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

import 'auth_service.dart';
import 'ui/app_design.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // AuthGate checks the student profile and opens the right screen.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = switch (e.code) {
        'invalid-credential' => 'Incorrect email or password.',
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-email' => 'Please enter a valid email.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'network-request-failed' => 'Check your internet connection.',
        _ => e.message ?? 'Login failed. Please try again.',
      };

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
    eyebrow: 'Welcome to LearnSpace',
    title: 'Great to see you again.',
    subtitle: 'Log in to explore courses and continue your learning.',
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
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.email_outlined)),
        ),
        const SizedBox(height: 18),
        const Text('Password', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _login(),
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter your password' : null,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () => setState(() =>
                  _obscurePassword = !_obscurePassword),
              icon: Icon(_obscurePassword
                  ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _isLoading ? null : _login,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
              : const Text('Sign in'),
        ),
        const SizedBox(height: 20),
        const Row(children: [
          Expanded(child: Divider()),
          Padding(padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('or sign in with',
                  style: TextStyle(color: AppColors.muted, fontSize: 12))),
          Expanded(child: Divider()),
        ]),
        const SizedBox(height: 16),
        OAuthProviderButton(
          provider: GoogleProvider(
            clientId: '859000619813-j2ijck21k4mo3qae5piaermvt43iimlk.apps.googleusercontent.com',
          ),
        ),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Flexible(child: Text("Don't have an account?")),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
            child: const Text('Create one'),
          ),
        ]),
      ]),
    ),
  );
}
