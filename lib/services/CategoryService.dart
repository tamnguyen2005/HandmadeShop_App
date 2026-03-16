import 'APIClient.dart';
import 'package:handmadeshop_app/models/Category/Category.dart';
import 'package:handmadeshop_app/models/Category/CategoryDetail.dart';

class CategoryService {
  APIClient apiClient;
  CategoryService({required this.apiClient});
  Future<List<Category>> GetAllCategory() async {
    var response = await apiClient.get("/Category");
    if (response.isSuccess) {
      return (response.data as List).map((c) => Category.fromJson(c)).toList();
    } else {
      return [];
    }
  }

  Future<List<Category>> GettAllCollection() async {
    var response = await apiClient.get("/Category/Collection");
    if (response.isSuccess) {
      return (response.data as List).map((c) => Category.fromJson(c)).toList();
    } else {
      return [];
    }
  }

  Future<CategoryDetail?> GetCategoryById(String id) async {
    var response = await apiClient.get("/Category/$id");
    if (response.isSuccess) {
      return CategoryDetail.fromJson(response.data);
    } else {
      return null;
    }
  }
}
