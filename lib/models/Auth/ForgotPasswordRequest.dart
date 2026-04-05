class ForgotPasswordRequest {
  String email;
  ForgotPasswordRequest({required this.email});
  Map<String, String> toJson() {
    return {"email": email.trim()};
  }
}
