class Coupon {
  String id;
  int value;
  double minOrderAmount;
  Coupon({required this.id, required this.value, required this.minOrderAmount});
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json["id"],
      value: json["value"],
      minOrderAmount: (json["minOrderAmount"] as num).toDouble(),
    );
  }
}
