// ignore: file_names
import 'dart:convert';
import 'dart:io';
import 'SharedPreferencesService.dart';
import 'package:handmadeshop_app/models/ApiReponse.dart';
import 'package:http/http.dart' as http;

class APIClient {
  String baseUrl = "http://192.168.50.18:5000/api";
  Future<ApiResponse<dynamic>> get(String endpoint) async {
    final token = await SharedPreferencesService().getToken() ?? "";
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token",
        },
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: jsonDecode(response.body),
        );
      } else {
        return ApiResponse(
          statusCode: response.statusCode,
          error: "Server returned an error",
        );
      }
    } catch (e) {
      return ApiResponse(statusCode: 500, error: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await SharedPreferencesService().getToken();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: response.body != "" ? jsonDecode(response.body) : null,
        );
      } else {
        return ApiResponse(
          statusCode: response.statusCode,
          error: "Server returned an error",
        );
      }
    } catch (e) {
      return ApiResponse(statusCode: 500, error: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await SharedPreferencesService().getToken();
    try {
      final response = await http.put(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: response.body != "" ? jsonDecode(response.body) : null,
        );
      } else {
        return ApiResponse(
          statusCode: response.statusCode,
          error: "Server returned an error",
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
    String fileKeyName,
  ) async {
    var request = http.MultipartRequest('PUT', Uri.parse("$baseUrl$endpoint"));
    request.fields.addAll(textFile);
    if (file != null) {
      var multipartFile = await http.MultipartFile.fromPath(
        fileKeyName,
        file.path,
      );
    }
    var streamedResponse = await request.send();
    try {
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: response.body != "" ? jsonDecode(response.body) : null,
        );
      } else {
        return ApiResponse(
          statusCode: response.statusCode,
          error: "Server returned an error",
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
    String? fileKeyName,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl$endpoint"));
    request.fields.addAll(textFile);
    if (file != null && fileKeyName != null) {
      var multipartFile = await http.MultipartFile.fromPath(
        fileKeyName,
        file.path,
      );
    }
    var streamedResponse = await request.send();
    try {
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return ApiResponse(
          statusCode: response.statusCode,
          data: response.body != "" ? jsonDecode(response.body) : null,
        );
      } else {
        return ApiResponse(
          statusCode: response.statusCode,
          error: "Server returned an error",
        );
      }
    } catch (e) {
      return ApiResponse(statusCode: 500, error: e.toString());
    }
  }
}
