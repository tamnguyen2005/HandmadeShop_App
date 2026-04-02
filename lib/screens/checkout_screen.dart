import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configurations/colors.dart';
import '../models/Coupon/Coupon.dart';
import '../models/Order/CreateOrderRequest.dart';
import '../models/User/UserInfo.dart';
import '../models/cart_item.dart';
import '../services/APIClient.dart';
import '../services/CouponService.dart';
import '../services/OrderService.dart';
import '../services/SharedPreferencesService.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.items,
  });

  final List<CartItem> items;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();

  final CouponService _couponService = CouponService(apiClient: APIClient());
  final OrderService _orderService = OrderService(apiClient: APIClient());

  String _paymentMethod = 'momo';
  bool _isSubmitting = false;
  bool _isLoadingDefaults = true;
  bool _isLoadingCoupons = true;
  bool _useDifferentInfo = false;
  bool _couponExpanded = false;
  bool _manualCouponMode = false;

  String _defaultReceiver = '';
  String _defaultPhone = '';
  String _defaultAddress = '';
  List<Coupon> _coupons = [];
  Coupon? _selectedCoupon;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
    _loadCoupons();
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  double get _itemsTotal {
    double total = 0;
    for (final item in widget.items) {
      total += item.totalPrice;
    }
    return total;
  }

  double get _discountAmount {
    if (_selectedCoupon == null) return 0;
    if (_itemsTotal < _selectedCoupon!.minOrderAmount) return 0;
    return _itemsTotal * (_selectedCoupon!.value / 100);
  }

  double get _finalTotal {
    final total = _itemsTotal - _discountAmount;
    return total < 0 ? 0 : total;
  }

  Future<void> _loadDefaults() async {
    setState(() {
      _isLoadingDefaults = true;
    });

    final prefs = SharedPreferencesService();
    final UserInfo user = await prefs.getUserInfo();
    final shipping = await prefs.getDefaultShippingInfo();

    final receiver = shipping['receiver']?.trim().isNotEmpty == true
        ? shipping['receiver']!.trim()
        : user.fullname.trim();
    final phone = shipping['phone']?.trim() ?? '';
    final address = shipping['address']?.trim() ?? '';

    if (!mounted) return;
    setState(() {
      _defaultReceiver = receiver;
      _defaultPhone = phone;
      _defaultAddress = address;

      _receiverController.text = receiver;
      _phoneController.text = phone;
      _addressController.text = address;

      _useDifferentInfo = false;
      if (_defaultReceiver.isEmpty || _defaultPhone.isEmpty || _defaultAddress.isEmpty) {
        _useDifferentInfo = true;
      }
      _isLoadingDefaults = false;
    });
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _isLoadingCoupons = true;
    });

    try {
      final coupons = await _couponService.GetAllCoupon();
      if (!mounted) return;
      setState(() {
        _coupons = coupons;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _coupons = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCoupons = false;
        });
      }
    }
  }

  String get _activeReceiver => _useDifferentInfo ? _receiverController.text.trim() : _defaultReceiver;
  String get _activePhone => _useDifferentInfo ? _phoneController.text.trim() : _defaultPhone;
  String get _activeAddress => _useDifferentInfo ? _addressController.text.trim() : _defaultAddress;

  Future<void> _submitOrder() async {
    final receiver = _activeReceiver;
    final phone = _activePhone;
    final address = _activeAddress;

    if (receiver.isEmpty || phone.isEmpty || address.isEmpty) {
      setState(() {
        _useDifferentInfo = true;
      });
      _showSnack('Thiếu thông tin nhận hàng, vui lòng bổ sung đầy đủ');
      return;
    }

    if (_selectedCoupon != null && _itemsTotal < _selectedCoupon!.minOrderAmount) {
      _showSnack('Mã ưu đãi chưa đạt giá trị đơn tối thiểu');
      return;
    }

    final couponCode = _manualCouponMode
        ? _couponController.text.trim()
        : (_selectedCoupon?.id ?? '');

    await SharedPreferencesService().setDefaultShippingInfo(
      receiver: receiver,
      phone: phone,
      address: address,
    );

    final request = CreateOrderRequest(
      items: widget.items
          .map(
            (item) => OrderItem(
              productId: item.productId,
              quantity: item.quantity,
              configuration: item.option,
            ),
          )
          .toList(),
      paymentMethod: _paymentMethod,
      receiverName: receiver,
      phoneNumber: phone,
          address: address,
          couponCode: couponCode.isEmpty ? null : couponCode,
    );

    setState(() {
      _isSubmitting = true;
    });

    final ok = await _orderService.CreateOrder(request);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _isSubmitting = false;
      });
      _showSnack(_orderService.lastError ?? 'Đặt hàng thất bại. Vui lòng thử lại.');
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    Navigator.of(context).pop(request);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EF),
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin nhận hàng',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoadingDefaults)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(minHeight: 2),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE6DFDA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              const Text(
                                'Thông tin mặc định',
                                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _useDifferentInfo = !_useDifferentInfo;
                                  });
                                },
                                child: Text(_useDifferentInfo ? 'Dùng mặc định' : 'Nhập thông tin khác'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Người nhận: ${_defaultReceiver.isEmpty ? '(chưa có)' : _defaultReceiver}'),
                          Text('Số điện thoại: ${_defaultPhone.isEmpty ? '(chưa có)' : _defaultPhone}'),
                          Text('Địa chỉ: ${_defaultAddress.isEmpty ? '(chưa có)' : _defaultAddress}'),
                          if (_defaultReceiver.isEmpty || _defaultPhone.isEmpty || _defaultAddress.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Thiếu thông tin mặc định, vui lòng nhập thông tin bên dưới.',
                                style: TextStyle(color: AppColors.error, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),

                  if (_useDifferentInfo) ...[
                    const SizedBox(height: 10),
                    _CheckoutField(
                      controller: _receiverController,
                      label: 'Người nhận *',
                    ),
                    const SizedBox(height: 10),
                    _CheckoutField(
                      controller: _phoneController,
                      label: 'Số điện thoại *',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _CheckoutField(
                      controller: _addressController,
                      label: 'Địa chỉ giao hàng *',
                      maxLines: 2,
                    ),
                  ],

                  const SizedBox(height: 10),
                  _CheckoutField(
                    controller: _noteController,
                    label: 'Ghi chú (tuỳ chọn)',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE6DFDA)),
                    ),
                    child: ExpansionTile(
                      initiallyExpanded: _couponExpanded,
                      onExpansionChanged: (value) {
                        setState(() {
                          _couponExpanded = value;
                        });
                      },
                      title: const Text(
                        'Mã giảm giá',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _selectedCoupon != null
                            ? 'Đang chọn: ${_selectedCoupon!.id}'
                            : (_manualCouponMode && _couponController.text.trim().isNotEmpty
                                ? 'Đã nhập mã: ${_couponController.text.trim()}'
                                : 'Nhấn để chọn hoặc nhập mã'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      children: [
                        if (_isLoadingCoupons)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        else ...[
                          if (_coupons.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _coupons.map((coupon) {
                                final selected = _selectedCoupon?.id == coupon.id && !_manualCouponMode;
                                return ChoiceChip(
                                  selected: selected,
                                  label: Text('${coupon.id} (-${coupon.value}%)'),
                                  onSelected: (_) {
                                    setState(() {
                                      _manualCouponMode = false;
                                      _selectedCoupon = coupon;
                                      _couponController.clear();
                                    });
                                  },
                                );
                              }).toList(),
                            )
                          else
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Bạn chưa có ưu đãi khả dụng.'),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: _manualCouponMode,
                                onChanged: (value) {
                                  setState(() {
                                    _manualCouponMode = value ?? false;
                                    if (_manualCouponMode) {
                                      _selectedCoupon = null;
                                    } else {
                                      _couponController.clear();
                                    }
                                  });
                                },
                              ),
                              const Expanded(child: Text('Nhập mã ưu đãi khác')),
                            ],
                          ),
                          if (_manualCouponMode)
                            _CheckoutField(
                              controller: _couponController,
                              label: 'Nhập mã giảm giá',
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _PaymentOptionTile(
                    title: 'MoMo',
                    subtitle: 'Thanh toán nhanh bằng ví MoMo',
                    value: 'momo',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _paymentMethod = value;
                      });
                    },
                  ),
                  _PaymentOptionTile(
                    title: 'Stripe',
                    subtitle: 'Thanh toán thẻ qua Stripe',
                    value: 'stripe',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _paymentMethod = value;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Đơn hàng của bạn',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE6DFDA)),
                    ),
                    child: Column(
                      children: [
                        ...widget.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                              child: Text(
                                    '${item.productName} x${item.quantity}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${currencyFormatter.format(item.totalPrice)}đ',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 8,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Tổng thanh toán',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${currencyFormatter.format(_finalTotal)}đ',
                            style: const TextStyle(
                              color: Color(0xFFA53D2B),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_discountAmount > 0)
                          Text(
                            'Đã giảm ${currencyFormatter.format(_discountAmount)}đ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Thanh toán',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD3C9C2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD3C9C2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6DFDA)),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
