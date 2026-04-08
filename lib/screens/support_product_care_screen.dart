import 'package:flutter/material.dart';

import '../configurations/colors.dart';

class SupportProductCareScreen extends StatelessWidget {
  const SupportProductCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EF),
      appBar: AppBar(
        title: const Text('Chăm sóc sản phẩm'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        children: [
          _InfoCard(
            icon: Icons.inventory_2_outlined,
            title: 'Hướng dẫn bảo quản đồ da',
            description:
                'Tránh tiếp xúc trực tiếp với nước, ánh nắng gắt và nhiệt độ cao. Dùng khăn mềm lau nhẹ định kỳ.',
          ),
          _InfoCard(
            icon: Icons.cleaning_services_outlined,
            title: 'Vệ sinh định kỳ',
            description:
                'Sử dụng dung dịch vệ sinh chuyên dụng cho da, không dùng chất tẩy mạnh để tránh bong tróc bề mặt.',
          ),
          _InfoCard(
            icon: Icons.shield_outlined,
            title: 'Bảo hành sản phẩm',
            description:
                'Hỗ trợ bảo hành lỗi kỹ thuật trong 30 ngày kể từ ngày nhận hàng. Giữ hóa đơn để được hỗ trợ nhanh.',
          ),
          _InfoCard(
            icon: Icons.local_shipping_outlined,
            title: 'Đóng gói khi vận chuyển',
            description:
                'Nên nhồi giấy giữ form sản phẩm và dùng túi chống ẩm để bảo vệ chất liệu trong quá trình di chuyển.',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4DDD7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
