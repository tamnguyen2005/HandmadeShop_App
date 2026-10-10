import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/Product/Product.dart';
import '../components/product_card.dart';
import '../components/banner_slider.dart';
import '../configurations/colors.dart';
import '../services/APIClient.dart';
import '../services/CartService.dart';
import '../services/ProductService.dart';
import '../services/SharedPreferencesService.dart';
import '../models/Cart/ShoppingCartRequest.dart';
import '../models/Cart/CartItem.dart' as api_cart;
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
  final ProductService _productService = ProductService(APIClient());
  final CartService _cartService = CartService(apiClient: APIClient());
  final List<Product> _favoriteProducts = [];
  final Set<String> _favoriteProductIds = {};
  final List<CartItem> _cartItems = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCart();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favoriteIds = await SharedPreferencesService().getFavoriteProductIds();
    if (!mounted) return;

    setState(() {
      _favoriteProductIds
        ..clear()
        ..addAll(favoriteIds);
    });

    _syncFavoriteProducts();
  }

  void _syncFavoriteProducts() {
    if (!mounted) return;
    setState(() {
      _favoriteProducts
        ..clear()
        ..addAll(
          _products.where((product) => _favoriteProductIds.contains(product.Id)),
        );
    });
  }

  Future<void> _loadCart() async {
    try {
      final cart = await _cartService.GetShoppingCart();
      if (!mounted || cart == null) return;
      setState(() {
        _cartItems
          ..clear()
          ..addAll(
            cart.items.map(
              (item) => CartItem(
                productId: item.productId,
                productName: item.productName,
                imageURL: item.imageURL,
                option: item.option,
                price: item.price,
                quantity: item.quantity,
              ),
            ),
          );
      });
    } catch (_) {
      // Keep local state if cart cannot be loaded yet.
    }
  }

  Future<void> _syncCartToServer() async {
    final items = _cartItems
        .map(
          (item) => api_cart.CartItem(
            productId: item.productId,
            productName: item.productName,
            imageURL: item.imageURL,
            option: item.option,
            price: item.price,
            quantity: item.quantity,
          ),
        )
        .toList();

    try {
      final ok = items.isEmpty
          ? await _cartService.DeleteShoppingCart()
          : await _cartService.UpdateShoppingCart(
              ShoppingCartRequest(userName: '', items: items),
            );

      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu giỏ hàng lên máy chủ'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể kết nối máy chủ để lưu giỏ hàng'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productService.GetAllProduct();
      if (!mounted) return;
      setState(() {
        _products = products;
      });
      _syncFavoriteProducts();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Khong the tai du lieu san pham. Vui long thu lai.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isFavorite(Product product) {
    return _favoriteProductIds.contains(product.Id);
  }

  void _toggleFavorite(Product product) {
    setState(() {
      if (_isFavorite(product)) {
        _favoriteProductIds.remove(product.Id);
      } else {
        _favoriteProductIds.add(product.Id);
      }
    });

    _syncFavoriteProducts();
    SharedPreferencesService().setFavoriteProductIds(_favoriteProductIds.toList());
  }

  void _addToCart(Product product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.productId == product.Id,
      );

      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(
          CartItem(
            productId: product.Id,
            productName: product.Name,
            imageURL: product.ImageURL,
            option: '',
            price: product.BasePrice,
            quantity: 1,
          ),
        );
      }
    });

    _syncCartToServer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Da them "${product.Name}" vao gio hang'),
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
          isFavorite: _isFavorite(product),
          onFavoriteToggle: () => _toggleFavorite(product),
          onAddToCart: _addToCart,
        ),
      ),
    );
  }

  void _openCartScreen() {
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
            _syncCartToServer();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingOrError() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: AppColors.textLight),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadProducts, child: const Text('Thu lai')),
            ],
          ),
        ),
      );
    }

    return const Center(
      child: Text(
        'Chua co san pham nao',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading || _errorMessage != null || _products.isEmpty) {
      return _buildLoadingOrError();
    }

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
                        _syncCartToServer();
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
              childAspectRatio: 0.74,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = _products[index];
              return ProductCard(
                product: product,
                isFavorite: _isFavorite(product),
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
            onCartPressed: _openCartScreen,
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
            onExplorePressed: () {
              setState(() {
                _currentIndex = 0;
              });
            },
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
