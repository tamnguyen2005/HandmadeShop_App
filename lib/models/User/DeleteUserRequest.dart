class DeleteUserRequest {
  String password;
  DeleteUserRequest({required this.password});
  Map<String, String> toJson() {
    return {"password": password.trim()};
  }
}
