import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../configurations/colors.dart';
import '../models/User/UserInfo.dart';
import '../services/SharedPreferencesService.dart';
import 'Login.dart';
import 'my_invoices_screen.dart';
import 'my_offers_screen.dart';
import 'order_status_screen.dart';
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
  String _avatarBase64 = '';
  bool _updatingAvatar = false;

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
      _avatarBase64 = userInfo.avatarBase64;
    });
  }

  ImageProvider _profileImageProvider() {
    if (_avatarBase64.trim().isNotEmpty) {
      return MemoryImage(base64Decode(_avatarBase64));
    }
    if (_imageUrl.trim().isNotEmpty) {
      return NetworkImage(_imageUrl);
    }
    return const AssetImage('assets/images/user.png');
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final selected = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );

    if (selected == null) return;

    setState(() {
      _updatingAvatar = true;
    });

    try {
      final bytes = await selected.readAsBytes();
      final encoded = base64Encode(bytes);
      await SharedPreferencesService().setAvatarBase64(encoded);
      if (!mounted) return;
      setState(() {
        _avatarBase64 = encoded;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật ảnh đại diện')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể cập nhật ảnh đại diện')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingAvatar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD9D3CD), width: 2),
                        image: DecorationImage(
                          image: _profileImageProvider(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _updatingAvatar ? null : _pickAvatar,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: _updatingAvatar
                              ? const Padding(
                                  padding: EdgeInsets.all(7),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF535353),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Nhấn biểu tượng máy ảnh để đổi avatar',
                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            children: [
              _OrderStatus(
                icon: Icons.fact_check_outlined,
                label: 'Xác nhận đơn',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrderStatusScreen(initialTab: 0)),
                  );
                },
              ),
              _OrderStatus(
                icon: Icons.inventory_2_outlined,
                label: 'Đang xử lý',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrderStatusScreen(initialTab: 1)),
                  );
                },
              ),
              _OrderStatus(
                icon: Icons.local_shipping_outlined,
                label: 'Đang giao hàng',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrderStatusScreen(initialTab: 2)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),

          _ProfileMenuTile(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
              );
              _loadUserInfo();
            },
          ),
          _ProfileMenuTile(
            icon: Icons.receipt_long_outlined,
            title: 'Hóa đơn của tôi',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyInvoicesScreen()),
              );
            },
          ),
          _ProfileMenuTile(
            icon: Icons.discount_outlined,
            title: 'Ưu đãi của tôi',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyOffersScreen()),
              );
            },
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
  const _OrderStatus({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
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
