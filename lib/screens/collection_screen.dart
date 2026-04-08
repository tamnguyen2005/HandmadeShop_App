import 'dart:async';

import 'package:flutter/material.dart';

import '../configurations/colors.dart';
import '../models/Category/Category.dart';
import '../models/Category/CategoryDetail.dart';
import '../models/Product/Product.dart';
import '../services/APIClient.dart';
import '../services/CategoryService.dart';
import '../services/ProductService.dart';

class CollectionScreen extends StatefulWidget {
  final List<Product> products;
  final List<Product> favoriteProducts;
  final Function(Product) onToggleFavorite;
  final Function(Product) onAddToCart;
  final Function(Product) onProductTap;
  final VoidCallback onCartPressed;

  const CollectionScreen({
    super.key,
    required this.products,
    required this.favoriteProducts,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onProductTap,
    required this.onCartPressed,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final CategoryService _categoryService = CategoryService(apiClient: APIClient());
  final ProductService _productService = ProductService(APIClient());

  late final DateTime _launchAt;
  late Duration _remaining;
  Timer? _timer;

  // Category and Products state
  Category? _selectedCategory;
  CategoryDetail? _selectedCategoryDetail;
  List<Category> _categories = [];
  List<Product> _categoryProducts = [];
  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _launchAt = DateTime.now().add(
      const Duration(days: 5, hours: 23, minutes: 35, seconds: 5),
    );
    _remaining = _launchAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final duration = _launchAt.difference(DateTime.now());
      if (!mounted) return;
      setState(() {
        _remaining = duration.isNegative ? Duration.zero : duration;
      });
    });
    _loadCollections();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Product> get _collectionProducts {
    final filtered = widget.products.where((product) {
      final category = (product.CategoryName ?? '').toLowerCase();
      return category.contains('bo suu tap') ||
          category.contains('bộ sưu tập') ||
          category.contains('collection');
    }).toList();

    if (filtered.isNotEmpty) {
      return filtered;
    }
    return widget.products.take(6).toList();
  }

  bool _isFavorite(Product product) {
    return widget.favoriteProducts.any((item) => item.Id == product.Id);
  }

  Future<void> _loadCollections() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final collections = await _categoryService.GettAllCollection();
      if (!mounted) return;
      setState(() {
        _categories = collections;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _loadProductsByCategory(Category category) async {
    setState(() {
      _selectedCategory = category;
      _selectedCategoryDetail = null;
      _isLoadingProducts = true;
      _categoryProducts = [];
    });

    try {
      final detail = await _categoryService.GetCategoryById(category.id);
      final products = await _loadProductsForCollection(category, detail);
      if (!mounted) return;
      setState(() {
        _selectedCategoryDetail = detail;
        _categoryProducts = products;
      });
    } catch (_) {
      if (!mounted) return;

      // Fallback to local filtering if API fails.
      final filtered = widget.products.where((product) {
        final categoryName = (product.CategoryName ?? '').toLowerCase();
        return categoryName.contains(category.name.toLowerCase());
      }).toList();

      setState(() {
        _categoryProducts = filtered;
      });
    }

    if (!mounted) return;
    setState(() {
      _isLoadingProducts = false;
    });
  }

  Future<List<Product>> _loadProductsForCollection(
    Category category,
    CategoryDetail? detail,
  ) async {
    final categoryIds = <String>{category.id};
    for (final subCategory in detail?.categories ?? const <Category>[]) {
      if (subCategory.id.trim().isNotEmpty) {
        categoryIds.add(subCategory.id);
      }
    }

    final unique = <String, Product>{};
    for (final id in categoryIds) {
      final products = await _productService.GetProductByCategoryId(id);
      for (final product in products) {
        unique[product.Id] = product;
      }
    }

    return unique.values.toList();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory != null) {
      return _buildProductsModalView();
    }

    final days = _twoDigits(_remaining.inDays);
    final hours = _twoDigits(_remaining.inHours.remainder(24));
    final minutes = _twoDigits(_remaining.inMinutes.remainder(60));
    final seconds = _twoDigits(_remaining.inSeconds.remainder(60));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EE),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: const Text(
          'ATELIER',
          style: TextStyle(
            color: AppColors.primary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.primary),
          ),
          IconButton(
            onPressed: widget.onCartPressed,
            icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFF8D8680))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'BỘ SƯU TẬP',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFF8D8680))),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Phiên bản giới hạn',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLimitedSection(),
                  const SizedBox(height: 20),
                  Text(
                    'Sắp ra mắt',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildComingSoonSection(days, hours, minutes, seconds),
                  const SizedBox(height: 22),
                  Text(
                    'Bộ sưu tập hiện có',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoadingCategories)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            )
          else if (_categories.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Chưa có bộ sưu tập hiện có',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = _categories[index];
                    return _CategoryTile(
                      category: category,
                      onTap: () => _loadProductsByCategory(category),
                    );
                  },
                  childCount: _categories.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLimitedSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 186,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/Phienbangioihan.png', fit: BoxFit.cover),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Đang mở bán',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.93),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Chỉ còn 12 sản phẩm',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Khám phá ngay >',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonSection(
    String days,
    String hours,
    String minutes,
    String seconds,
  ) {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Sapramat.png', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                Colors.transparent,
                Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CountdownBox(label: 'Ngày', value: days),
                    const SizedBox(width: 4),
                    _CountdownBox(label: 'Giờ', value: hours),
                    const SizedBox(width: 4),
                    _CountdownBox(label: 'Phút', value: minutes),
                    const SizedBox(width: 4),
                    _CountdownBox(label: 'Giây', value: seconds),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Da bat nhac nho khi bo suu tap ra mat'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  icon: const Icon(Icons.notifications_active_outlined, size: 14),
                  label: const Text('Nhắc tôi khi ra mắt'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsModalView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EE),
      appBar: AppBar(
        titleSpacing: 12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            setState(() {
              _selectedCategory = null;
              _selectedCategoryDetail = null;
              _categoryProducts = [];
            });
          },
        ),
        title: Text(
          _selectedCategoryDetail?.name ?? _selectedCategory?.name ?? 'Bộ sưu tập',
          style: const TextStyle(
            color: AppColors.primary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.primary),
          ),
          IconButton(
            onPressed: widget.onCartPressed,
            icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
          ),
        ],
      ),
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _categoryProducts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 72,
                          color: AppColors.textLight,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Không có sản phẩm trong bộ sưu tập này',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.83,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _categoryProducts.length,
                  itemBuilder: (context, index) {
                    final product = _categoryProducts[index];
                    return _CollectionProductTile(
                      product: product,
                      isFavorite: _isFavorite(product),
                      onTap: () => widget.onProductTap(product),
                      onFavoriteTap: () => widget.onToggleFavorite(product),
                      onAddToCart: () => widget.onAddToCart(product),
                    );
                  },
                ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
  });

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              category.imageURL.startsWith('http')
                  ? Image.network(
                      category.imageURL,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.accent,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.category_outlined,
                          color: AppColors.textLight,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.accent,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.category_outlined,
                        color: AppColors.textLight,
                      ),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  const _CountdownBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 29,
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E4D6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _CollectionProductTile extends StatelessWidget {
  const _CollectionProductTile({
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onAddToCart,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.ImageURL.startsWith('http')
                        ? Image.network(
                            product.ImageURL,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.accent,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.textLight,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.accent,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.textLight,
                            ),
                          ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: onFavoriteTap,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white.withValues(alpha: 0.92),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFavorite ? AppColors.favorite : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Bộ sưu tập',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.Name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onAddToCart,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
