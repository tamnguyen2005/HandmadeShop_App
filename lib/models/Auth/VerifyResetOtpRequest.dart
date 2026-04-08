class VerifyResetOtpRequest {
  String email;
  String otp;

  VerifyResetOtpRequest({required this.email, required this.otp});

  Map<String, String> toJson() {
    return {
      "email": email.trim(),
      "otp": otp.trim(),
    };
  }
}
