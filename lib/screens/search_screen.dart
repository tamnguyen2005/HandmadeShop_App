import 'package:flutter/material.dart';
import '../models/Product/Product.dart';
import '../components/product_card.dart';
import '../configurations/colors.dart';

class SearchScreen extends StatefulWidget {
  final List<Product> products;
  final List<Product> favoriteProducts;
  final Function(Product) onToggleFavorite;
  final Function(Product) onAddToCart;
  final Function(Product) onProductTap;

  const SearchScreen({
    super.key,
    required this.products,
    required this.favoriteProducts,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onProductTap,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  List<Product> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return widget.products
        .where(
          (p) =>
              p.Name.toLowerCase().contains(q) ||
              (p.Description ?? '').toLowerCase().contains(q) ||
              (p.CategoryName ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            hintStyle: const TextStyle(color: AppColors.textLight),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textLight),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _query = '';
                });
              },
            )
          else
            const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body:
          _query.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search,
                      size: 72,
                      color: AppColors.textLight.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nhập từ khóa để tìm kiếm',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              )
              : _results.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 72,
                      color: AppColors.textLight.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy kết quả cho "$_query"',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      '${_results.length} kết quả',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final product = _results[index];
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
