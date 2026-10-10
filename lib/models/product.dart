class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isUnique;
  final List<String> images;
  final String material;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isUnique = true,
    this.images = const [],
    this.material = 'Da ý nguyên miếng',
  });

  // Factory constructor để tạo từ JSON (cho sau này khi có backend)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      isUnique: json['isUnique'] as bool? ?? true,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      material: json['material'] as String? ?? 'Da ý nguyên miếng',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isUnique': isUnique,
      'images': images,
      'material': material,
    };
  }
}
