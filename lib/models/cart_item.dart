class CartItem {
  final String productId;
  final String productName;
  final double price;
  final String option;
  final String imageURL;
  int quantity;
  
  CartItem({
    required String productId,
    required String productName,
    required String imageURL,
    String option = '',
    required double price,
    required int quantity,
  })  : productId = productId.isEmpty ? 'unknown' : productId,
        productName = productName.isEmpty ? 'San pham' : productName,
        imageURL = imageURL,
        option = option,
        price = price <= 0 ? 0.0 : price,
        quantity = quantity <= 0 ? 1 : quantity;

  double get totalPrice => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: (json["productId"] ?? '') as String,
      productName: (json["productName"] ?? '') as String,
      imageURL: (json["imageURL"] ?? '') as String,
      option: (json["option"] ?? '') as String,
      price: ((json["price"] ?? 0) as num).toDouble(),
      quantity: (json["quantity"] ?? 1) as int,
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
