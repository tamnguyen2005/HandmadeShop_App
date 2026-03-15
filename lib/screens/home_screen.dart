import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../components/product_card.dart';
import '../components/banner_slider.dart';
import '../configurations/colors.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'collection_screen.dart';
import 'store_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Product> _favoriteProducts = [];
  final List<CartItem> _cartItems = [];

  // Mock data - sản phẩm mẫu
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Túi da xách tay',
      description: 'Túi da thủ công cao cấp, thiết kế sang trọng',
      price: 350000,
      imageUrl: 'https://example.com/bag1.jpg',
      category: 'Túi xách',
      isUnique: true,
      material: 'Da ý nguyên miếng',
    ),
    Product(
      id: '2',
      name: 'Túi đeo chéo hoa anh đào',
      description: 'Túi đeo chéo với họa tiết hoa anh đào tinh tế',
      price: 420000,
      imageUrl: 'https://example.com/bag2.jpg',
      category: 'Túi xách',
      isUnique: true,
      material: 'Da bò nguyên tấm',
    ),
    Product(
      id: '3',
      name: 'Ví da mini',
      description: 'Ví nhỏ gọn, tiện lợi cho phái đẹp',
      price: 180000,
      imageUrl: 'https://example.com/wallet1.jpg',
      category: 'Ví',
      isUnique: false,
      material: 'Da ý nguyên miếng',
    ),
    Product(
      id: '4',
      name: 'Túi tote da bò',
      description: 'Túi tote size lớn, phù hợp đi làm, đi học',
      price: 520000,
      imageUrl: 'https://example.com/bag3.jpg',
      category: 'Túi xách',
      isUnique: true,
      material: 'Da bò nguyên tấm',
    ),
    Product(
      id: '5',
      name: 'Ví dài nữ',
      description: 'Ví dài nhiều ngăn, thiết kế thanh lịch',
      price: 250000,
      imageUrl: 'https://example.com/wallet2.jpg',
      category: 'Ví',
      isUnique: false,
      material: 'Da ý nguyên miếng',
    ),
    Product(
      id: '6',
      name: 'Túi saddle bag',
      description: 'Túi yên ngựa phong cách vintage',
      price: 480000,
      imageUrl: 'https://example.com/bag4.jpg',
      category: 'Túi xách',
      isUnique: true,
      material: 'Da bò thuộc thủ công',
    ),
  ];

  void _toggleFavorite(Product product) {
    setState(() {
      if (_favoriteProducts.contains(product)) {
        _favoriteProducts.remove(product);
      } else {
        _favoriteProducts.add(product);
      }
    });
  }

  void _addToCart(Product product) {
    setState(() {
      final existingItem = _cartItems.firstWhere(
        (item) => item.product.id == product.id,
        orElse: () => CartItem(product: product, quantity: 0),
      );

      if (existingItem.quantity > 0) {
        existingItem.quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${product.name}" vào giỏ hàng'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          isFavorite: _favoriteProducts.contains(product),
          onFavoriteToggle: () => _toggleFavorite(product),
          onAddToCart: () => _addToCart(product),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          centerTitle: false,
          title: Image.asset(
            'assets/images/logo.png',
            height: 36,
            alignment: Alignment.centerLeft,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'ATELIER',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'Playfair Display',
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.primary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(
                      products: _products,
                      favoriteProducts: _favoriteProducts,
                      onToggleFavorite: _toggleFavorite,
                      onAddToCart: _addToCart,
                      onProductTap: _navigateToProductDetail,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Badge(
                isLabelVisible: _cartItems.isNotEmpty,
                label: Text('${_cartItems.length}'),
                child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(
                      cartItems: _cartItems,
                      onUpdateCart: (updatedItems) {
                        setState(() {
                          _cartItems
                            ..clear()
                            ..addAll(updatedItems);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border),
          ),
        ),

        // Banner Section
        SliverToBoxAdapter(
          child: BannerSlider(
            onExplorePressed: () {
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
        ),

        // Section Header - Featured Products
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sản phẩm nổi bật',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Products Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = _products[index];
              return ProductCard(
                product: product,
                isFavorite: _favoriteProducts.contains(product),
                onTap: () => _navigateToProductDetail(product),
                onFavoritePressed: () => _toggleFavorite(product),
                onAddToCart: () => _addToCart(product),
              );
            }, childCount: _products.length),
          ),
        ),

        // Bottom Padding
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          CollectionScreen(
            products: _products,
            favoriteProducts: _favoriteProducts,
            onToggleFavorite: _toggleFavorite,
            onAddToCart: _addToCart,
            onProductTap: _navigateToProductDetail,
          ),
          StoreScreen(
            products: _products,
            favoriteProducts: _favoriteProducts,
            onToggleFavorite: _toggleFavorite,
            onAddToCart: _addToCart,
            onProductTap: _navigateToProductDetail,
          ),
          FavoritesScreen(
            favoriteProducts: _favoriteProducts,
            onToggleFavorite: _toggleFavorite,
            onAddToCart: _addToCart,
          ),
          ProfileScreen(
            favoriteCount: _favoriteProducts.length,
            cartCount: _cartItems.length,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_mosaic_outlined),
            activeIcon: Icon(Icons.auto_awesome_mosaic),
            label: 'Bộ sưu tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Cửa hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
