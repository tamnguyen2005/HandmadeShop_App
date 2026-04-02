import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  String _normalizeCategory(String? value) {
    final normalized = (value ?? '').trim();
    return normalized.isEmpty ? 'Khác' : normalized;
  }

  List<String> get _categories {
    final dynamicCategories = widget.products
        .map((p) => _normalizeCategory(p.CategoryName))
        .toSet()
        .toList();
    return ['Tất cả', ...dynamicCategories];
  }

  List<Product> get _filteredProducts {
    return widget.products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Tất cả' ||
          _normalizeCategory(product.CategoryName) == _selectedCategory;
      final matchesQuery = product.Name.toLowerCase().contains(
        _query.toLowerCase(),
      );
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    AppColors.background.withValues(alpha: 0.35),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cửa hàng',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bộ sưu tập sản phẩm handmade cao cấp',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm sản phẩm...',
                      hintStyle: GoogleFonts.lato(
                        color: AppColors.textLight,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Text(
                                category,
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: _categories.length,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Products Grid
          if (_filteredProducts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: AppColors.textLight.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy sản phẩm',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy thử tìm kiếm từ khác',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(
                      product: product,
                      isFavorite: widget.favoriteProducts.any((p) => p.Id == product.Id),
                      onTap: () => widget.onProductTap(product),
                      onFavoritePressed: () =>
                          widget.onToggleFavorite(product),
                      onAddToCart: () => widget.onAddToCart(product),
                    );
                  },
                  childCount: _filteredProducts.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
