import 'package:intl/intl.dart';

/// Extension methods cho String
extension StringExtensions on String {
  /// Format tiền tệ VND
  String toVNDCurrency() {
    try {
      final amount = double.parse(this);
      final formatter = NumberFormat('#,###', 'vi_VN');
      return '${formatter.format(amount)}₫';
    } catch (_) {
      return this;
    }
  }

  /// Capitalize từ đầu
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Check email valid
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(this);
  }

  /// Check phone valid (VN)
  bool isValidPhoneVN() {
    final phoneRegex = RegExp(r'^(0|\+84)[1-9]\d{8}$');
    return phoneRegex.hasMatch(this);
  }

  /// Truncate string
  String truncate(int length) {
    return this.length > length ? '${substring(0, length)}...' : this;
  }

  /// Remove extra spaces
  String removeExtraSpaces() {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

/// Extension methods cho double
extension DoubleExtensions on double {
  /// Format VND
  String toVND() {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(this)}₫';
  }

  /// Format with decimal places
  String toStringWithDecimal(int decimals) {
    return toStringAsFixed(decimals);
  }

  /// Check nếu là số nguyên
  bool isInteger() {
    return this == toInt();
  }
}

/// Extension methods cho DateTime
extension DateTimeExtensions on DateTime {
  /// Format lịch sử đơn hàng
  String toOrderDate() {
    final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
    return formatter.format(this);
  }

  /// Format full datetime
  String toFullDateTime() {
    final formatter = DateFormat('HH:mm:ss dd/MM/yyyy', 'vi_VN');
    return formatter.format(this);
  }

  /// Check ngày hôm nay?
  bool isToday() {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  /// Check ngày hôm qua?
  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return day == yesterday.day &&
        month == yesterday.month &&
        year == yesterday.year;
  }

  /// Relative time (e.g. "2 giờ trước")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return toOrderDate();
    }
  }
}

/// Extension methods cho List
extension ListExtensions<T> on List<T> {
  /// Check nếu list trống và return default value
  T? firstOrDefault(T? defaultValue) {
    return isEmpty ? defaultValue : first;
  }

  /// Thêm separator giữa items
  List<T> intersperse(T separator) {
    if (isEmpty) return this;
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }

  /// Paginate list
  List<List<T>> paginate(int pageSize) {
    final pages = <List<T>>[];
    for (int i = 0; i < length; i += pageSize) {
      pages.add(sublist(
        i,
        i + pageSize > length ? length : i + pageSize,
      ));
    }
    return pages;
  }
}

/// Extension methods cho int
extension IntExtensions on int {
  /// Format VND
  String toVND() {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(this)}₫';
  }

  /// Check nếu là even
  bool isEven() => this % 2 == 0;

  /// Check nếu là odd
  bool isOdd() => this % 2 != 0;
}
