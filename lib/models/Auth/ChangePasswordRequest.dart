class ChangePasswordRequest {
  String oldPassword;
  String newPassword;
  String confirmPassword;
  ChangePasswordRequest({
    required this.oldPassword,
    required this.confirmPassword,
    required this.newPassword,
  });
  Map<String, String> toJson() {
    return {
      "oldPassword": oldPassword.trim(),
      "newPassword": newPassword.trim(),
      "confirmPassword": confirmPassword.trim(),
    };
  }
}
