import 'package:flutter/material.dart';

import '../configurations/colors.dart';
import '../models/Coupon/Coupon.dart';
import '../services/APIClient.dart';
import '../services/CouponService.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final CouponService _couponService = CouponService(apiClient: APIClient());

  bool _isLoading = true;
  String? _error;
  List<Coupon> _coupons = [];

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _couponService.GetAllCoupon();
      if (!mounted) return;
      setState(() {
        _coupons = data;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể tải ưu đãi.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ưu đãi của tôi')),
      body: RefreshIndicator(
        onRefresh: _loadCoupons,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary))),
                    ],
                  )
                : _coupons.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 140),
                          Icon(Icons.discount_outlined, size: 72, color: AppColors.textLight),
                          SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Hiện chưa có ưu đãi khả dụng',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(14),
                        itemBuilder: (context, index) {
                          final coupon = _coupons[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE8E1DB)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.local_offer_outlined, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        coupon.id,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Giảm ${coupon.value}% - đơn từ ${coupon.minOrderAmount.toStringAsFixed(0)}đ',
                                        style: const TextStyle(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Mã ${coupon.id} đã được sao chép (demo)')),
                                    );
                                  },
                                  child: const Text('Dùng'),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemCount: _coupons.length,
                      ),
      ),
    );
  }
}
