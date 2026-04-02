import 'APIClient.dart';
import 'package:handmadeshop_app/models/Product/Product.dart';

class ProductService {
  final APIClient apiClient;
  ProductService(this.apiClient);

  List<Product> _mockProducts() {
    return [
      Product(
        Id: 'mock-01',
        Name: 'Vong Tay Da Khac Ten',
        BasePrice: 189000,
        ImageURL:
            'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=900',
        CategoryName: 'Trang suc',
        Description: 'Vong tay da that, co the khac ten theo yeu cau.',
        StockQuantity: 25,
        StoryBehind: 'San pham thu cong phu hop lam qua tang ca nhan.',
      ),
      Product(
        Id: 'mock-02',
        Name: 'Tui Vai Canvas Theu Hoa',
        BasePrice: 349000,
        ImageURL:
            'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=900',
        CategoryName: 'Tui xach',
        Description: 'Tui canvas ben dep, theu hoa bang tay.',
        StockQuantity: 12,
        StoryBehind: 'Moi hoa tiet duoc theu thu cong trong 4 gio.',
      ),
      Product(
        Id: 'mock-03',
        Name: 'Nen Thom Oai Huong',
        BasePrice: 149000,
        ImageURL:
            'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=900',
        CategoryName: 'Nha cua doi song',
        Description: 'Nen sap dau nanh, mui oai huong diu nhe.',
        StockQuantity: 40,
        StoryBehind: 'Nen duoc do thu cong tung me nho de dam bao chat luong.',
      ),
      Product(
        Id: 'mock-04',
        Name: 'So Tay Bia Da Handmade',
        BasePrice: 229000,
        ImageURL:
            'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=900',
        CategoryName: 'Van phong pham',
        Description: 'So tay bia da mem, giay day va de viet.',
        StockQuantity: 18,
        StoryBehind: 'Phan bia duoc cat va khau tay boi nghe nhan dia phuong.',
      ),
    ];
  }

  List<Product> _mergeWithMocks(List<Product> products) {
    final result = [...products];
    final existingIds = result.map((p) => p.Id).toSet();
    for (final mock in _mockProducts()) {
      if (!existingIds.contains(mock.Id)) {
        result.add(mock);
      }
    }
    return result;
  }

  Future<List<Product>> GetAllProduct() async {
    var response = await apiClient.get("/Product");
    if (response.isSuccess) {
      final products =
          (response.data as List).map((p) => Product.fromJson(p)).toList();
      return _mergeWithMocks(products);
    } else {
      return _mockProducts();
    }
  }

  Future<Product?> GetProductDetail(String Id) async {
    final mock = _mockProducts().cast<Product?>().firstWhere(
      (p) => p?.Id == Id,
      orElse: () => null,
    );
    if (mock != null) {
      return mock;
    }

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
      final products =
          (response.data as List).map((j) => Product.fromJson(j)).toList();
      return _mergeWithMocks(products);
    } else {
      return _mockProducts();
    }
  }

  Future<List<Product>> GetProductByName(String name) async {
    var response = await apiClient.get("/Product?Name=$name");
    final keyword = name.trim().toLowerCase();
    final mockFiltered = _mockProducts().where((p) {
      return p.Name.toLowerCase().contains(keyword) ||
          (p.Description ?? '').toLowerCase().contains(keyword);
    }).toList();

    if (response.isSuccess) {
      final products =
          (response.data as List).map((j) => Product.fromJson(j)).toList();
      final merged = _mergeWithMocks(products);
      return merged.where((p) => p.Name.toLowerCase().contains(keyword)).toList();
    } else {
      return mockFiltered;
    }
  }
}
