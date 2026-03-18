import 'package:flutter/material.dart';
import '../configurations/colors.dart';
import '../models/User/UserInfo.dart';
import '../services/SharedPreferencesService.dart';
import 'Login.dart';
import 'personal_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int favoriteCount;
  final int cartCount;

  const ProfileScreen({
    super.key,
    required this.favoriteCount,
    required this.cartCount,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = 'Chưa đăng nhập';
  String _email = '?@gmail.com';
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final UserInfo userInfo = await SharedPreferencesService().getUserInfo();
    if (!mounted) return;
    setState(() {
      _fullName = userInfo.fullname;
      _email = userInfo.email;
      _imageUrl = userInfo.imageURL;
    });
  }

  ImageProvider _profileImageProvider() {
    if (_imageUrl.trim().isNotEmpty) {
      return NetworkImage(_imageUrl);
    }
    return const AssetImage('assets/images/user.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EF),
      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD9D3CD)),
                  image: DecorationImage(
                    image: _profileImageProvider(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF535353),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 24, color: Color(0xFFD8D2CC)),

          const Text(
            'Lịch sử đơn hàng',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _OrderStatus(icon: Icons.fact_check_outlined, label: 'Xác nhận đơn'),
              _OrderStatus(icon: Icons.inventory_2_outlined, label: 'Đang xử lý'),
              _OrderStatus(icon: Icons.local_shipping_outlined, label: 'Đang giao hàng'),
            ],
          ),
          const SizedBox(height: 18),

          _ProfileMenuTile(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
              );
            },
          ),
          _ProfileMenuTile(
            icon: Icons.receipt_long_outlined,
            title: 'Hóa đơn của tôi',
            onTap: () => _showComingSoon(context, 'Hóa đơn của tôi'),
          ),
          _ProfileMenuTile(
            icon: Icons.discount_outlined,
            title: 'Ưu đãi của tôi',
            onTap: () => _showComingSoon(context, 'Ưu đãi của tôi'),
          ),

          const SizedBox(height: 16),
          const Text(
            'Hỗ trợ',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 10),
          _ProfileMenuTile(
            icon: Icons.support_agent_outlined,
            title: 'Chăm sóc sản phẩm',
            onTap: () => _showComingSoon(context, 'Chăm sóc sản phẩm'),
          ),
          _ProfileMenuTile(
            icon: Icons.headset_mic_outlined,
            title: 'Chăm sóc khách hàng',
            onTap: () => _showComingSoon(context, 'Chăm sóc khách hàng'),
          ),
          _ProfileMenuTile(
            icon: Icons.verified_user_outlined,
            title: 'Điều khoản và chính sách',
            onTap: () => _showComingSoon(context, 'Điều khoản và chính sách'),
          ),
          _ProfileMenuTile(
            icon: Icons.help_outline,
            title: 'Câu hỏi thường gặp',
            onTap: () => _showComingSoon(context, 'Câu hỏi thường gặp'),
          ),

          const SizedBox(height: 16),
          const Text(
            'Tùy chỉnh cá nhân',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 10),
          _ProfileMenuTile(
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            trailing: widget.favoriteCount > 0 || widget.cartCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.favoriteCount}/${widget.cartCount}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
            onTap: () => _showComingSoon(context, 'Cài đặt'),
          ),
          _ProfileMenuTile(
            icon: Icons.logout,
            title: 'Đăng xuất',
            onTap: () async {
              await SharedPreferencesService().clearUserInfo();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFD8D2CC), height: 1),
        ],
      ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title đang được phát triển')),
    );
  }
}

class _OrderStatus extends StatelessWidget {
  const _OrderStatus({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: Column(
        children: [
          Icon(icon, size: 34, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2E2E2E),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Icon(icon, size: 21, color: const Color(0xFF1E1E1E)),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF222222),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF98928C),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
