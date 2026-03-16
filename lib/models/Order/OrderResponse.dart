class OrderResponse {
  String id;
  String orderDate;
  double totalAmount;
  String paymentMethod;
  String status;
  OrderResponse({
    required this.id,
    required this.orderDate,
    required this.paymentMethod,
    required this.status,
    required this.totalAmount,
  });
  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json["id"],
      orderDate: json["orderDate"],
      paymentMethod: json["paymentMethod"],
      status: json["status"],
      totalAmount: (json["totalAmount"] as num).toDouble(),
    );
  }
}
