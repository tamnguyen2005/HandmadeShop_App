import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../configurations/colors.dart';

class BannerSlider extends StatelessWidget {
  final VoidCallback? onExplorePressed;

  const BannerSlider({super.key, this.onExplorePressed});

  @override
  Widget build(BuildContext context) {
    final double bannerWidth = MediaQuery.of(context).size.width - 32;
    final double bannerHeight = (bannerWidth * 1.08).clamp(320.0, 430.0);

    return Container(
      height: bannerHeight,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image - bannerhome.png
            Image.asset('assets/images/bannerhome.png', fit: BoxFit.cover),

            // Content - responsive positioning avoids overflow on smaller devices
            LayoutBuilder(
              builder: (context, constraints) {
                final double textTop = constraints.maxHeight * 0.08;
                final double buttonBottom = constraints.maxHeight * 0.07;

                return Stack(
                  children: [
                    Positioned(
                      top: textTop,
                      left: 16,
                      right: 16,
                      child: Center(
                        child: Image.asset(
                          'assets/images/textinbanner.png',
                          height: constraints.maxHeight * 0.25,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: buttonBottom,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: onExplorePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primary,
                            elevation: 8,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: Text(
                            'Khám Phá Ngay',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
