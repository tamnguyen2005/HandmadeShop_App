import 'package:flutter/material.dart';

import '../configurations/colors.dart';
import '../models/Auth/RegisterRequest.dart';
import '../services/APIClient.dart';
import '../services/SharedPreferencesService.dart';
import '../services/UserService.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final UserService _userService = UserService(apiClient: APIClient());
  bool _isAgree = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (fullName.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnack('Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (password != confirm) {
      _showSnack('Mật khẩu xác nhận không khớp');
      return;
    }

    if (!_isAgree) {
      _showSnack('Vui lòng đồng ý với điều khoản và chính sách');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final ok = await _userService.Register(
        RegisterRequest(
          fullname: fullName,
          email: email,
          password: password,
          phoneNumber: phone,
          address: '',
        ),
      );
      if (!mounted) return;
      if (ok) {
        // Persist initial shipping info by email so profile/checkout can reuse it after login.
        await SharedPreferencesService().setDefaultShippingInfo(
          receiver: fullName,
          phone: phone,
          address: '',
          userEmail: email,
        );
        _showSnack('Đăng ký thành công, vui lòng đăng nhập');
        Navigator.of(context).pop();
      } else {
  		_showSnack(_userService.lastError ?? 'Đăng ký thất bại, vui lòng thử lại');
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('Không thể kết nối máy chủ, vui lòng thử lại');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EF),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/backgroundregister.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
              child: Column(
                children: [
                  const SizedBox(height: 170),
                  // const SizedBox(height: 36),
                  // Image.asset('assets/images/logo.png', width: 200),
                  // const SizedBox(height: 34),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                    child: Column(
                      children: [
                        _UnderlineInput(
                          label: 'Họ và tên',
                          controller: _fullNameController,
                        ),
                        _UnderlineInput(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _UnderlineInput(
                          label: 'Số điện thoại',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        _UnderlineInput(
                          label: 'Mật khẩu',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        _UnderlineInput(
                          label: 'Nhập lại mật khẩu',
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _isAgree,
                                onChanged: (value) {
                                  setState(() {
                                    _isAgree = value ?? false;
                                  });
                                },
                                side: const BorderSide(color: AppColors.primaryLight),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                activeColor: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Đồng ý với Điều Khoản và Chính Sách',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('ĐĂNG KÝ'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Bạn đã có tài khoản? ',
                        style: TextStyle(color: AppColors.primaryDark, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Đăng Nhập Ngay',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnderlineInput extends StatelessWidget {
  const _UnderlineInput({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8A7973),
          ),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          filled: false,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: AppColors.primaryLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: AppColors.primaryLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
