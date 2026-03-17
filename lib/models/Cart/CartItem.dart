class CartItem {
  String productId;
  String productName;
  double price;
  String option;
  String imageURL;
  int quantity;
  CartItem({
    required this.productId,
    required this.productName,
    required this.imageURL,
    required this.option,
    required this.price,
    required this.quantity,
  });
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json["productId"],
      productName: json["productName"],
      imageURL: json["imageURL"],
      option: json["option"],
      price: (json["price"] as num).toDouble(),
      quantity: json["quantity"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "productName": productName,
      "imageURL": imageURL,
      "option": option,
      "price": price,
      "quantity": quantity,
    };
  }
}
