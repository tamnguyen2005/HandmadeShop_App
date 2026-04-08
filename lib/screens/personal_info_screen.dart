import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../configurations/colors.dart';
import '../models/User/DeleteUserRequest.dart';
import '../models/User/UpdateUserRequest.dart';
import '../models/User/UserInfo.dart';
import '../services/APIClient.dart';
import '../services/SharedPreferencesService.dart';
import '../services/UserService.dart';
import 'Login.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final UserService _userService = UserService(apiClient: APIClient());
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _fullNameValue = '';
  String _emailValue = '';
  String _phoneValue = '';
  String _addressValue = '';
  String _imageUrl = '';
  String _avatarBase64 = '';
  Uint8List? _pickedAvatarBytes;
  String? _pickedAvatarFileName;
  bool _isSaving = false;
  bool _isPickingAvatar = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final prefs = SharedPreferencesService();
    final userInfo = await SharedPreferencesService().getUserInfo();
    final shipping = await prefs.getDefaultShippingInfo(userEmail: userInfo.email);
    if (!mounted) return;

    setState(() {
      _fullNameValue = userInfo.fullname == 'Chưa đăng nhập' ? '' : userInfo.fullname;
      _emailValue = userInfo.email == '?@gmail.com' ? '' : userInfo.email;
      _phoneValue = shipping['phone'] ?? '';
      _addressValue = shipping['address'] ?? '';
      _fullNameController.text = _fullNameValue;
      _emailController.text = _emailValue;
      _phoneController.text = _phoneValue;
      _addressController.text = _addressValue;
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

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final selected = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );

    if (selected == null) return;

    setState(() {
      _isPickingAvatar = true;
    });

    try {
      final bytes = await selected.readAsBytes();
      final encoded = base64Encode(bytes);
      if (!mounted) return;
      setState(() {
        _pickedAvatarBytes = bytes;
        _pickedAvatarFileName = selected.name.isNotEmpty ? selected.name : 'avatar.jpg';
        _avatarBase64 = encoded;
      });
      await SharedPreferencesService().setAvatarBase64(encoded);
    } finally {
      if (mounted) {
        setState(() {
          _isPickingAvatar = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final fullName = _fullNameValue.trim();
    final email = _emailValue.trim();
    final phoneNumber = _phoneValue.trim();
    final address = _addressValue.trim();

    if (fullName.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập họ tên và email')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final ok = await _userService.UpdateUserInfo(
        UpdateUserRequest(
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          avartarBytes: _pickedAvatarBytes,
          avartarFileName: _pickedAvatarFileName,
        ),
      );

      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_userService.lastError ?? 'Không thể cập nhật thông tin'),
          ),
        );
        return;
      }

      final currentToken = await SharedPreferencesService().getToken();
      await SharedPreferencesService().setUserInfo(
        UserInfo(
          fullname: fullName,
          email: email,
          imageURL: _imageUrl,
          avatarBase64: _avatarBase64,
          token: currentToken,
        ),
      );
      await SharedPreferencesService().setDefaultShippingInfo(
        receiver: fullName,
        phone: phoneNumber,
        address: address,
        userEmail: email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thông tin cá nhân')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể cập nhật thông tin cá nhân')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteAccount() async {
    final password = await _askForPassword();
    if (password == null || password.trim().isEmpty) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final ok = await _userService.DeleteUser(
        DeleteUserRequest(password: password),
      );

      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_userService.lastError ?? 'Không thể xóa tài khoản')),
        );
        return;
      }

      await SharedPreferencesService().clearUserInfo();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xóa tài khoản')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<String?> _askForPassword() async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFF9F1EC),
          elevation: 12,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE3DA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFC25B3A),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Xác nhận xóa tài khoản',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF251F1C),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hành động này sẽ xóa toàn bộ dữ liệu tài khoản và không thể hoàn tác.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF6F625B),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  autofocus: true,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nhập mật khẩu để xác nhận',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFD9C7BE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFD9C7BE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                    ),
                  ),
                  onSubmitted: (_) => Navigator.of(dialogContext).pop(passwordController.text),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                          side: const BorderSide(color: Color(0xFFCFB9AF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size.fromHeight(46),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(passwordController.text),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD24D3E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size.fromHeight(46),
                        ),
                        child: const Text('Xóa tài khoản'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    passwordController.dispose();
    return password;
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD9D3CD), width: 2),
                      image: DecorationImage(
                        image: _avatarProvider(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: _isPickingAvatar ? null : _pickAvatar,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _isPickingAvatar
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
            ),
            const SizedBox(height: 18),
            _buildInfoField(
              label: 'Họ và tên',
              controller: _fullNameController,
              icon: Icons.badge_outlined,
              onChanged: (value) => _fullNameValue = value,
            ),
            const SizedBox(height: 12),
            _buildInfoField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email_outlined,
              onChanged: (value) => _emailValue = value,
            ),
            const SizedBox(height: 12),
            _buildInfoField(
              label: 'Số điện thoại',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              onChanged: (value) => _phoneValue = value,
            ),
            const SizedBox(height: 12),
            _buildInfoField(
              label: 'Địa chỉ',
              controller: _addressController,
              icon: Icons.home_outlined,
              onChanged: (value) => _addressValue = value,
            ),
            const SizedBox(height: 12),
            Text(
              'Thay đổi thông tin sẽ được cập nhật trực tiếp lên server.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Đang lưu...' : 'Lưu thay đổi'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _isDeleting ? null : _deleteAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : const Icon(Icons.delete_forever_outlined),
              label: Text(_isDeleting ? 'Đang xóa...' : 'Xóa tài khoản'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Xóa tài khoản là thao tác không thể hoàn tác.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8C837E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}