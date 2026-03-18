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
    final dynamic rawFullName = json["fullName"] ?? json["FullName"];
    final dynamic rawEmail = json["email"] ?? json["Email"];
    final dynamic rawImageUrl =
        json["imageURL"] ?? json["ImageURL"] ?? json["avatarURL"] ?? json["AvatarURL"];
    final dynamic rawToken = json["token"] ?? json["Token"];

    return UserInfo(
      fullname: (rawFullName ?? "").toString(),
      email: (rawEmail ?? "").toString(),
      imageURL: (rawImageUrl ?? "").toString(),
      token: rawToken?.toString(),
    );
  }
}
