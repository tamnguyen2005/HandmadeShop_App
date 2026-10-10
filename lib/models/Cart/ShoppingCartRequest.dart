import 'CartItem.dart';

class ShoppingCartRequest {
  String userName;
  List<CartItem> items;
  ShoppingCartRequest({required this.userName, required this.items});
  Map<String, dynamic> toJson() {
    return {
      "userName": userName,
      "items": items.map((i) => i.toJson()).toList(),
    };
  }
}
