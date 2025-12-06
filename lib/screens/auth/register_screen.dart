import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _verifyCtl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _usernameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _passCtl.dispose();
    _verifyCtl.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _loading = true);
    try {
      // register expects full_name, email, phone, password (as implemented earlier)
      await auth.register(
        _usernameCtl.text.trim(),
        _emailCtl.text.trim(),
        _phoneCtl.text.trim(),
        _passCtl.text.trim(),
      );

      // بعد التسجيل، نذهب للـ home وندمر الستاك
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } catch (e) {
      final msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // full background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backGround.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: media.height - MediaQuery.of(context).padding.top,
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // back button top-left (circle)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white70,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.arrow_back,
                              size: 18,
                              color: Colors.black87,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // main rounded card area
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        height: media.height * 0.78,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          // transparente bg so underlying image visible with gradient overlay
                        ),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // gradient rounded background (soft)
                            Positioned.fill(
                              top: 40,
                              child: Container(
                                margin: const EdgeInsets.only(top: 40),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primary.withOpacity(0.95),
                                      AppTheme.accent.withOpacity(0.92),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 12,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // big circular avatar
                            Positioned(
                              top: 6,
                              child: Container(
                                width: 168,
                                height: 168,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 6,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.14),
                                      blurRadius: 12,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/doctor.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // form fields area positioned below avatar
                            Positioned(
                              left: 22,
                              right: 22,
                              top: 200,
                              child: Form(
                                key: _form,
                                child: Column(
                                  children: [
                                    // username
                                    _StyledField(
                                      controller: _usernameCtl,
                                      hint: 'username',
                                      validator: (s) => (s == null || s.isEmpty)
                                          ? 'required'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),

                                    // email
                                    _StyledField(
                                      controller: _emailCtl,
                                      hint: 'email',
                                      validator: (s) {
                                        if (s == null || s.isEmpty)
                                          return 'required';
                                        if (!s.contains('@'))
                                          return 'invalid email';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // password
                                    _StyledField(
                                      controller: _passCtl,
                                      hint: 'password',
                                      obscure: true,
                                      validator: (s) {
                                        if (s == null || s.length < 6)
                                          return 'min 6 chars';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // verify
                                    _StyledField(
                                      controller: _verifyCtl,
                                      hint: 'verify',
                                      obscure: true,
                                      validator: (s) {
                                        if (s == null || s.isEmpty)
                                          return 'required';
                                        if (s != _passCtl.text)
                                          return 'passwords do not match';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),

                                    // sign up button
                                    SizedBox(
                                      width: 140,
                                      child: _loading
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              child: Center(
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                            )
                                          : ElevatedButton(
                                              onPressed: _onSignUp,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.black87,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(28),
                                                ),
                                                elevation: 6,
                                              ),
                                              child: Text(
                                                'sign up',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // small decorative bottom-right icon (optional)
                            Positioned(
                              bottom: 20,
                              right: 30,
                              child: Opacity(
                                opacity: 0.18,
                                child: Icon(
                                  Icons.star,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// styled rounded field used in signup screen
class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final String? Function(String?)? validator;

  const _StyledField({
    Key? key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
