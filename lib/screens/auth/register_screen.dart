import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart'; // optional: keep your theme constants

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

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
