import 'APIClient.dart';
import 'package:handmadeshop_app/models/Auth/LoginRequest.dart';
import 'package:handmadeshop_app/models/Auth/RegisterRequest.dart';
import 'package:handmadeshop_app/models/User/UserInfo.dart';
import 'package:handmadeshop_app/models/Auth/ForgotPasswordRequest.dart';
import 'package:handmadeshop_app/models/Auth/ResetPasswordRequest.dart';
import 'package:handmadeshop_app/models/Auth/VerifyResetOtpRequest.dart';
import 'package:handmadeshop_app/models/Auth/ChangePasswordRequest.dart';
import 'package:handmadeshop_app/models/User/UpdateUserRequest.dart';
import 'package:handmadeshop_app/models/User/DeleteUserRequest.dart';

class UserService {
  APIClient apiClient;
  String? lastError;

  UserService({required this.apiClient});

  Map<String, dynamic>? _extractUserMap(dynamic payload) {
    if (payload is! Map<String, dynamic>) return null;

    // Common backend envelopes.
    final dynamic data =
        payload['data'] ?? payload['result'] ?? payload['user'];
    if (data is Map<String, dynamic>) return data;

    // Sometimes login fields are returned at root.
    if (payload.containsKey('email') ||
        payload.containsKey('fullName') ||
        payload.containsKey('token')) {
      return payload;
    }
    return null;
  }

  String? _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final dynamic message =
          payload['message'] ?? payload['error'] ?? payload['title'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final errors = payload['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }
      }
    }
    return null;
  }

  String _localizeError(String? rawError, {required String fallback}) {
    final message = (rawError ?? '').trim();
    if (message.isEmpty) return fallback;

    final lower = message.toLowerCase();
    if (lower.contains('email or password is not correct') ||
        lower.contains('login failed') ||
        lower.contains('sai tài khoản hoặc mật khẩu')) {
      return 'Email hoặc mật khẩu không đúng';
    }
    if (lower.contains('user does not exist') ||
        lower.contains('account does not exist') ||
        lower.contains('tài khoản không tồn tại')) {
      return 'Tài khoản không tồn tại';
    }
    if (lower.contains('please log in first')) {
      return 'Vui lòng đăng nhập trước';
    }
    if (lower.contains('email does not exist')) {
      return 'Email không tồn tại trong hệ thống';
    }
    if (lower.contains('otp ran out of time') ||
        lower.contains('otp expired')) {
      return 'Mã OTP đã hết hạn, vui lòng gửi lại mã mới';
    }
    if (lower.contains('otp does not match') ||
        lower.contains('otp invalid')) {
      return 'Mã OTP không đúng';
    }
    if (lower.contains('server returned an error')) {
      return 'Máy chủ đang gặp lỗi, vui lòng thử lại';
    }

    return message;
  }

  Future<UserInfo?> Login(LoginRequest request) async {
    lastError = null;
    var response = await apiClient.post(
      "/User/Login",
      request.toJson(),
      requiresAuth: false,
    );

    if (!response.isSuccess) {
      lastError = _localizeError(
        response.error ?? _extractMessage(response.data),
        fallback: 'Sai tài khoản hoặc mật khẩu',
      );
      return null;
    }

    // Clear lastError on success
    lastError = null;

    final dynamic payload = response.data;
    try {
      final userMap = _extractUserMap(payload);
      if (userMap != null) {
        return UserInfo.fromJson(userMap);
      }
      lastError =
          _extractMessage(payload) ??
          'Không đọc được dữ liệu người dùng từ máy chủ';
      return null;
    } catch (_) {
      lastError =
          _extractMessage(payload) ??
          'Dữ liệu đăng nhập không hợp lệ từ máy chủ';
      return null;
    }
  }

  Future<bool> Register(RegisterRequest request) async {
    lastError = null;

    final response = await apiClient.postWithFile(
      "/User/Register",
      request.toFormData(),
      null,
      null,
      requiresAuth: false,
    );

    if (!response.isSuccess) {
      lastError =
          response.error ??
          _extractMessage(response.data) ??
          'Đăng ký thất bại';
    } else {
      // Clear lastError on success
      lastError = null;
    }
    return response.isSuccess;
  }

  Future<bool> ForgotPassword(ForgotPasswordRequest request) async {
    lastError = null;
    final response = await apiClient.post(
      "/User/ForgotPassword",
      request.toJson(),
      requiresAuth: false,
    );
    if (!response.isSuccess) {
      lastError = _localizeError(
        response.error ?? _extractMessage(response.data),
        fallback:
        'Không gửi được OTP. Vui lòng kiểm tra email hoặc trạng thái mail server',
      );
    } else {
      lastError = null;
    }
    return response.isSuccess;
  }

  Future<bool> ResetPassword(ResetPasswordRequest request) async {
    lastError = null;
    var response = await apiClient.post(
      "/User/ResetPassword",
      request.toJson(),
      requiresAuth: false,
    );
    if (!response.isSuccess) {
      lastError = _localizeError(
        response.error ?? _extractMessage(response.data),
        fallback: 'Đặt lại mật khẩu thất bại',
      );
    } else {
      lastError = null;
    }
    return response.isSuccess;
  }

  Future<bool> VerifyResetOtp(VerifyResetOtpRequest request) async {
    lastError = null;
    var response = await apiClient.post(
      "/User/VerifyResetOtp",
      request.toJson(),
      requiresAuth: false,
    );
    if (!response.isSuccess) {
      lastError = _localizeError(
        response.error ?? _extractMessage(response.data),
        fallback: 'Xác thực OTP thất bại',
      );
    } else {
      lastError = null;
    }
    return response.isSuccess;
  }

  Future<bool> ChangePassword(ChangePasswordRequest request) async {
    lastError = null;
    var response = await apiClient.post(
      "/User/ChangePassword",
      request.toJson(),
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      lastError = response.error ?? _extractMessage(response.data);
    } else {
      lastError = null;
    }
    return response.isSuccess;
  }

  Future<bool> UpdateUserInfo(UpdateUserRequest request) async {
    lastError = null;
    var response = await apiClient.putWithBytes(
      "/User",
      request.toJson(),
      request.avartarBytes,
      request.avartarFileName,
      "avartar",
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      lastError = response.error ?? _extractMessage(response.data);
    } else {
      lastError = null;
    }
    return response.isSuccess;
  }

  Future<bool> DeleteUser(DeleteUserRequest request) async {
    lastError = null;
    var response = await apiClient.delete(
      "/User",
      request.toJson(),
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      lastError = response.error ?? _extractMessage(response.data);
    } else {
      lastError = null;
    }
    return response.isSuccess;
  }
}
