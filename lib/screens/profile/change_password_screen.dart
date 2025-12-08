// lib/screens/change_password_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentCtl = TextEditingController();
  final _newCtl = TextEditingController();
  final _confirmCtl = TextEditingController();

  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // animation controller for shake on error
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _currentCtl.dispose();
    _newCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  // simple password strength: 0..1
  double _passwordStrength(String pwd) {
    if (pwd.isEmpty) return 0;
    var score = 0;
    if (pwd.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score++;
    if (RegExp(r'[0-9]').hasMatch(pwd)) score++;
    if (RegExp(r'[!@#\$&*~%^]').hasMatch(pwd)) score++;
    return (score / 4).clamp(0.0, 1.0);
  }

  Color _strengthColor(double v) {
    if (v < 0.4) return Colors.redAccent;
    if (v < 0.7) return Colors.orange;
    return Colors.green;
  }

  Future<void> _showResultDialog({
    required bool success,
    String? message,
  }) async {
    // showGeneralDialog for custom animation and content
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'result',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: _ResultCard(
            success: success,
            message:
                message ?? (success ? 'Password changed' : 'Change failed'),
            onOk: () {
              Navigator.of(ctx).pop(); // close dialog
              if (success) {
                // go to home (change route name if needed)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (r) => false,
                );
              }
            },
            shakeController: _shakeController,
          ),
        );
      },
      transitionBuilder: (context, anim, secAnim, child) {
        final curved = Curves.easeOutBack.transform(anim.value);
        return Transform.scale(
          scale: curved,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final current = _currentCtl.text.trim();
    final next = _newCtl.text.trim();

    setState(() => _loading = true);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    try {
      final svc = authProv.authService;
      if (svc == null) throw Exception('Auth service unavailable');

      final ok = await svc.changePassword(current, next);

      if (ok == true) {
        await _showResultDialog(
          success: true,
          message: 'Password changed successfully',
        );
      } else {
        // server returned non-true but no exception
        _shakeController.forward(from: 0);
        await _showResultDialog(
          success: false,
          message: 'Server did not confirm change',
        );
      }
    } catch (e) {
      // shake + show error message
      _shakeController.forward(from: 0);
      await _showResultDialog(success: false, message: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateNew(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (v.trim().length < 8) return 'At least 8 chars';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    final strength = _passwordStrength(_newCtl.text);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Change Password'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf6f9ff), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                // header card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00c6ff), Color(0xFF0072ff)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Secure your account',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Change your password regularly to keep your account safe.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // form card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildPasswordField(
                            controller: _currentCtl,
                            label: 'Current password',
                            obscure: _obscureCurrent,
                            toggle: () => setState(
                              () => _obscureCurrent = !_obscureCurrent,
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: _newCtl,
                            label: 'New password',
                            obscure: _obscureNew,
                            toggle: () =>
                                setState(() => _obscureNew = !_obscureNew),
                            validator: _validateNew,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 8),
                          // strength indicator row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: strength,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _strengthColor(strength),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                strength < 0.4
                                    ? 'Weak'
                                    : (strength < 0.7 ? 'Medium' : 'Strong'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _strengthColor(strength),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: _confirmCtl,
                            label: 'Confirm new password',
                            obscure: _obscureConfirm,
                            toggle: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v != _newCtl.text)
                                return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Update Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // optional help text
                TextButton(
                  onPressed: () {
                    // maybe navigate to forgot password flow
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[700],
          ),
          onPressed: toggle,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Color strengthColor(double v) {
    if (v < 0.4) return Colors.redAccent;
    if (v < 0.7) return Colors.orange;
    return Colors.green;
  }
}

/// Custom result card used inside showGeneralDialog.
/// shows animated check or cross and message + OK button.
/// supports shaking animation on error via shakeController.
class _ResultCard extends StatefulWidget {
  final bool success;
  final String message;
  final VoidCallback onOk;
  final AnimationController shakeController;

  const _ResultCard({
    Key? key,
    required this.success,
    required this.message,
    required this.onOk,
    required this.shakeController,
  }) : super(key: key);

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  @override
  void initState() {
    super.initState();
    // if an error, play the shaking animation whenever the widget appears
    if (!widget.success) {
      widget.shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: widget.shakeController,
      builder: (context, child) {
        // shake offset calculation
        final progress = widget.shakeController.value;
        final offset =
            sin(progress * pi * 10) * (1.0 - progress) * 12; // shake amplitude
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: min(size.width * 0.82, 420),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // icon circle
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: widget.success
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    widget.success ? Icons.check_circle : Icons.cancel,
                    size: 56,
                    color: widget.success ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.success ? 'Success' : 'Failed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.success ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.success ? Colors.green : Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: widget.onOk,
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
