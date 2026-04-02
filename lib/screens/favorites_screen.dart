import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/Product/Product.dart';
import '../components/product_card.dart';
import '../configurations/colors.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Product> favoriteProducts;
  final Function(Product) onToggleFavorite;
  final Function(Product) onAddToCart;
  final VoidCallback onExplorePressed;

  const FavoritesScreen({
    super.key,
    required this.favoriteProducts,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onExplorePressed,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late bool _isEmpty = widget.favoriteProducts.isEmpty;

  @override
  void didUpdateWidget(covariant FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _isEmpty = widget.favoriteProducts.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isEmpty
          ? _buildEmptyState()
          : CustomScrollView(
              slivers: [
                // Custom SliverAppBar
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  expandedHeight: 180,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            AppColors.background.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'SẢN PHẨM\nYÊU THÍCH',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        letterSpacing: 1,
                                        height: 1.2,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '${widget.favoriteProducts.length}',
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Những sản phẩm bạn đã yêu thích',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: 40,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Products Grid
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
                        final product = widget.favoriteProducts[index];
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
                                  onFavoriteToggle: () =>
                                      widget.onToggleFavorite(product),
                                  onAddToCart: () =>
                                      widget.onAddToCart(product),
                                ),
                              ),
                            );
                          },
                          onFavoritePressed: () =>
                              widget.onToggleFavorite(product),
                          onAddToCart: () => widget.onAddToCart(product),
                        );
                      },
                      childCount: widget.favoriteProducts.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Build Empty State with better design
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty Icon Container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  Icons.favorite_border,
                  size: 60,
                  color: AppColors.secondary.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Title
            Text(
              'Chưa có yêu thích',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Hãy khám phá những sản phẩm handmade độc đáo và thêm những yêu thích vào danh sách này',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            // Decorative Line
            Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 28),

            // CTA Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onExplorePressed,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'KHÁM PHÁ SẢN PHẨM',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
