import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Product/Product.dart';
import '../models/Product/ProductOption.dart';
import '../configurations/colors.dart';
import '../components/custom_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;

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

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  ProductOption? _getColorOption() {
    if (widget.product.ProductOptions == null) return null;
    try {
      return widget.product.ProductOptions!.firstWhere(
        (opt) => opt.name.toLowerCase().contains('màu') || opt.name.toLowerCase().contains('color'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final NumberFormat currencyFormatter = NumberFormat('#,###', 'vi_VN');
    final colorOption = _getColorOption();

    return Scaffold(
      backgroundColor: Colors.white,
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
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.isFavorite ? AppColors.favorite : AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                onPressed: widget.onFavoriteToggle,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Product Name & Price Section
                  Text(
                    widget.product.Name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    '${currencyFormatter.format(widget.product.BasePrice)}đ',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Color Selection
                  if (colorOption != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildColorSelector(colorOption),
                    ),

                  // Brief Description - Optional
                  if (widget.product.Description != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        widget.product.Description!,
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      height: 1,
                      color: AppColors.textLight.withValues(alpha: 0.15),
                    ),
                  ),

                  // Expansion Sections
                  _buildExpansionSection(
                    'Chi tiết sản phẩm',
                    widget.product.Description ?? 'Sản phẩm thủ công cao cấp, chất lượng vàng từ các nghệ nhân lành nghề.',
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

                  const SizedBox(height: 28),

                  // Story Behind
                  if (widget.product.StoryBehind != null)
                    _buildStorybehind(),

                  if (widget.product.StoryBehind != null)
                    const SizedBox(height: 32),

                  // Related Products Section - Accessories
                  _buildRelatedProductsSection(),

                  const SizedBox(height: 36),

                  // Suggested Products Section - Continue Exploring
                  _buildSuggestedProductsSection(),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          child: CustomButton(
            text: 'Thêm vào giỏ hàng',
            icon: Icons.shopping_bag_outlined,
            onPressed: () {
              widget.onAddToCart();
              Navigator.pop(context);
            },
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
          child: PageView(
            controller: _imageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            children: [
              _buildImageWidget(widget.product.ImageURL),
              ...?widget.product.ProductOptions
                  ?.expand((opt) =>
                      opt.values.map((val) => _buildImageWidget(widget.product.ImageURL)))
                  .toList(),
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
              1 + (widget.product.ProductOptions?.length ?? 0),
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

  Color _getColorFromString(String colorName) {
    final colors = {
      'xanh': const Color(0xFFB8E6D5),
      'xanh lam': const Color(0xFFB8E6D5),
      'đỏ': const Color(0xFFFF6B6B),
      'nâu': const Color(0xFF8B6F47),
      'trắng': const Color(0xFFE8E8E8),
      'đen': const Color(0xFF2D2D2D),
      'cam': const Color(0xFFFF9F43),
      'tím': const Color(0xFFEE5A6F),
    };
    return colors[colorName.toLowerCase()] ?? Colors.grey;
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
          widget.product.StoryBehind!,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phụ kiến đi kèm',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            itemBuilder: (context, index) {
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: _buildProductCard(index, 'Phụ kiến ${index + 1}', '150.000'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiếp tục khám phá',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return _buildProductCard(index, 'Sản phẩm ${index + 1}', '${(index + 1) * 100}.000');
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(int index, String name, String price) {
    return GestureDetector(
      onTap: () {},
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
              child: Center(
                child: Image.asset(
                  'assets/icons/shopping_bag.png',
                  width: 50,
                  height: 50,
                  color: AppColors.textLight,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.shopping_bag_outlined,
                      size: 50,
                      color: AppColors.textLight.withValues(alpha: 0.5),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
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
            '${price}đ',
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
