import 'APIClient.dart';
import 'package:handmadeshop_app/models/Auth/LoginRequest.dart';
import 'package:handmadeshop_app/models/Auth/RegisterRequest.dart';
import 'package:handmadeshop_app/models/User/UserInfo.dart';

class UserService {
  APIClient apiClient;
  String? lastError;

  UserService({required this.apiClient});

  Map<String, dynamic>? _extractUserMap(dynamic payload) {
    if (payload is! Map<String, dynamic>) return null;

    // Common backend envelopes.
    final dynamic data = payload['data'] ?? payload['result'] ?? payload['user'];
    if (data is Map<String, dynamic>) return data;

    // Sometimes login fields are returned at root.
    if (payload.containsKey('email') || payload.containsKey('fullName') || payload.containsKey('token')) {
      return payload;
    }
    return null;
  }

  String? _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final dynamic message = payload['message'] ?? payload['error'] ?? payload['title'];
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

  Future<UserInfo?> Login(LoginRequest request) async {
    lastError = null;
    var response = await apiClient.post(
      "/User/Login",
      request.toJson(),
      requiresAuth: false,
    );

    if (!response.isSuccess) {
      lastError = response.error ?? _extractMessage(response.data) ?? 'Sai tài khoản hoặc mật khẩu';
      return null;
    }

    final dynamic payload = response.data;
    try {
      final userMap = _extractUserMap(payload);
      if (userMap != null) {
        return UserInfo.fromJson(userMap);
      }
      lastError = _extractMessage(payload) ?? 'Không đọc được dữ liệu người dùng từ máy chủ';
      return null;
    } catch (_) {
      lastError = _extractMessage(payload) ?? 'Dữ liệu đăng nhập không hợp lệ từ máy chủ';
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
      lastError = response.error ?? _extractMessage(response.data) ?? 'Đăng ký thất bại';
    }
    return response.isSuccess;
  }
}
