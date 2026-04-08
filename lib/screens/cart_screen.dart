import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Order/CreateOrderRequest.dart';
import '../models/cart_item.dart';
import '../configurations/colors.dart';
import 'checkout_success_screen.dart';
import 'checkout_screen.dart';

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
  List<CartItem> _cartItems = [];
  List<bool> _selectedItems = [];
  bool _hasSelectionInteracted = false;

  @override
  void initState() {
    super.initState();
    _cartItems = _cloneItems(widget.cartItems);
    _selectedItems = List<bool>.filled(_cartItems.length, true, growable: true);
  }

  @override
  void didUpdateWidget(covariant CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_cartDataChanged(oldWidget.cartItems, widget.cartItems)) {
      _cartItems = _cloneItems(widget.cartItems);
    }
    _syncSelectionState();
  }

  bool _cartDataChanged(List<CartItem> oldItems, List<CartItem> newItems) {
    if (oldItems.length != newItems.length) return true;
    for (int i = 0; i < oldItems.length; i++) {
      final oldItem = oldItems[i];
      final newItem = newItems[i];
      if (oldItem.productId != newItem.productId || oldItem.quantity != newItem.quantity) {
        return true;
      }
    }
    return false;
  }

  List<CartItem> _cloneItems(List<CartItem> source) {
    return source
        .map((item) => CartItem(
              productId: item.productId,
              productName: item.productName,
              imageURL: item.imageURL,
              option: item.option,
              price: item.price,
              quantity: item.quantity,
            ))
        .toList();
  }

  void _notifyCartChanged() {
    widget.onUpdateCart(_cloneItems(_cartItems));
  }

  void _syncSelectionState() {
    if (_selectedItems.length != _cartItems.length) {
      final List<bool> next = List<bool>.filled(_cartItems.length, true, growable: true);
      final int carryLength = _selectedItems.length < next.length
          ? _selectedItems.length
          : next.length;
      for (int i = 0; i < carryLength; i++) {
        next[i] = _selectedItems[i];
      }
      _selectedItems = next;
    }

    if (!_hasSelectionInteracted &&
        _cartItems.isNotEmpty &&
        !_selectedItems.any((value) => value)) {
      _selectedItems = List<bool>.filled(_cartItems.length, true, growable: true);
    }
  }

  void _incrementQuantity(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    setState(() {
      _cartItems[index].quantity++;
    });
    _notifyCartChanged();
  }

  void _decrementQuantity(int index) {
    if (index < 0 || index >= _cartItems.length) return;

    if (_cartItems[index].quantity > 1) {
      setState(() {
        _cartItems[index].quantity--;
      });
      _notifyCartChanged();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số lượng tối thiểu là 1')),
      );
    }
  }

  void _removeItem(int index) {
    if (index < 0 || index >= _cartItems.length) return;
    
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
                _cartItems.removeAt(index);
                _selectedItems.removeAt(index);
              });
              _notifyCartChanged();
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

  Future<void> _checkoutSelectedItems() async {
    _syncSelectionState();

    final selectedIndexes = <int>[];
    final selectedCartItems = <CartItem>[];

    for (int i = 0; i < _cartItems.length; i++) {
      if (_selectedItems[i]) {
        selectedIndexes.add(i);
        selectedCartItems.add(_cartItems[i]);
      }
    }

    if (selectedCartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sản phẩm để thanh toán')),
      );
      return;
    }

    final double selectedTotalBeforeCheckout = _selectedTotalAmount;

    final result = await Navigator.push<CreateOrderRequest>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(items: selectedCartItems),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      for (final index in selectedIndexes.reversed) {
        _cartItems.removeAt(index);
        _selectedItems.removeAt(index);
      }
    });

    _notifyCartChanged();

    if (!mounted) return;
    final NumberFormat currencyFormatter = NumberFormat('#,###', 'vi_VN');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutSuccessScreen(
          paymentMethod: result.paymentMethod,
          totalAmountLabel: '${currencyFormatter.format(selectedTotalBeforeCheckout)}đ',
        ),
      ),
    );
  }

  double get _selectedTotalAmount {
    _syncSelectionState();
    double total = 0;
    for (int i = 0; i < _cartItems.length; i++) {
      if (_selectedItems[i]) {
        total += _cartItems[i].totalPrice;
      }
    }
    return total;
  }

  int get _selectedCount {
    _syncSelectionState();
    return _selectedItems.where((value) => value).length;
  }

  bool get _isAllSelected {
    _syncSelectionState();
    if (_selectedItems.isEmpty) return false;
    return _selectedItems.every((value) => value);
  }

  String _buildReference(CartItem item) {
    final refSource = item.productId.replaceAll('-', '').toUpperCase();
    final short = refSource.length >= 8 ? refSource.substring(0, 8) : refSource;
    return 'H0B7285$short';
  }

  String _buildColorLabel(CartItem item) {
    final category = (item.option ?? '').trim();
    if (category.isEmpty) return 'Nau vang';
    return category;
  }

  @override
  Widget build(BuildContext context) {
    _syncSelectionState();
    final NumberFormat currencyFormatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EF),
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: AppColors.textLight.withValues(alpha: 0.5),
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
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    color: const Color(0xFFEDEBE8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bạn có ${_cartItems.length} sản phẩm trong giỏ hàng',
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _cartItems.length,
                            separatorBuilder: (context, index) => const Divider(height: 14),
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return _buildCartItemRow(item, index, currencyFormatter);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 78,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _isAllSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      _hasSelectionInteracted = true;
                                      _selectedItems = List<bool>.filled(
                                        _cartItems.length,
                                        value ?? false,
                                        growable: true,
                                      );
                                    });
                                  },
                                  side: const BorderSide(color: Color(0xFFBEB8B3)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('Tất cả', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Tổng cộng(',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '$_selectedCount',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Text(
                                        '):',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${currencyFormatter.format(_selectedTotalAmount)}đ',
                                      style: const TextStyle(
                                        color: Color(0xFFA53D2B),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _selectedTotalAmount <= 0
                                ? null
                                : _checkoutSelectedItems,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFC5BDB7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Thanh toán'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItemRow(
    CartItem item,
    int index,
    NumberFormat currencyFormatter,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFE3E0DC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: item.imageURL.startsWith('http')
              ? Image.network(
                  item.imageURL,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.textLight,
                  ),
                )
              : const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.textLight,
                ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3C3A39),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Màu sắc: ${_buildColorLabel(item)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6E6B68)),
              ),
              const SizedBox(height: 2),
              Text(
                'Tham chiếu: ${_buildReference(item)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6E6B68)),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => _decrementQuantity(index),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E6E3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.remove, size: 16, color: AppColors.textPrimary),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 32,
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => _incrementQuantity(index),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E6E3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.add, size: 16, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  InkWell(
                    onTap: () => _removeItem(index),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF534F4B),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _selectedItems[index],
                  onChanged: (value) {
                    setState(() {
                      _hasSelectionInteracted = true;
                      _selectedItems[index] = value ?? false;
                    });
                  },
                  side: const BorderSide(color: Color(0xFFC0BCB7)),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 57),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '${currencyFormatter.format(item.totalPrice)}đ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF403E3C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
