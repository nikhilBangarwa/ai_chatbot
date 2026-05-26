import 'package:flutter/material.dart';

import '../../services/auth/auth_service.dart';
import '../../widgets/auth/auth_divider.dart';
import '../../widgets/auth/auth_scaffold.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/google_sign_in_button.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.authService,
    this.onLoggedIn,
  });

  final AuthService authService;
  final VoidCallback? onLoggedIn;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _googleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await widget.authService.signUpWithEmail(
        name: _nameController.text,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      _goHome();
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _googleLoading = true);
    try {
      final user = await widget.authService.signInWithGoogle();
      if (!mounted) return;
      if (user != null) {
        _goHome();
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _goHome() {
    widget.onLoggedIn?.call();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Sign up to start chatting with AI',
      bottom: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Already have an account? ', style: theme.textTheme.bodyMedium),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Sign in'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GoogleSignInButton(
              loading: _googleLoading,
              label: 'Sign up with Google',
              onPressed: _handleGoogleSignUp,
            ),
            const SizedBox(height: 20),
            const AuthDivider(text: 'or sign up with email'),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _nameController,
              label: 'Full name',
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value == null || value.length < 8) {
                  return 'At least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmPasswordController,
              label: 'Confirm password',
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _handleSignUp,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
