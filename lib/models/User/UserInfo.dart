class UserInfo {
  String fullname;
  String email;
  String imageURL;
  String avatarBase64;
  String? token;

  UserInfo({
    required this.fullname,
    required this.email,
    required this.imageURL,
    this.avatarBase64 = '',
    this.token,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final dynamic rawFullName = json["fullName"] ?? json["FullName"];
    final dynamic rawEmail = json["email"] ?? json["Email"];
    final dynamic rawImageUrl =
        json["imageURL"] ?? json["ImageURL"] ?? json["avatarURL"] ?? json["AvatarURL"];
    final dynamic rawAvatarBase64 = json["avatarBase64"] ?? json["AvatarBase64"];
    final dynamic rawToken = json["token"] ?? json["Token"];

    return UserInfo(
      fullname: (rawFullName ?? "").toString(),
      email: (rawEmail ?? "").toString(),
      imageURL: (rawImageUrl ?? "").toString(),
      avatarBase64: (rawAvatarBase64 ?? "").toString(),
      token: rawToken?.toString(),
    );
  }
}
