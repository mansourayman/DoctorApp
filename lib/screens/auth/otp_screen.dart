import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String fullName;
  final String phone;
  final String password;
  final String? avatarPath;

  const OtpScreen({
    super.key,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.password,
    this.avatarPath,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtl = TextEditingController();

  bool _loading = false;
  int _seconds = 60;
  late final SimpleTicker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = SimpleTicker(_onTick)..start();
  }

  void _onTick(Duration d) {
    if (!mounted) return;
    final s = 60 - d.inSeconds;
    if (s <= 0) {
      setState(() => _seconds = 0);
      _ticker.stop();
    } else {
      setState(() => _seconds = s);
    }
  }

  @override
  void dispose() {
    _otpCtl.dispose();
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _verifyAndRegister() async {
    final code = _otpCtl.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid OTP code')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      await auth.confirmRegisterOtp(
        email: widget.email,
        code: code,
        fullName: widget.fullName,
        phone: widget.phone,
        password: widget.password,
        avatarPath: widget.avatarPath,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('the account has been created')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_seconds > 0) return;

    setState(() {
      _loading = true;
      _seconds = 60;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      await auth.startRegisterRequestOtp(email: widget.email);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('the code has been sent')));

      _ticker.stop();
      _ticker.start();
    } catch (e) {
      if (!mounted) return;
      setState(() => _seconds = 0);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Faild to send  $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'Verify Email',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We sent a code to:',
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.email,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _otpCtl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: 'Enter OTP (6 digits)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _verifyAndRegister,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Verify & Continue',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _loading ? null : _resend,
              child: Text(
                _seconds > 0 ? 'Resend in $_seconds s' : 'Resend OTP',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleTicker {
  final void Function(Duration) onTick;
  SimpleTicker(this.onTick);

  bool _running = false;
  final Stopwatch _sw = Stopwatch();

  void start() {
    if (_running) return;
    _running = true;
    _sw.reset();
    _sw.start();
    _loop();
  }

  void stop() {
    _running = false;
    _sw.stop();
  }

  void dispose() => stop();

  Future<void> _loop() async {
    while (_running) {
      await Future.delayed(const Duration(seconds: 1));
      onTick(_sw.elapsed);
    }
  }
}
