class LoginResponse {
  String fullName;
  String email;
  String imageURL;
  String token;
  LoginResponse({
    required this.fullName,
    required this.email,
    required this.imageURL,
    required this.token,
  });
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      fullName: json["fullName"],
      email: json["email"],
      imageURL: json["imageURL"],
      token: json["token"],
    );
  }
}
