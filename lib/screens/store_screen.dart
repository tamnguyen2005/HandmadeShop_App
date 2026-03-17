import 'package:flutter/material.dart';
import '../components/product_card.dart';
import '../configurations/colors.dart';
import '../models/Product/Product.dart';

class StoreScreen extends StatefulWidget {
  final List<Product> products;
  final List<Product> favoriteProducts;
  final Function(Product) onToggleFavorite;
  final Function(Product) onAddToCart;
  final Function(Product) onProductTap;

  const StoreScreen({
    super.key,
    required this.products,
    required this.favoriteProducts,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onProductTap,
  });

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _query = '';
  String _selectedCategory = 'Tất cả';

  List<String> get _categories {
    final dynamicCategories = widget.products
        .map((p) => p.CategoryName ?? 'Khac')
        .toSet()
        .toList();
    return ['Tất cả', ...dynamicCategories];
  }

  List<Product> get _filteredProducts {
    return widget.products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Tất cả' ||
          (product.CategoryName ?? 'Khac') == _selectedCategory;
      final matchesQuery = product.Name.toLowerCase().contains(
        _query.toLowerCase(),
      );
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa hàng'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm theo tên sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final bool selected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _categories.length,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy sản phẩm phù hợp',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(
                        product: product,
                        isFavorite: widget.favoriteProducts.contains(product),
                        onTap: () => widget.onProductTap(product),
                        onFavoritePressed: () =>
                            widget.onToggleFavorite(product),
                        onAddToCart: () => widget.onAddToCart(product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
