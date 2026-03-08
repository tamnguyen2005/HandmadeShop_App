import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../configurations/colors.dart';

class BannerSlider extends StatelessWidget {
  final VoidCallback? onExplorePressed;

  const BannerSlider({
    super.key,
    this.onExplorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
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
            // Background Image
            Image.asset(
              'assets/images/banner_spring.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback gradient if image not found
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accent,
                        AppColors.secondary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  // Mock product image as background
                  child: Opacity(
                    opacity: 0.3,
                    child: Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 120,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Main Title with decorative font
                  Text(
                    'Bộ sưu tập Mùa Xuân',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dancingScript(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  Text(
                    'Nơi tình lệ da mùa mới',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // CTA Button
                  ElevatedButton(
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
                  
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
