class OrderDetailResponse {
  String id;
  String orderDate;
  double totalAmount;
  String shippingAddress;
  String paymentMethod;
  String status;
  List<ProductResponse> products;
  OrderDetailResponse({
    required this.id,
    required this.orderDate,
    required this.paymentMethod,
    required this.products,
    required this.shippingAddress,
    required this.status,
    required this.totalAmount,
  });
  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      id: json["id"],
      orderDate: json["orderDate"],
      paymentMethod: json["paymentMethod"],
      products: json["products"] != null
          ? (json["products"] as List)
                .map((j) => ProductResponse.fromJson(j))
                .toList()
          : [],
      shippingAddress: json["shippingAddress"],
      status: json["status"],
      totalAmount: (json["totalAmount"] as num).toDouble(),
    );
  }
}

class ProductResponse {
  String id;
  String name;
  String imageURL;
  int quantity;
  double unitPrice;
  String configurations;
  ProductResponse({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.imageURL,
    required this.configurations,
    required this.quantity,
  });
  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json["id"],
      name: json["name"],
      unitPrice: (json["unitPrice"] as num).toDouble(),
      imageURL: json["imageURL"],
      configurations: json["configurations"],
      quantity: json["quantity"],
    );
  }
}
