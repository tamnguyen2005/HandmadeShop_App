import 'package:flutter/material.dart';
import '../components/product_card.dart';
import '../configurations/colors.dart';
import '../models/Product/Product.dart';

class CollectionScreen extends StatelessWidget {
  final List<Product> products;
  final List<Product> favoriteProducts;
  final Function(Product) onToggleFavorite;
  final Function(Product) onAddToCart;
  final Function(Product) onProductTap;

  const CollectionScreen({
    super.key,
    required this.products,
    required this.favoriteProducts,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Product> uniqueProducts = products
        .where((product) => (product.StockQuantity ?? 0) <= 1)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ sưu tập'),
        automaticallyImplyLeading: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFAEAD7), Color(0xFFF1D8B5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mùa Xuân Atelier',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Khám phá các thiết kế thủ công giới hạn, tập trung vào chất liệu da tự nhiên và chi tiết độc bản.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Thiết kế độc bản',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = uniqueProducts[index];
                return ProductCard(
                  product: product,
                  isFavorite: favoriteProducts.contains(product),
                  onTap: () => onProductTap(product),
                  onFavoritePressed: () => onToggleFavorite(product),
                  onAddToCart: () => onAddToCart(product),
                );
              }, childCount: uniqueProducts.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
