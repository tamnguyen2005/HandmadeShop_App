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

  Map<String, String> toFormData() {
    return {
      "FullName": fullname.trim(),
      "Email": email.trim().toLowerCase(),
      "Password": password,
      "PhoneNumber": phoneNumber ?? "",
      "Address": address ?? "",
    };
  }
}
