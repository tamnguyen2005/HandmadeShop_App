import 'APIClient.dart';
import 'package:handmadeshop_app/models/Auth/LoginRequest.dart';
import 'package:handmadeshop_app/models/Auth/RegisterRequest.dart';
import 'package:handmadeshop_app/models/User/UserInfo.dart';

class UserService {
  APIClient apiClient;
  UserService({required this.apiClient});
  Future<UserInfo?> Login(LoginRequest request) async {
    var response = await apiClient.post("/User/Login", request.toJson());
    if (response.isSuccess) {
      return UserInfo.fromJson(response.data);
    } else {
      return null;
    }
  }

  Future<bool> Register(RegisterRequest request) async {
    var response = await apiClient.postWithFile(
      "/User/Register",
      request.toJson(),
      null,
      null,
    );
    return response.isSuccess;
  }
}
