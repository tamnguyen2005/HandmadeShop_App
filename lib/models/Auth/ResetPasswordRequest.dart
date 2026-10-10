class ResetPasswordRequest {
  String email;
  String otp;
  String password;
  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.password,
  });
  Map<String, String> toJson() {
    return {
      "email": email.trim(),
      "otp": otp.trim(),
      "password": password.trim(),
    };
  }
}
