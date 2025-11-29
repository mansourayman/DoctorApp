import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscure = true;
  bool _remember = false;

  // animation fields
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _scaleAnim = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    // start animation safely after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    // validate first
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _loading = true);

    try {
      await auth.login(_emailCtl.text.trim(), _passCtl.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      final msg = _prettyError(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _prettyError(Object e) {
    final s = e.toString();
    if (s.startsWith('Exception:'))
      return s.replaceFirst('Exception:', '').trim();
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F52FF), Color(0xFF2EC9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // soft decorative circle
          Positioned(
            top: -media.width * 0.15,
            right: -media.width * 0.15,
            child: Container(
              width: media.width * 0.5,
              height: media.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // main content with keyboard-aware padding
          SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 160),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  height:
                      media.height -
                      MediaQuery.of(context).padding.top -
                      bottomInset,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(height: 22),

                      // header (logo + text) animated
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Column(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00C6FF),
                                    Color(0xFF0072FF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 14,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/doctor.png',
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Welcome back',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sign in to continue',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // animated card with max width for tablets
                      SlideTransition(
                        position: _slideAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 520,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 20,
                                        offset: Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                      vertical: 20,
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _ModernField(
                                            controller: _emailCtl,
                                            hint: 'Email',
                                            prefix: Icons.email_outlined,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: (s) {
                                              if (s == null || s.isEmpty)
                                                return 'Required';
                                              if (!RegExp(
                                                r'^[^@]+@[^@]+\.[^@]+',
                                              ).hasMatch(s.trim()))
                                                return 'Invalid email';
                                              return null;
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(
                                                  context,
                                                ).nextFocus(),
                                          ),
                                          const SizedBox(height: 12),
                                          _ModernField(
                                            controller: _passCtl,
                                            hint: 'Password',
                                            prefix: Icons.lock_outline,
                                            obscure: _obscure,
                                            suffix: IconButton(
                                              icon: Icon(
                                                _obscure
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.grey[700],
                                              ),
                                              onPressed: () => setState(
                                                () => _obscure = !_obscure,
                                              ),
                                            ),
                                            validator: (s) {
                                              if (s == null || s.length < 6)
                                                return 'Min 6 chars';
                                              return null;
                                            },
                                            textInputAction:
                                                TextInputAction.done,
                                            onFieldSubmitted: (_) =>
                                                _onLoginPressed(),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () => setState(
                                                  () => _remember = !_remember,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Row(
                                                  children: [
                                                    AnimatedContainer(
                                                      duration: const Duration(
                                                        milliseconds: 220,
                                                      ),
                                                      width: 22,
                                                      height: 22,
                                                      decoration: BoxDecoration(
                                                        color: _remember
                                                            ? const Color(
                                                                0xFF0072FF,
                                                              )
                                                            : Colors
                                                                  .transparent,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        border: Border.all(
                                                          color: _remember
                                                              ? Colors
                                                                    .transparent
                                                              : Colors
                                                                    .grey
                                                                    .shade300,
                                                        ),
                                                      ),
                                                      child: _remember
                                                          ? const Icon(
                                                              Icons.check,
                                                              size: 16,
                                                              color:
                                                                  Colors.white,
                                                            )
                                                          : null,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Remember me',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 13,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/forgot',
                                                    ),
                                                child: Text(
                                                  'Forgot password?',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                backgroundColor: const Color(
                                                  0xFF0072FF,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 6,
                                              ),
                                              onPressed: _loading
                                                  ? null
                                                  : _onLoginPressed,
                                              child: _loading
                                                  ? const SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 2.2,
                                                          ),
                                                    )
                                                  : Text(
                                                      'Sign in',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                          ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                    ),
                                                child: Text(
                                                  'or',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // social buttons: responsive — Expanded + FittedBox prevents overflow
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () {},
                                                  icon: Image.asset(
                                                    r'assets\images\google_logo.png',
                                                    width: 18,
                                                    height: 18,
                                                    errorBuilder: (ctx, o, s) =>
                                                        const SizedBox.shrink(),
                                                  ),
                                                  label: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Google',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                    ),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                    Icons.apple,
                                                    size: 18,
                                                  ),
                                                  label: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Apple',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                    ),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Don't have an account? ",
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/register',
                                                    ),
                                                child: Text(
                                                  'Sign up',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 12),
                      Text(
                        '© ${DateTime.now().year} Your Clinic',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern reusable text field used in LoginPage.
class _ModernField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefix;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const _ModernField({
    Key? key,
    required this.controller,
    required this.hint,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          prefixIcon: prefix != null
              ? Icon(prefix, color: Colors.grey[700])
              : null,
          suffixIcon: suffix,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
