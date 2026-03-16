import 'CartItem.dart';

class ShoppingCartResponse {
  String userName;
  double totalPrice;
  List<CartItem> items;
  ShoppingCartResponse({
    required this.userName,
    required this.totalPrice,
    required this.items,
  });
  factory ShoppingCartResponse.fromJson(Map<String, dynamic> json) {
    return ShoppingCartResponse(
      userName: json["userName"],
      totalPrice: (json["totalPrice"] as num).toDouble(),
      items: json["items"] != null
          ? (json["items"] as List).map((j) => CartItem.fromJson(j)).toList()
          : [],
    );
  }
}
