import 'package:flutter/material.dart';

import '../configurations/colors.dart';

class SupportTermsPolicyScreen extends StatelessWidget {
  const SupportTermsPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EF),
      appBar: AppBar(
        title: const Text('Điều khoản và chính sách'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        children: const [
          _PolicyCard(
            title: 'Chính sách bảo mật',
            content:
                'Chúng tôi cam kết bảo vệ dữ liệu cá nhân của bạn và chỉ sử dụng thông tin cho mục đích xử lý đơn hàng, chăm sóc khách hàng và cải thiện dịch vụ.',
          ),
          _PolicyCard(
            title: 'Điều khoản sử dụng',
            content:
                'Người dùng cần cung cấp thông tin chính xác khi đăng ký và chịu trách nhiệm về hoạt động của tài khoản trong suốt thời gian sử dụng.',
          ),
          _PolicyCard(
            title: 'Chính sách đổi trả',
            content:
                'Sản phẩm được hỗ trợ đổi trả trong vòng 7 ngày nếu có lỗi từ nhà sản xuất hoặc khác biệt đáng kể so với mô tả.',
          ),
          _PolicyCard(
            title: 'Chính sách vận chuyển',
            content:
                'Đơn hàng được xử lý trong 24 giờ làm việc. Thời gian giao hàng phụ thuộc khu vực và đơn vị vận chuyển.',
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4DDD7)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.primary,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
