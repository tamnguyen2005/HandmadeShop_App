// ignore: file_names
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'SharedPreferencesService.dart';
import 'package:handmadeshop_app/models/ApiReponse.dart';
import 'package:http/http.dart' as http;

class APIClient {
  String baseUrl = "http://192.168.50.18:5000/api";
  Future<Map<String, String>> _buildHeaders({
    bool requiresAuth = true,
    bool includeJsonContentType = true,
  }) async {
    final headers = <String, String>{};

    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (requiresAuth) {
      final token = await SharedPreferencesService().getToken();
      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = "Bearer $token";
      }
    }

    return headers;
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['title'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }

      final errors = data['errors'];
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

      // Fallback for unknown JSON error envelopes.
      final raw = jsonEncode(data);
      if (raw.trim().isNotEmpty && raw != '{}') {
        return raw;
      }
    }
    return "Server returned an error";
  }

  Future<ApiResponse<dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: await _buildHeaders(requiresAuth: requiresAuth),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: _decodeBody(response.body),
        );
      } else {
        final data = _decodeBody(response.body);
        return ApiResponse(
          statusCode: response.statusCode,
          data: data,
          error: _extractErrorMessage(data),
        );
      }
    } catch (e) {
      return ApiResponse(statusCode: 500, error: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: await _buildHeaders(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: _decodeBody(response.body),
        );
      } else {
        final data = _decodeBody(response.body);
        return ApiResponse(
          statusCode: response.statusCode,
          data: data,
          error: _extractErrorMessage(data),
        );
      }
    } catch (e) {
      return ApiResponse(statusCode: 500, error: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl$endpoint"),
        headers: await _buildHeaders(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: _decodeBody(response.body),
        );
      } else {
        final data = _decodeBody(response.body);
        return ApiResponse(
          statusCode: response.statusCode,
          data: data,
          error: _extractErrorMessage(data),
        );
      }
    } catch (e) {
      return ApiResponse(statusCode: 500, error: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> putWithFile(
    String endpoint,
    Map<String, String> textFile,
    File? file,
    String fileKeyName, {
    bool requiresAuth = true,
  }) async {
    var request = http.MultipartRequest('PUT', Uri.parse("$baseUrl$endpoint"));
    request.headers.addAll(
      await _buildHeaders(
        requiresAuth: requiresAuth,
        includeJsonContentType: false,
      ),
    );
    request.fields.addAll(textFile);
    if (file != null) {
      var multipartFile = await http.MultipartFile.fromPath(
        fileKeyName,
        file.path,
      );
      request.files.add(multipartFile);
    }
    var streamedResponse = await request.send();
    try {
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: _decodeBody(response.body),
        );
      } else {
        final data = _decodeBody(response.body);
        return ApiResponse(
          statusCode: response.statusCode,
          data: data,
          error: _extractErrorMessage(data),
        );
      }
    } catch (e) {
      return ApiResponse(statusCode: 500, error: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> putWithBytes(
    String endpoint,
    Map<String, String> textFile,
    Uint8List? bytes,
    String? fileName,
    String fileKeyName, {
    bool requiresAuth = true,
  }) async {
    var request = http.MultipartRequest('PUT', Uri.parse("$baseUrl$endpoint"));
    request.headers.addAll(
      await _buildHeaders(
        requiresAuth: requiresAuth,
        includeJsonContentType: false,
      ),
    );
    request.fields.addAll(textFile);
    if (bytes != null && fileName != null) {
      final multipartFile = http.MultipartFile.fromBytes(
        fileKeyName,
        bytes,
        filename: fileName,
      );
      request.files.add(multipartFile);
    }
    final streamedResponse = await request.send();
    try {
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: _decodeBody(response.body),
        );
      } else {
        final data = _decodeBody(response.body);
        return ApiResponse(
          statusCode: response.statusCode,
          data: data,
          error: _extractErrorMessage(data),
        );
      }
    } catch (e) {
      return ApiResponse(statusCode: 500, error: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> postWithFile(
    String endpoint,
    Map<String, String> textFile,
    File? file,
    String? fileKeyName, {
    bool requiresAuth = true,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl$endpoint"));
    request.headers.addAll(
      await _buildHeaders(
        requiresAuth: requiresAuth,
        includeJsonContentType: false,
      ),
    );
    request.fields.addAll(textFile);
    if (file != null && fileKeyName != null) {
      var multipartFile = await http.MultipartFile.fromPath(
        fileKeyName,
        file.path,
      );
      request.files.add(multipartFile);
    }
    var streamedResponse = await request.send();
    try {
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: _decodeBody(response.body),
        );
      } else {
        final data = _decodeBody(response.body);
        return ApiResponse(
          statusCode: response.statusCode,
          data: data,
          error: _extractErrorMessage(data),
        );
      }
    } catch (e) {
      return ApiResponse(statusCode: 500, error: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> delete(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl$endpoint"),
        headers: await _buildHeaders(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: _decodeBody(response.body),
        );
      } else {
        final data = _decodeBody(response.body);
        return ApiResponse(
          statusCode: response.statusCode,
          data: data,
          error: _extractErrorMessage(data),
        );
      }
    } catch (e) {
      return ApiResponse(statusCode: 500, error: e.toString());
    }
  }
}
