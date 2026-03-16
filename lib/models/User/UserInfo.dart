class UserInfo {
  String fullname;
  String email;
  String imageURL;
  String? token;
  UserInfo({
    required this.fullname,
    required this.email,
    required this.imageURL,
    this.token,
  });
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      fullname: json["fullName"],
      email: json["email"],
      imageURL: json["imageURL"],
      token: json["token"],
    );
  }
}
