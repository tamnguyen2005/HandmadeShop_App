import 'APIClient.dart';
import 'package:handmadeshop_app/models/Product/Product.dart';

class ProductService {
  final APIClient apiClient;
  ProductService(this.apiClient);
  Future<List<Product>> GetAllProduct() async {
    var response = await apiClient.get("/Product");
    if (response.isSuccess) {
      return response.data.map((p) => Product.fromJson(p)).toList();
    } else {
      return List.empty();
    }
  }

  Future<Product?> GetProductDetail(String Id) async {
    var response = await apiClient.get("/Product/$Id");
    if (response.isSuccess) {
      return Product.fromJson(response.data);
    } else {
      return null;
    }
  }
}
