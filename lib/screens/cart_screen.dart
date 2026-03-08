import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart';
import '../components/cart_item_card.dart';
import '../components/custom_button.dart';
import '../configurations/colors.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(List<CartItem>) onUpdateCart;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onUpdateCart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _incrementQuantity(int index) {
    setState(() {
      widget.cartItems[index].quantity++;
    });
    widget.onUpdateCart(widget.cartItems);
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (widget.cartItems[index].quantity > 1) {
        widget.cartItems[index].quantity--;
      } else {
        _removeItem(index);
      }
    });
    widget.onUpdateCart(widget.cartItems);
  }

  void _removeItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.cartItems.removeAt(index);
              });
              widget.onUpdateCart(widget.cartItems);
              Navigator.pop(context);
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  double get _totalAmount {
    return widget.cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        automaticallyImplyLeading: false,
        actions: [
          if (widget.cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            widget.cartItems.clear();
                          });
                          widget.onUpdateCart(widget.cartItems);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Xóa tất cả',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Xóa tất cả',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: widget.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: AppColors.textLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Giỏ hàng trống',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy thêm sản phẩm vào giỏ hàng',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      return CartItemCard(
                        cartItem: widget.cartItems[index],
                        onIncrement: () => _incrementQuantity(index),
                        onDecrement: () => _decrementQuantity(index),
                        onRemove: () => _removeItem(index),
                      );
                    },
                  ),
                ),
                // Summary Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tạm tính:',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${currencyFormatter.format(_totalAmount)}đ',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Phí vận chuyển:',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Miễn phí',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng cộng:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${currencyFormatter.format(_totalAmount)}đ',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Thanh toán',
                          icon: Icons.payment,
                          width: double.infinity,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chức năng thanh toán đang được phát triển'),
                                backgroundColor: AppColors.info,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
