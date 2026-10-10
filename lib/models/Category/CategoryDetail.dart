import 'Category.dart';

class CategoryDetail {
  String id;
  String name;
  String imageURL;
  List<Category> categories;
  CategoryDetail({
    required this.id,
    required this.name,
    required this.imageURL,
    required this.categories,
  });
  factory CategoryDetail.fromJson(Map<String, dynamic> json) {
    return CategoryDetail(
      id: json["id"],
      name: json["name"],
      imageURL: json["imageURL"],
      categories: json["subCategory"] != null
          ? (json["subCategory"] as List)
                .map((j) => Category.fromJson(j))
                .toList()
          : [],
    );
  }
}
