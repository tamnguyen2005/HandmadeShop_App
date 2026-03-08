import 'package:flutter/material.dart';
import '../models/product.dart';
import '../components/product_card.dart';
import '../configurations/colors.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Product> favoriteProducts;
  final Function(Product) onToggleFavorite;
  final Function(Product) onAddToCart;

  const FavoritesScreen({
    super.key,
    required this.favoriteProducts,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        automaticallyImplyLeading: false,
      ),
      body: favoriteProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: AppColors.textLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có sản phẩm yêu thích',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy thêm sản phẩm bạn yêu thích',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return ProductCard(
                  product: product,
                  isFavorite: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          product: product,
                          isFavorite: true,
                          onFavoriteToggle: () => onToggleFavorite(product),
                          onAddToCart: () => onAddToCart(product),
                        ),
                      ),
                    );
                  },
                  onFavoritePressed: () => onToggleFavorite(product),
                  onAddToCart: () => onAddToCart(product),
                );
              },
            ),
    );
  }
}
