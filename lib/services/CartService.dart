import 'APIClient.dart';
import 'package:handmadeshop_app/models/Cart/ShoppingCartResponse.dart';
import 'package:handmadeshop_app/models/Cart/ShoppingCartRequest.dart';

class CartService {
  APIClient apiClient;
  CartService({required this.apiClient});
  Future<ShoppingCartResponse?> GetShoppingCart() async {
    var response = await apiClient.get("/Cart");
    if (response.isSuccess) {
      return ShoppingCartResponse.fromJson(response.data);
    } else {
      return null;
    }
  }

  Future<bool> UpdateShoppingCart(ShoppingCartRequest request) async {
    var response = await apiClient.post("/Cart", request.toJson());
    return response.isSuccess;
  }

  Future<bool> DeleteShoppingCart() async {
    var response = await apiClient.delete("/Cart", {});
    return response.isSuccess;
  }
}
