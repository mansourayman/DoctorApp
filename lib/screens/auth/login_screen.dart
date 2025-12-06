import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _loading = true);

    try {
      // هنا نستخدم method في AuthProvider لعمل login
      await auth.login(_emailCtl.text.trim(), _passCtl.text.trim());

      // لو نجح، ننقّل المستخدم للـ Home ونمسح الستاك عشان ميقدرش يرجع لشاشة login
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      // عرض رسالة خطأ للمستخدم
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
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Container(
                        height: media.height * 0.62,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF2E6BFF).withOpacity(0.95),
                                      const Color(0xFF0078FF).withOpacity(0.92),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Positioned(
                              top: 18,
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
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 8),
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

                            // الحقول وزر التسجيل
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 18,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _RoundedField(
                                      controller: _emailCtl,
                                      hint: 'email',
                                      prefix: Icons.email_outlined,
                                      suffixWidget: GestureDetector(
                                        onTap: () {
                                          _emailCtl.clear();
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                      ),
                                      validator: (s) {
                                        if (s == null || s.isEmpty)
                                          return 'required';
                                        if (!s.contains('@'))
                                          return 'invalid email';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    _RoundedField(
                                      controller: _passCtl,
                                      hint: 'pass',
                                      prefix: Icons.lock_outline,
                                      obscure: true,
                                      validator: (s) {
                                        if (s == null || s.length < 6)
                                          return 'min 6 chars';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/register',
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(80, 30),
                                          ),
                                          child: Text(
                                            'sign up',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/forgot',
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(80, 30),
                                          ),
                                          child: Text(
                                            'forget password',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    SizedBox(
                                      width: 160,
                                      child: _loading
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(
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
                                              onPressed: _onLoginPressed,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.black87,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(36),
                                                ),
                                                elevation: 6,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                              ),
                                              child: Text(
                                                'login',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
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

/// حقل مدخل دائري مُعاد استخدامه — الآن يقبل controller وvalidator
class _RoundedField extends StatelessWidget {
  final String hint;
  final IconData? prefix;
  final Widget? suffixWidget;
  final bool obscure;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const _RoundedField({
    Key? key,
    required this.hint,
    this.prefix,
    this.suffixWidget,
    this.obscure = false,
    this.controller,
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          prefixIcon: prefix != null
              ? Icon(prefix, color: Colors.grey[700])
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
          suffixIcon: suffixWidget != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: suffixWidget,
                )
              : null,
        ),
      ),
    );
  }
}
