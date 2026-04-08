import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Product/Product.dart';
import '../models/Product/ProductOption.dart';
import '../models/cart_item.dart';
import '../configurations/colors.dart';
import '../services/APIClient.dart';
import '../services/ProductService.dart';
import 'checkout_screen.dart';
import 'checkout_success_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final ValueChanged<Product> onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late PageController _imageController;
  int _currentImageIndex = 0;
  String? _selectedColor;
  String? _selectedSize;
  late bool _isFavorite;
  final ProductService _productService = ProductService(APIClient());
  Product? _detailProduct;
  List<Product> _relatedProducts = [];
  bool _isLoadingDetail = false;

  Product get _activeProduct => _detailProduct ?? widget.product;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    _isFavorite = widget.isFavorite;
    _loadDetailAndRelated();
  }

  Future<void> _loadDetailAndRelated() async {
    setState(() {
      _isLoadingDetail = true;
    });

    try {
      final detail = await _productService.GetProductDetail(widget.product.Id);
      final allProducts = await _productService.GetAllProduct();
      if (!mounted) return;

      final current = detail ?? widget.product;
      final related = allProducts
          .where((p) => p.Id != current.Id)
          .take(6)
          .toList();

      final colorOption = _getOptionByKeywords(
        current,
        const ['màu', 'mau', 'color'],
      );
      final sizeOption = _getOptionByKeywords(
        current,
        const ['size', 'kích', 'kich', 'cỡ', 'co'],
      );

      final defaultColor = (colorOption != null && colorOption.values.isNotEmpty)
          ? colorOption.values.first
          : null;
      final defaultSize = (sizeOption != null && sizeOption.values.isNotEmpty)
          ? sizeOption.values.first
          : null;

      setState(() {
        _detailProduct = current;
        _relatedProducts = related;
        _selectedColor = _selectedColor ?? defaultColor;
        _selectedSize = _selectedSize ?? defaultSize;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  ProductOption? _getOptionByKeywords(Product product, List<String> keywords) {
    if (product.ProductOptions == null) return null;
    try {
      return product.ProductOptions!.firstWhere(
        (opt) {
          final name = opt.name.toLowerCase();
          return keywords.any((keyword) => name.contains(keyword));
        },
      );
    } catch (e) {
      return null;
    }
  }

  ProductOption? _getColorOption() {
    return _getOptionByKeywords(
      _activeProduct,
      const ['màu', 'mau', 'color'],
    );
  }

  ProductOption? _getSizeOption() {
    return _getOptionByKeywords(
      _activeProduct,
      const ['size', 'kích', 'kich', 'cỡ', 'co'],
    );
  }

  String _buildSelectedOptionLabel() {
    final parts = <String>[];
    if ((_selectedColor ?? '').trim().isNotEmpty) {
      parts.add('Màu: ${_selectedColor!.trim()}');
    }
    if ((_selectedSize ?? '').trim().isNotEmpty) {
      parts.add('Size: ${_selectedSize!.trim()}');
    }
    return parts.join(' | ');
  }

  Future<void> _buyNow() async {
    final product = _activeProduct;
    final item = CartItem(
      productId: product.Id,
      productName: product.Name,
      imageURL: product.ImageURL,
      option: _buildSelectedOptionLabel(),
      price: product.BasePrice,
      quantity: 1,
    );
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(items: [item]),
      ),
    );

    if (!mounted || result == null) return;

    final totalLabel = '${NumberFormat('#,###', 'vi_VN').format(item.totalPrice)}đ';
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CheckoutSuccessScreen(
          paymentMethod: result.paymentMethod,
          totalAmountLabel: totalLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _activeProduct;
    final size = MediaQuery.of(context).size;
    final NumberFormat currencyFormatter = NumberFormat('#,###', 'vi_VN');
    final colorOption = _getColorOption();
    final sizeOption = _getSizeOption();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar - Minimal
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? AppColors.favorite : AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  widget.onFavoriteToggle();
                },
              ),
              const SizedBox(width: 12),
            ],
          ),

          // Image Carousel - Large section
          SliverToBoxAdapter(
            child: _buildImageCarousel(context, size),
          ),

          // Product Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE9E2DC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const SizedBox(height: 2),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.CategoryName?.trim().isNotEmpty == true
                              ? product.CategoryName!
                              : 'Handmade',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (product.StockQuantity != null)
                        Text(
                          'Còn ${product.StockQuantity} sản phẩm',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Product Name & Price Section
                  Text(
                    product.Name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    '${currencyFormatter.format(product.BasePrice)}đ',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _TrustChip(icon: Icons.local_shipping_outlined, label: 'Giao toàn quốc'),
                      _TrustChip(icon: Icons.verified_outlined, label: 'Handmade cao cấp'),
                      _TrustChip(icon: Icons.autorenew_outlined, label: 'Đổi trả 7 ngày'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Color Selection
                  if (colorOption != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildColorSelector(colorOption),
                    ),

                  if (sizeOption != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildSizeSelector(sizeOption),
                    ),

                  // Brief Description - Optional
                  if (product.Description != null && product.Description!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        product.Description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      height: 1,
                      color: AppColors.textLight.withValues(alpha: 0.15),
                    ),
                  ),

                  // Expansion Sections
                  _buildExpansionSection(
                    'Chi tiết sản phẩm',
                    product.Description ?? 'Sản phẩm thủ công cao cấp, chất lượng vàng từ các nghệ nhân lành nghề.',
                  ),
                  _buildExpansionSection(
                    'Bảo dưỡng',
                    'Nên vệ sinh bằng khăn mềm ẩm để duy trì độ mới của sản phẩm. Tránh tiếp xúc với nước quá lâu.',
                  ),
                  _buildExpansionSection(
                    'Giao và nhận hàng',
                    'Giao hàng toàn quốc trong 3-5 ngày làm việc. Hỗ trợ đổi trả trong 7 ngày nếu sản phẩm lỗi.',
                  ),
                  _buildExpansionSection(
                    'Quà tặng',
                    'Mỗi sản phẩm đi kèm bao bì cao cấp phù hợp làm quà tặng cho người thân.',
                  ),

                  const SizedBox(height: 18),

                  // Story Behind
                  if (product.StoryBehind != null && product.StoryBehind!.trim().isNotEmpty)
                    _buildStorybehind(),

                  if (product.StoryBehind != null && product.StoryBehind!.trim().isNotEmpty)
                    const SizedBox(height: 20),

                  // Related products from API
                  _buildRelatedProductsSection(),

                  const SizedBox(height: 92),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    widget.onAddToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Thêm vào giỏ'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _buyNow,
                  icon: const Icon(Icons.bolt_rounded),
                  label: const Text('Mua ngay'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context, Size size) {
    final imageHeight = size.height * 0.5; // 50% của màn hình
    return Stack(
      children: [
        Container(
          height: imageHeight.clamp(350.0, 500.0),
          width: double.infinity,
          color: AppColors.accent.withValues(alpha: 0.15),
          child: _isLoadingDetail
              ? const Center(child: CircularProgressIndicator())
              : PageView(
            controller: _imageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            children: [
              _buildImageWidget(_activeProduct.ImageURL),
              ...?_activeProduct.ProductOptions?.expand(
                (opt) => opt.values.map(
                  (val) => _buildImageWidget(_activeProduct.ImageURL),
                ),
              ),
            ],
          ),
        ),
        // Image indicators - Inside the image
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              1 + (_activeProduct.ProductOptions?.length ?? 0),
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return Container(
      color: AppColors.accent.withValues(alpha: 0.1),
      child: imageUrl.startsWith('http')
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: AppColors.textLight,
                  ),
                );
              },
            )
          : const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 100,
                color: AppColors.textLight,
              ),
            ),
    );
  }

  Widget _buildColorSelector(dynamic colorOption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Màu sắc',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: colorOption.values.map<Widget>((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textLight.withValues(alpha: 0.2),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      color: _getColorFromString(color),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 28)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    color,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(ProductOption sizeOption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kích thước',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: sizeOption.values.map((sizeValue) {
            final isSelected = _selectedSize == sizeValue;
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  _selectedSize = sizeValue;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textLight.withValues(alpha: 0.35),
                    width: isSelected ? 1.6 : 1,
                  ),
                ),
                child: Text(
                  sizeValue,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getColorFromString(String rawColor) {
    final input = rawColor.trim();

    // 1) Parse common hex formats from API, including text like "Nâu #8B5E3C".
    final hexMatch = RegExp(r'(#|0x)?[0-9a-fA-F]{6,8}').firstMatch(input);
    if (hexMatch != null) {
      final hexRaw = hexMatch.group(0)!.toLowerCase().replaceAll('#', '').replaceAll('0x', '');
      if (hexRaw.length == 6) {
        final value = int.tryParse('ff$hexRaw', radix: 16);
        if (value != null) return Color(value);
      }
      if (hexRaw.length == 8) {
        final value = int.tryParse(hexRaw, radix: 16);
        if (value != null) return Color(value);
      }
    }

    // 2) Parse rgb(r,g,b) strings.
    final rgbMatch = RegExp(r'rgb\s*\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)', caseSensitive: false).firstMatch(input);
    if (rgbMatch != null) {
      final r = int.tryParse(rgbMatch.group(1) ?? '0') ?? 0;
      final g = int.tryParse(rgbMatch.group(2) ?? '0') ?? 0;
      final b = int.tryParse(rgbMatch.group(3) ?? '0') ?? 0;
      return Color.fromARGB(
        255,
        r.clamp(0, 255),
        g.clamp(0, 255),
        b.clamp(0, 255),
      );
    }

    // 3) Fallback by Vietnamese/English color names (with/without accents).
    final normalized = input
        .toLowerCase()
        .replaceAll('đ', 'd')
        .replaceAll('à', 'a')
        .replaceAll('á', 'a')
        .replaceAll('ạ', 'a')
        .replaceAll('ả', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ầ', 'a')
        .replaceAll('ấ', 'a')
        .replaceAll('ậ', 'a')
        .replaceAll('ẩ', 'a')
        .replaceAll('ẫ', 'a')
        .replaceAll('ă', 'a')
        .replaceAll('ằ', 'a')
        .replaceAll('ắ', 'a')
        .replaceAll('ặ', 'a')
        .replaceAll('ẳ', 'a')
        .replaceAll('ẵ', 'a')
        .replaceAll('è', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ẹ', 'e')
        .replaceAll('ẻ', 'e')
        .replaceAll('ẽ', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ề', 'e')
        .replaceAll('ế', 'e')
        .replaceAll('ệ', 'e')
        .replaceAll('ể', 'e')
        .replaceAll('ễ', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('í', 'i')
        .replaceAll('ị', 'i')
        .replaceAll('ỉ', 'i')
        .replaceAll('ĩ', 'i')
        .replaceAll('ò', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ọ', 'o')
        .replaceAll('ỏ', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ồ', 'o')
        .replaceAll('ố', 'o')
        .replaceAll('ộ', 'o')
        .replaceAll('ổ', 'o')
        .replaceAll('ỗ', 'o')
        .replaceAll('ơ', 'o')
        .replaceAll('ờ', 'o')
        .replaceAll('ớ', 'o')
        .replaceAll('ợ', 'o')
        .replaceAll('ở', 'o')
        .replaceAll('ỡ', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('ú', 'u')
        .replaceAll('ụ', 'u')
        .replaceAll('ủ', 'u')
        .replaceAll('ũ', 'u')
        .replaceAll('ư', 'u')
        .replaceAll('ừ', 'u')
        .replaceAll('ứ', 'u')
        .replaceAll('ự', 'u')
        .replaceAll('ử', 'u')
        .replaceAll('ữ', 'u')
        .replaceAll('ỳ', 'y')
        .replaceAll('ý', 'y')
        .replaceAll('ỵ', 'y')
        .replaceAll('ỷ', 'y')
        .replaceAll('ỹ', 'y');

    final namedColors = <String, Color>{
      'xanh': const Color(0xFF4A90E2),
      'blue': const Color(0xFF4A90E2),
      'xanh la': const Color(0xFF6ABF69),
      'xanh lam': const Color(0xFF4A90E2),
      'do': const Color(0xFFE74C3C),
      'red': const Color(0xFFE74C3C),
      'nau': const Color(0xFF8B6F47),
      'brown': const Color(0xFF8B6F47),
      'trang': const Color(0xFFEDEDED),
      'white': const Color(0xFFEDEDED),
      'den': const Color(0xFF2D2D2D),
      'black': const Color(0xFF2D2D2D),
      'cam': const Color(0xFFFF9F43),
      'orange': const Color(0xFFFF9F43),
      'tim': const Color(0xFF9B59B6),
      'purple': const Color(0xFF9B59B6),
      'vang': const Color(0xFFF1C40F),
      'yellow': const Color(0xFFF1C40F),
      'hong': const Color(0xFFEB7CB7),
      'pink': const Color(0xFFEB7CB7),
      'xam': const Color(0xFFB0B0B0),
      'gray': const Color(0xFFB0B0B0),
      'grey': const Color(0xFFB0B0B0),
    };

    for (final entry in namedColors.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return const Color(0xFFBDBDBD);
  }

  Widget _buildExpansionSection(String title, String content) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textLight.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          collapsedIconColor: AppColors.textSecondary,
          iconColor: AppColors.primary,
          tilePadding: const EdgeInsets.symmetric(vertical: 4),
          childrenPadding: const EdgeInsets.only(bottom: 16, top: 4),
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorybehind() {
    final product = _activeProduct;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.textLight.withValues(alpha: 0.12),
              ),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 16),
          child: const Text(
            'Câu chuyện đằng sau',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          product.StoryBehind ?? '',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductsSection() {
    final NumberFormat currencyFormatter = NumberFormat('#,###', 'vi_VN');

    if (_relatedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sản phẩm liên quan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _relatedProducts.length,
            itemBuilder: (context, index) {
              final related = _relatedProducts[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: _buildProductCard(
                  related,
                  '${currencyFormatter.format(related.BasePrice)}đ',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product item, String priceLabel) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: item,
              isFavorite: false,
              onFavoriteToggle: () {},
              onAddToCart: widget.onAddToCart,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageWidget(item.ImageURL),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.Name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            priceLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFEDE4DD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
