// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  final List<Map<String, String>> pages = [
    {
      'title': 'اختيار أفضل الأطباء',
      'subtitle': 'ابحث عن التخصص المناسب واحجز بسهولة.',
    },
    {
      'title': 'إدارة المواعيد',
      'subtitle': 'راجع مواعيدك، عدّل مواعيدك، وتلقّى تذكيرات.',
    },
    {
      'title': 'ملف صحي مرتب',
      'subtitle': 'سجلات، تقييمات، وملاحظات في مكان واحد.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pc,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: pages.length,
                itemBuilder: (_, i) {
                  final p = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 240,
                          width: 240,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withOpacity(0.95),
                                AppTheme.accent.withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(140),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.medical_services,
                              size: 84,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          p['title']!,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          p['subtitle']!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 6, vertical: 18),
                  height: 8,
                  width: active ? 28 : 8,
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primary : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 18,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text('تخطي'),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_page == pages.length - 1) {
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        _pc.nextPage(
                          duration: Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Text(_page == pages.length - 1 ? 'ابدأ' : 'التالي'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
  final List<_OnbPage> pages = [
    _OnbPage(
      imageAsset: 'assets/images/onb_doctor1.png',
      title: 'اختيار أفضل الأطباء',
      subtitle: 'ابحث عن التخصص المناسب واحجز بسهولة.',
    ),
    _OnbPage(
      imageAsset: 'assets/images/onb_schedule.png',
      title: 'إدارة المواعيد',
      subtitle: 'راجع مواعيدك وعدّلها بسرعة.',
    ),
    _OnbPage(
      imageAsset: 'assets/images/onb_records.png',
      title: 'ملف صحي مرتب',
      subtitle: 'سجلات، تقييمات، وملاحظات في مكان واحد.',
    ),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Color get _primarySafe => AppTheme.primary;
  Color get _bgSafe => AppTheme.bg;

  void _next() {
    if (_page == pages.length - 1) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _pc.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final isWide = w > 600;

    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 الخلفية
          Positioned.fill(
            child: Image.asset(
              'assets/images/backGround.png',
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 طبقة شفافة خفيفة لتنعيم الألوان
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.05)),
          ),

          /// 🔹 المحتوى الأصلي
          SafeArea(
            child: Column(
              children: [
                // top controls (skip)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      InkWell(
                        onTap: _skip,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            'تخطي',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (ctx, i) {
                      final p = pages[i];
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final availableHeight = constraints.maxHeight;
                          final imageMaxWidth = isWide
                              ? 360.0
                              : (w * 0.62).clamp(140.0, 320.0);
                          final maxImageByHeight = (availableHeight * 0.55)
                              .clamp(120.0, imageMaxWidth);
                          final imageSize = imageMaxWidth.clamp(
                            120.0,
                            maxImageByHeight,
                          );
                          final allowScroll = availableHeight < 420;

                          final content = Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22.0,
                              vertical: 8,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // image container
                                Container(
                                  width: imageSize,
                                  height: imageSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x22000000),
                                        blurRadius: 18,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.asset(
                                      p.imageAsset,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.white,
                                        child: Center(
                                          child: Icon(
                                            Icons.medical_services,
                                            size: imageSize * 0.34,
                                            color: _primarySafe,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                // title
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    p.title,
                                    key: ValueKey('title_$i'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isWide ? 22 : 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // subtitle
                                Text(
                                  p.subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (allowScroll) {
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: content,
                              ),
                            );
                          } else {
                            return content;
                          }
                        },
                      );
                    },
                  ),
                ),

                // indicator + buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 18,
                  ),
                  child: Column(
                    children: [
                      // indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(pages.length, (idx) {
                          final active = idx == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            height: 8,
                            width: active ? 28 : 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),

                      // action buttons
                      Row(
                        children: [
                          SizedBox(
                            width: 84,
                            child: _page > 0
                                ? TextButton(
                                    onPressed: () => _pc.previousPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    ),
                                    child: const Text(
                                      'السابق',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _primarySafe,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _page == pages.length - 1 ? 'ابدأ' : 'التالي',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _page == pages.length - 1
                                      ? Icons.check
                                      : Icons.arrow_forward,
                                  size: 18,
                                ),
                              ],
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
        ],
      ),
    );
  }
}

class _OnbPage {
  final String imageAsset;
  final String title;
  final String subtitle;
  _OnbPage({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });
 }
}