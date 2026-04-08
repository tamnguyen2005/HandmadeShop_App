import 'dart:typed_data';

class UpdateUserRequest {
  String? fullName;
  String? email;
  String? phoneNumber;
  String? address;
  Uint8List? avartarBytes;
  String? avartarFileName;
  UpdateUserRequest({
    this.fullName,
    this.email,
    this.address,
    this.avartarBytes,
    this.avartarFileName,
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
