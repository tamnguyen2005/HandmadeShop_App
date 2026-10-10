import 'package:flutter/material.dart';

import '../configurations/colors.dart';

class SupportCustomerCareScreen extends StatelessWidget {
  const SupportCustomerCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EF),
      appBar: AppBar(
        title: const Text('Chăm sóc khách hàng'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        children: [
          _ContactTile(
            icon: Icons.phone_in_talk_outlined,
            title: 'Hotline',
            value: '1900 6868 (08:00 - 22:00)',
          ),
          _ContactTile(
            icon: Icons.mail_outline,
            title: 'Email hỗ trợ',
            value: 'support@atelier.vn',
          ),
          _ContactTile(
            icon: Icons.chat_bubble_outline,
            title: 'Chat trực tuyến',
            value: 'Phản hồi trong vòng 5 - 10 phút',
          ),
          const SizedBox(height: 10),
          const Text(
            'Yêu cầu hỗ trợ nhanh',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.refresh_outlined,
            label: 'Yêu cầu đổi trả sản phẩm',
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Khiếu nại đơn hàng',
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.lock_reset_outlined,
            label: 'Hỗ trợ tài khoản',
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4DDD7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label đang được cập nhật')),
          );
        },
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          alignment: Alignment.centerLeft,
          elevation: 0,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2D8D1)),
          ),
        ),
      ),
    );
  }
}
