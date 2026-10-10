import 'APIClient.dart';
import 'package:handmadeshop_app/models/Order/OrderResponse.dart';
import 'package:handmadeshop_app/models/Order/OrderDetailResponse.dart';
import 'package:handmadeshop_app/models/Order/CreateOrderRequest.dart';

class OrderService {
  APIClient apiClient;
  String? lastError;
  OrderService({required this.apiClient});
  Future<List<OrderResponse>> GetAllOrder() async {
    var response = await apiClient.get("/Order");
    if (response.isSuccess) {
      return (response.data as List)
          .map((o) => OrderResponse.fromJson(o))
          .toList();
    } else {
      return [];
    }
  }

  Future<OrderDetailResponse?> GetOrderById(String id) async {
    var response = await apiClient.get("/Order/$id");
    if (response.isSuccess) {
      return OrderDetailResponse.fromJson(response.data);
    } else {
      return null;
    }
  }

  Future<bool> CreateOrder(CreateOrderRequest request) async {
    var response = await apiClient.post("/Order", request.toJson());
    lastError = response.error;
    return response.isSuccess;
  }
}
