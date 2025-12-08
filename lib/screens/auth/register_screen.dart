import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart'; // optional: keep your theme constants

class RegisterScreen extends StatefulWidget {

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);


  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _verifyCtl = TextEditingController();

  bool _loading = false;
  bool _showPass = false;
  bool _showVerify = false;
  bool _agree = false;
  double _strength = 0.0;
  File? _pickedImage;

  final _picker = ImagePicker();
    }
  @override
  void initState() {
    super.initState();
    _passCtl.addListener(() {
      final s = _passwordStrength(_passCtl.text);
      setState(() => _strength = s);
    });
  }

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
    }
  }   // register expects full_name, email, phone, password (as implemented earlier)
  // pick avatar (optional)
  Future<void> _pickAvatar() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
      );
      if (x != null) setState(() => _pickedImage = File(x.path));
    } catch (e) {
      // ignore or show snackbar
    }
  }

  double _passwordStrength(String pwd) {
    if (pwd.isEmpty) return 0;
    var score = 0;
    if (pwd.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score++;
    if (RegExp(r'[0-9]').hasMatch(pwd)) score++;
    if (RegExp(r'[!@#\$&*~%^]').hasMatch(pwd)) score++;
    return (score / 4).clamp(0.0, 1.0);
  }

  String _strengthLabel(double v) {
    if (v <= 0.25) return 'Very weak';
    if (v <= 0.5) return 'Weak';
    if (v <= 0.75) return 'Medium';
    return 'Strong';
  }

  Color _strengthColor(double v) {
    if (v <= 0.25) return Colors.redAccent;
    if (v <= 0.5) return Colors.orange;
    if (v <= 0.75) return Colors.amber;
    return Colors.green;
  }

  Future<void> _onSignUp() async {
    if (!_form.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms first')),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
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
      // optionally upload avatar after register
      if (_pickedImage != null) {
        await auth.uploadAvatarAndUpdate(_pickedImage!.path);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful')));
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Register failed: ${e.toString()}')),
        );
      }
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
    final isWide = media.width >= 700;

    return Scaffold(
      body: Stack(
        children: [
          // background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F4DFF), Color(0xFF00C6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 900 : 420),
                  child: Card(
                    color: Colors.white,
                    elevation: 14,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22.0,
                        vertical: 18,
                      ),
                      child: Column(
                        children: [
                          // header with avatar and title
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: _pickAvatar,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00C6FF),
                                        Color(0xFF0072FF),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundImage: _pickedImage != null
                                        ? FileImage(_pickedImage!)
                                        : const AssetImage(
                                                'assets/images/doctor.png',
                                              )
                                              as ImageProvider,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create account',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Join us — secure & simple',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // form fields
                          Form(
                            key: _form,
                            child: Column(
                              children: [
                                _buildField(
                                  controller: _usernameCtl,
                                  hint: 'Full name',
                                  icon: Icons.person_outline,
                                  validator: (s) =>
                                      s == null || s.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                _buildField(
                                  controller: _emailCtl,
                                  hint: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (s) {
                                    if (s == null || s.trim().isEmpty)
                                      return 'Required';
                                    final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                    if (!re.hasMatch(s.trim()))
                                      return 'Invalid email';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildField(
                                  controller: _phoneCtl,
                                  hint: 'Phone',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 12),
                                // password + strength
                                _buildField(
                                  controller: _passCtl,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  obscure: !_showPass,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _showPass
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () =>
                                        setState(() => _showPass = !_showPass),
                                  ),
                                  validator: (s) {
                                    if (s == null || s.length < 8)
                                      return 'Min 8 chars';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                // strength bar
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: _strength,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _strengthColor(_strength),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _strengthLabel(_strength),
                                      style: TextStyle(
                                        color: _strengthColor(_strength),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildField(
                                  controller: _verifyCtl,
                                  hint: 'Confirm password',
                                  icon: Icons.lock_clock,
                                  obscure: !_showVerify,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _showVerify
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () => setState(
                                      () => _showVerify = !_showVerify,
                                    ),
                                  ),
                                  validator: (s) {
                                    if (s == null || s.isEmpty)
                                      return 'Required';
                                    if (s != _passCtl.text)
                                      return 'Confirm does not match';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _agree,
                                      onChanged: (v) =>
                                          setState(() => _agree = v ?? false),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            setState(() => _agree = !_agree),
                                        child: RichText(
                                          text: TextSpan(
                                            style: GoogleFonts.poppins(
                                              color: Colors.black87,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: 'I agree to the ',
                                              ),
                                              TextSpan(
                                                text: 'Terms & Privacy',
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // action buttons: signup + social
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _onSignUp,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Create account',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {}, // implement google
                                        icon: Image.asset(
                                          r'assets\images\google_logo.png',
                                          width: 18,
                                          height: 18,
                                          errorBuilder: (_, __, ___) =>
                                              Icon(Icons.g_mobiledata),
                                        ),
                                        label: const FittedBox(
                                          child: Text('Continue with Google'),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {}, // implement apple
                                        icon: const Icon(Icons.apple, size: 18),
                                        label: const FittedBox(
                                          child: Text('Continue with Apple'),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already a member? ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/login',
                                      ),
                                      child: Text(
                                        'Sign in',
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
                        ],
                      ),
                    ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    Widget? suffix,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[700]) : null,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
     );
   }
  }
 }
}