class CreateOrderRequest {
  String? address;
  String? couponCode;
  List<OrderItem> items;
  String paymentMethod;
  CreateOrderRequest({
    required this.items,
    required this.paymentMethod,
    this.address,
    this.couponCode,
  });
  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "couponCode": couponCode,
      "paymentMethod": paymentMethod,
      "items": items.map((i) => i.toJson()).toList(),
    };
  }
}

class OrderItem {
  String productId;
  int quantity;
  String? configuration;
  OrderItem({
    required this.productId,
    required this.quantity,
    this.configuration,
  });
  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "quantity": quantity,
      "configuration": configuration,
    };
  }
}
