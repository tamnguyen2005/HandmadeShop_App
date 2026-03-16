class RegisterRequest {
  String fullname;
  String email;
  String password;
  String? phoneNumber;
  String? address;
  RegisterRequest({
    required this.fullname,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.address,
  });
  Map<String, String> toJson() {
    return {
      "FullName": fullname,
      "Email": email,
      "Password": password,
      "PhoneNumber": phoneNumber ?? "",
      "Address": address ?? "",
    };
  }
}
