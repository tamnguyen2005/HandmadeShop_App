class Category {
  String id;
  String name;
  String imageURL;
  Category({required this.id, required this.name, required this.imageURL});
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"],
      name: json["name"],
      imageURL: json["imageURL"],
    );
  }
}
