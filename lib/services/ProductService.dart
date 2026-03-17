import 'APIClient.dart';
import 'package:handmadeshop_app/models/Product/Product.dart';

class ProductService {
  final APIClient apiClient;
  ProductService(this.apiClient);
  Future<List<Product>> GetAllProduct() async {
    var response = await apiClient.get("/Product");
    if (response.isSuccess) {
      return (response.data as List).map((p) => Product.fromJson(p)).toList();
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

  Future<List<Product>> GetProductByCategoryId(String categoryId) async {
    var response = await apiClient.get("/Product?CategoryId=$categoryId");
    if (response.isSuccess) {
      return (response.data as List).map((j) => Product.fromJson(j)).toList();
    } else {
      return [];
    }
  }

  Future<List<Product>> GetProductByName(String name) async {
    var response = await apiClient.get("/Product?Name=$name");
    if (response.isSuccess) {
      return (response.data as List).map((j) => Product.fromJson(j)).toList();
    } else {
      return [];
    }
  }
}
