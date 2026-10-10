import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configurations/colors.dart';
import '../models/Order/OrderResponse.dart';
import '../services/APIClient.dart';
import '../services/OrderService.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final OrderService _orderService = OrderService(apiClient: APIClient());

  bool _isLoading = true;
  String? _error;
  List<OrderResponse> _orders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _orderService.GetAllOrder();
      if (!mounted) return;
      setState(() {
        _orders = orders;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể tải danh sách đơn hàng.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _statusBucket(String status) {
    final s = status.toLowerCase();
    if (s.contains('confirm') || s.contains('pending') || s.contains('xác nhận')) {
      return 0;
    }
    if (s.contains('process') || s.contains('xử lý')) {
      return 1;
    }
    if (s.contains('ship') || s.contains('deliver') || s.contains('giao')) {
      return 2;
    }
    return 0;
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(value)}đ';
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(dt.toLocal());
  }

  Color _statusColor(String status) {
    switch (_statusBucket(status)) {
      case 0:
        return AppColors.info;
      case 1:
        return AppColors.warning;
      case 2:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  List<OrderResponse> _ordersByTab(int tab) {
    return _orders.where((o) => _statusBucket(o.status) == tab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trạng thái đơn hàng'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Xác nhận'),
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Đang giao'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                    ],
                  )
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(3, (tab) {
                      final data = _ordersByTab(tab);
                      if (data.isEmpty) {
                        return ListView(
                          children: const [
                            SizedBox(height: 140),
                            Icon(Icons.inventory_2_outlined, size: 72, color: AppColors.textLight),
                            SizedBox(height: 14),
                            Center(
                              child: Text(
                                'Chưa có đơn hàng ở trạng thái này',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(14),
                        itemBuilder: (context, index) {
                          final order = data[index];
                          final color = _statusColor(order.status);
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE8E1DB)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Đơn #${order.id}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        order.status,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Ngày đặt: ${_formatDate(order.orderDate)}'),
                                const SizedBox(height: 4),
                                Text('Thanh toán: ${order.paymentMethod}'),
                                const SizedBox(height: 8),
                                Text(
                                  _formatCurrency(order.totalAmount),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemCount: data.length,
                      );
                    }),
                  ),
      ),
    );
  }
}
