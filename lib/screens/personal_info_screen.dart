import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/User/UserInfo.dart';
import '../services/SharedPreferencesService.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  String _fullName = 'Chưa đăng nhập';
  String _email = '?@gmail.com';
  String _imageUrl = '';
  String _avatarBase64 = '';

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

  ImageProvider _avatarProvider() {
    if (_avatarBase64.trim().isNotEmpty) {
      return MemoryImage(base64Decode(_avatarBase64));
    }
    if (_imageUrl.trim().isNotEmpty) {
      return NetworkImage(_imageUrl);
    }
    return const AssetImage('assets/images/user.png');
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3DDD6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF5E4B45)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF867C77),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF221F1D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF4F2EF),
        foregroundColor: const Color(0xFF1F1F1F),
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserInfo,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            Center(
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD9D3CD), width: 2),
                  image: DecorationImage(
                    image: _avatarProvider(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _buildInfoTile(
              icon: Icons.badge_outlined,
              label: 'Họ và tên',
              value: _fullName,
            ),
            _buildInfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: _email,
            ),
            const SizedBox(height: 6),
            const Text(
              'Avatar được quản lý tại trang cá nhân.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8C837E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
