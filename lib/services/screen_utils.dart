import 'package:flutter/material.dart';
import '../configurations/colors.dart';

/// Screen Utilities và Helper Functions
class ScreenUtils {
  /// Hiển thị SnackBar
  static void showSnackBar(
    BuildContext context,
    String message, {
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    Color backgroundColor = AppColors.primary,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: behavior,
        backgroundColor: backgroundColor,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Hiển thị Error SnackBar
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.error);
  }

  /// Hiển thị Success SnackBar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.success);
  }

  /// Hiển thị Warning SnackBar
  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.warning);
  }

  /// Hiển thị Dialog xác nhận
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    VoidCallback? onConfirm,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  cancelText,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  onConfirm?.call();
                },
                child: Text(
                  confirmText,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Hiển thị Loading Dialog
  static Future<void> showLoadingDialog(
    BuildContext context, {
    String message = 'Đang xử lý...',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Hide Loading Dialog
  static Future<void> hideLoadingDialog(BuildContext context) async {
    return Navigator.of(context, rootNavigator: true).pop();
  }

  /// Hiển thị Bottom Sheet
  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    double borderRadius = 24,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      builder: (context) => child,
    );
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return const EdgeInsets.all(16);
    } else if (width < 900) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Check nếu device là landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check nếu device là portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check nếu là small screen (mobile)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Check nếu là medium screen (tablet)
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  /// Check nếu là large screen (desktop)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  /// Show date picker
  static Future<DateTime?> showCustomDatePicker(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
  }

  /// Show time picker
  static Future<TimeOfDay?> showCustomTimePicker(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }

  /// Dismiss keyboard
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Push to new screen
  static Future<T?> pushTo<T>(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    return Navigator.of(context).push<T>(MaterialPageRoute(builder: builder));
  }

  /// Push replacement
  static Future<T?> pushReplacementTo<T>(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    return Navigator.of(
      context,
    ).pushReplacement<T, T>(MaterialPageRoute(builder: builder));
  }

  /// Push and remove until
  static void pushReplacementAll(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    Navigator.of(
      context,
    ).pushAndRemoveUntil(MaterialPageRoute(builder: builder), (route) => false);
  }

  /// Pop screen
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Pop until
  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  /// Can pop
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}

/// String validation utilities
class ValidationUtils {
  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được bỏ trống';
    }
    final isValid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
    if (!isValid) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Password validation
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được bỏ trống';
    }
    if (value.length < minLength) {
      return 'Mật khẩu phải có ít nhất $minLength ký tự';
    }
    return null;
  }

  /// Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được bỏ trống';
    }
    final isValid = RegExp(r'^(0|\+84)[1-9]\d{8}$').hasMatch(value);
    if (!isValid) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  /// Full name validation
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tên không được bỏ trống';
    }
    if (value.length < 3) {
      return 'Tên phải có ít nhất 3 ký tự';
    }
    return null;
  }

  /// Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Địa chỉ không được bỏ trống';
    }
    if (value.length < 5) {
      return 'Địa chỉ quá ngắn';
    }
    return null;
  }

  /// Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được bỏ trống';
    }
    return null;
  }
}
