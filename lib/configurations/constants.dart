/// App Constants - Tập trung các giá trị hằng số
class AppConstants {
  // App Info
  static const String appName = 'ATELIER Handmade Shop';
  static const String appVersion = '1.0.0';
  
  // API
  static const String apiBaseUrl = "http://192.168.50.18:5000/api";
  static const int apiTimeoutSeconds = 30;
  static const int apiRetryCount = 3;
  
  // Local Storage Keys
  static const String tokenKey = 'Token';
  static const String fullNameKey = 'FullName';
  static const String emailKey = 'Email';
  static const String imageUrlKey = 'ImageURL';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int gridColumns = 2;
  
  // Image Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String userDefaultPath = 'assets/images/user.png';
  static const String onboarding1Path = 'assets/images/BackGroundOnBoarding1.png';
  static const String onboarding2Path = 'assets/images/BackGroundOnBoarding2.png';
  static const String onboarding3Path = 'assets/images/BackGroundOnBoarding3.png';
  static const String loginBackgroundPath = 'assets/images/backgroundlogin.png';
  static const String registerBackgroundPath = 'assets/images/backgroundregister.png';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxAddressLength = 200;
  
  // Animation Durations
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  
  // Numeric Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double appBarElevation = 0.0;
  
  // Payment Methods
  static const String paymentMethodCOD = 'COD';
  static const String paymentMethodBank = 'Bank Transfer';
  static const String paymentMethodCard = 'Credit Card';
  
  // Order Status
  static const String orderStatusPending = 'Pending';
  static const String orderStatusConfirmed = 'Confirmed';
  static const String orderStatusShipping = 'Shipping';
  static const String orderStatusDelivered = 'Delivered';
  static const String orderStatusCancelled = 'Cancelled';
  
  // Error Messages
  static const String errorNetwork = 'Không thể kết nối. Vui lòng kiểm tra cết nối mạng.';
  static const String errorApiTimeout = 'Kết nối quá lâu. Vui lòng thử lại.';
  static const String errorUnknown = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const String errorInvalidEmail = 'Email không hợp lệ';
  static const String errorPasswordTooShort = 'Mật khẩu phải có ít nhất $minPasswordLength ký tự';
  static const String errorPasswordMismatch = 'Mật khẩu xác nhận không khớp';
  static const String errorEmptyField = 'Vui lòng điền đầy đủ thông tin';
  
  // Success Messages
  static const String successLoginMessage = 'Đăng nhập thành công!';
  static const String successRegisterMessage = 'Đăng ký thành công! Vui lòng đăng nhập.';
  static const String successAddToCart = 'Đã thêm vào giỏ hàng';
  static const String successAddToFavorite = 'Đã thêm vào yêu thích';
  static const String successOrderPlaced = 'Đặt hàng thành công!';
  
  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );
  
  static final RegExp phoneRegex = RegExp(
    r'^(0|\+84)[1-9]\d{8}$',
  );
  
  // Collection Launch
  static const Duration collectionCountdown = Duration(days: 5, hours: 23, minutes: 35);
}

/// App Routes (nếu sử dụng named routes)
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String personalInfo = '/personal-info';
  static const String search = '/search';
  static const String store = '/store';
  static const String collection = '/collection';
}

/// Feature Flags
class FeatureFlags {
  static const bool enablePushNotification = false;
  static const bool enablePaymentIntegration = false;
  static const bool enableSocialLogin = false;
  static const bool enableWishlist = true;
  static const bool enableReviews = false;
  static const bool enableMessaging = false;
  static const bool enableLiveChat = false;
}
