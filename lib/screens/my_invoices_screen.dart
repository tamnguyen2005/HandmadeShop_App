import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configurations/colors.dart';
import '../models/Order/OrderResponse.dart';
import '../services/APIClient.dart';
import '../services/OrderService.dart';

class MyInvoicesScreen extends StatefulWidget {
  const MyInvoicesScreen({super.key});

  @override
  State<MyInvoicesScreen> createState() => _MyInvoicesScreenState();
}

class _MyInvoicesScreenState extends State<MyInvoicesScreen> {
  final OrderService _orderService = OrderService(apiClient: APIClient());
  bool _isLoading = true;
  String? _error;
  List<OrderResponse> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _orderService.GetAllOrder();
      if (!mounted) return;
      setState(() {
        _orders = data;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể tải hóa đơn của bạn.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(value)}đ';
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Hóa đơn của tôi')),
      body: RefreshIndicator(
        onRefresh: _loadInvoices,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary))),
                    ],
                  )
                : _orders.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 140),
                          Icon(Icons.receipt_long_outlined, size: 72, color: AppColors.textLight),
                          SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Bạn chưa có hóa đơn nào',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(14),
                        itemBuilder: (context, index) {
                          final order = _orders[index];
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
                                Text(
                                  'Mã hóa đơn: ${order.id}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                const SizedBox(height: 8),
                                Text('Ngày: ${_formatDate(order.orderDate)}'),
                                const SizedBox(height: 4),
                                Text('Phương thức: ${order.paymentMethod}'),
                                const SizedBox(height: 4),
                                Text('Trạng thái: ${order.status}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Tổng tiền: ${_formatCurrency(order.totalAmount)}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemCount: _orders.length,
                      ),
      ),
    );
  }
}
