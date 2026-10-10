class ProductOption {
  String name;
  List<String> values;
  ProductOption({required this.name, required this.values});
  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      name: json["name"],
      values: json["values"] != null ? List<String>.from(json["values"]) : [],
    );
  }
}
