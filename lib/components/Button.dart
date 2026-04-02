import 'package:flutter/material.dart';
import '../configurations/colors.dart';

/// Primary Button Component - Sử dụng cho action chính
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final double? fontSize;
  final IconData? icon;
  final MainAxisAlignment iconAlignment;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width = double.infinity,
    this.height = 54,
    this.fontSize = 16,
    this.icon,
    this.iconAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isClickable ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isClickable ? 2 : 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isClickable ? Colors.white : Colors.white.withOpacity(0.7),
                  ),
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (icon == null) {
      return Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      );
    }

    return Row(
      mainAxisAlignment: iconAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Secondary Button - Sử dụng cho action phụ
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final double? fontSize;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width = double.infinity,
    this.height = 54,
    this.fontSize = 16,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isClickable ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.primary.withOpacity(isClickable ? 1 : 0.3),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withOpacity(isClickable ? 1 : 0.5),
                  ),
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (icon == null) {
      return Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

/// Text Button - Sử dụng cho action lightweight
class TextActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final Color? textColor;

  const TextActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textStyle,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
      ),
      child: Text(
        label,
        style: textStyle ??
            TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppColors.primary,
            ),
      ),
    );
  }
}

/// Floating Action Button - Sử dụng cho action nổi bật
class FloatingActionBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? size;

  const FloatingActionBtn({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Icon Button - Sử dụng cho button nhỏ với icon
class IconActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;
  final double? padding;
  final bool isSelected;
  final Color? selectedColor;

  const IconActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconColor,
    this.iconSize = 24,
    this.padding,
    this.isSelected = false,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: iconSize,
        color: isSelected ? (selectedColor ?? AppColors.primary) : (iconColor ?? Colors.grey),
      ),
      padding: EdgeInsets.all(padding ?? 8),
    );
  }
}
