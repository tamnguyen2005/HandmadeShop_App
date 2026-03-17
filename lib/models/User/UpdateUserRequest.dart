import 'dart:io';

class UpdateUserRequest {
  String? fullName;
  String? email;
  String? password;
  String? phoneNumber;
  String? address;
  File? avatarURL;
  UpdateUserRequest({
    this.fullName,
    this.email,
    this.password,
    this.address,
    this.avatarURL,
    this.phoneNumber,
  });
  Map<String, String> toJson() {
    return {
      "fullName": fullName ?? "",
      "email": email ?? "",
      "password": password ?? "",
      "address": address ?? "",
      "phoneNumber": phoneNumber ?? "",
    };
  }
}
