import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../configurations/colors.dart';
import 'Login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      backgroundAsset: 'assets/images/BackGroundOnBoarding1.png',
      fit: BoxFit.cover,
      showLogo: true,
    ),
    _OnboardingPageData(
      backgroundAsset: 'assets/images/BackGroundOnBoarding2.png',
      fit: BoxFit.cover,
    ),
    _OnboardingPageData(
      backgroundAsset: 'assets/images/BackGroundOnBoarding3.png',
      fit: BoxFit.cover,
      ctaText: 'Bắt đầu khám phá',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1ED),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                return _OnboardingPage(page: page, currentPage: _currentPage);
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PageIndicator(currentPage: _currentPage, pageCount: _pages.length),
                    const SizedBox(height: 34),
                    _OnboardingButton(
                      label: _pages[_currentPage].ctaText,
                      onPressed: _goNext,
                      isLastPage: _currentPage == _pages.length - 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page, required this.currentPage});

  final _OnboardingPageData page;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(page.backgroundAsset, fit: page.fit),
        if (currentPage == 2)
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xFFF4F1ED)],
                stops: [0.58, 0.92],
              ),
            ),
          ),
        // if (page.showLogo)
        //   Align(
        //     alignment: const Alignment(0, -0.60),
        //     child: Image.asset('assets/images/logo.png', width: 176),
        //   ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage, required this.pageCount});

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 6,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF6D3F32),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  const _OnboardingButton({
    required this.label,
    required this.onPressed,
    required this.isLastPage,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLastPage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 236,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          elevation: 0,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            if (!isLastPage)
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.backgroundAsset,
    required this.fit,
    this.showLogo = false,
    this.ctaText = 'Tiếp tục',
  });

  final String backgroundAsset;
  final BoxFit fit;
  final bool showLogo;
  final String ctaText;
}
