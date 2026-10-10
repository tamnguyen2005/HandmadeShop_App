import 'package:handmadeshop_app/models/Product/ProductOption.dart';

class Product {
  String Id;
  String Name;
  String? Description;
  String? StoryBehind;
  int? StockQuantity;
  double BasePrice;
  String ImageURL;
  String? CategoryName;
  List<ProductOption>? ProductOptions;
  List<String>? SubImages;

  Product({
    required this.Id,
    required this.Name,
    required this.BasePrice,
    required this.ImageURL,
    this.CategoryName,
    this.Description,
    this.StockQuantity,
    this.StoryBehind,
    this.ProductOptions,
    this.SubImages,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      Id: json["id"],
      Name: json["name"],
      BasePrice: (json["basePrice"] as num).toDouble(),
      ImageURL: json["imageURL"],
      StockQuantity: json["stockQuantity"] ?? 0,
      CategoryName: json["categoryName"] ?? "",
      Description: json["description"] ?? "",
      StoryBehind: json["storyBehind"] ?? "",
      SubImages: json["subImages"] != null
          ? List<String>.from(json["subImages"] as List)
          : [],
      ProductOptions: json["options"] != null
          ? (json["options"] as List)
                .map((j) => ProductOption.fromJson(j))
                .toList()
          : [],
    );
  }
}
