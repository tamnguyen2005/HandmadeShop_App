import 'package:flutter/material.dart';

import '../configurations/colors.dart';

class SupportFaqScreen extends StatelessWidget {
  const SupportFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EF),
      appBar: AppBar(
        title: const Text('Câu hỏi thường gặp'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        children: const [
          _FaqTile(
            question: 'Làm sao để theo dõi đơn hàng?',
            answer:
                'Bạn vào mục Đơn hàng trong trang cá nhân để xem trạng thái đơn theo thời gian thực.',
          ),
          _FaqTile(
            question: 'Tôi có thể đổi địa chỉ giao hàng sau khi đặt đơn không?',
            answer:
                'Bạn có thể liên hệ Chăm sóc khách hàng trong vòng 30 phút sau khi đặt đơn để được hỗ trợ thay đổi.',
          ),
          _FaqTile(
            question: 'Cửa hàng có hỗ trợ đổi trả không?',
            answer:
                'Có. Bạn có thể gửi yêu cầu đổi trả trong vòng 7 ngày nếu sản phẩm có lỗi hoặc không đúng mô tả.',
          ),
          _FaqTile(
            question: 'Làm sao để áp dụng mã giảm giá?',
            answer:
                'Tại màn thanh toán, mở mục Mã giảm giá để chọn mã có sẵn hoặc nhập mã ưu đãi thủ công.',
          ),
          _FaqTile(
            question: 'Bao lâu tôi nhận được phản hồi hỗ trợ?',
            answer:
                'Thông thường trong giờ làm việc, đội ngũ hỗ trợ sẽ phản hồi trong vòng 5-10 phút.',
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

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
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.primary,
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Text(
            answer,
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
