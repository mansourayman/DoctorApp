import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/api_constants.dart';
import 'package:http/http.dart' as http;
import '../../theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    super.dispose();
  }

  Future<void> _sendResetRequest() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    try {
      // حاول إرسال الطلب إلى الـ API (عدل المسار إن اختلف)
      final uri = Uri.parse(ApiConstants.baseUrl + '/auth/forgot-password');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailCtl.text.trim()}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // تعامل مع نجاح النداء: نظهر رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني.'),
          ),
        );
        // يمكنك الرجوع للشاشة السابقة بعد نجاح الإرسال
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) Navigator.pop(context);
      } else {
        // حاول قراءة رسالة الخطأ من الاستجابة
        String message = 'فشل إرسال الطلب';
        try {
          final j = jsonDecode(res.body);
          if (j is Map && j['detail'] != null)
            message = j['detail'].toString();
          else if (j is Map && j['message'] != null)
            message = j['message'].toString();
        } catch (_) {}
        throw Exception(message);
      }
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
      // لا نعرض AppBar تقليدي لكي يشبه التصميم السابق؛ لكن يمكن إضافته بسهولة
      body: Stack(
        children: [
          // الخلفية
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
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // زر رجوع دائري في أعلى اليسار
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: CircleAvatar(
                          radius: 18,
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

                    // البطاقة الرئيسية
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        height: media.height * 0.6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // الخلفية المنحنية
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

                            // دائرة صغيرة زخرفية أو صورة (نحتفظ بدائرة فوق لأنها تصميم مشترك)
                            Positioned(
                              top: 6,
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 5,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/doctor.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // عنوان وتعليمات
                            Positioned(
                              top: 150,
                              left: 28,
                              right: 28,
                              child: Column(
                                children: [
                                  Text(
                                    'Reset Password',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'أدخل البريد الإلكتروني المرتبط بحسابك وسنرسل لك رابط إعادة التعيين.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),

                            // الحقل وزر الإرسال
                            Positioned(
                              left: 22,
                              right: 22,
                              bottom: 28,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(26),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextFormField(
                                        controller: _emailCtl,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (s) {
                                          if (s == null || s.isEmpty)
                                            return 'required';
                                          if (!s.contains('@'))
                                            return 'invalid email';
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 14,
                                          ),
                                          hintText: 'email',
                                          hintStyle: TextStyle(
                                            color: Colors.black54,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: 160,
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
                                              onPressed: _sendResetRequest,
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
                                                'send',
                                                style: GoogleFonts.poppins(
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

                    const SizedBox(height: 12),
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
