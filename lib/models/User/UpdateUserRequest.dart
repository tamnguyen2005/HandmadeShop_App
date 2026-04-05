import 'dart:io';

class UpdateUserRequest {
  String? fullName;
  String? email;
  String? phoneNumber;
  String? address;
  File? avartar;
  UpdateUserRequest({
    this.fullName,
    this.email,
    this.address,
    this.avartar,
    this.phoneNumber,
  });
  Map<String, String> toJson() {
    return {
      "fullName": fullName?.trim() ?? "",
      "email": email?.trim().toLowerCase() ?? "",
      "phoneNumber": phoneNumber?.trim() ?? "",
      "address": address?.trim() ?? "",
    };
  }
}
