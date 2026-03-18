import 'package:flutter/material.dart';

import '../configurations/colors.dart';
import '../models/Auth/LoginRequest.dart';
import '../services/APIClient.dart';
import '../services/SharedPreferencesService.dart';
import '../services/UserService.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
	const LoginScreen({super.key});

	@override
	State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();
	final UserService _userService = UserService(apiClient: APIClient());
	bool _obscurePassword = true;
	bool _isLoading = false;

	@override
	void dispose() {
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	Future<void> _submitLogin() async {
		final email = _emailController.text.trim();
		final password = _passwordController.text.trim();

		if (email.isEmpty || password.isEmpty) {
			_showSnack('Vui lòng nhập đầy đủ tài khoản và mật khẩu');
			return;
		}

		if (!_isValidEmail(email)) {
			_showSnack('Hiện tại hệ thống chỉ hỗ trợ đăng nhập bằng email hợp lệ');
			return;
		}

		setState(() {
			_isLoading = true;
		});

		try {
			final user = await _userService.Login(
				LoginRequest(email: email, password: password),
			);
			if (!mounted) return;

			if (user == null) {
				_showSnack(_userService.lastError ?? 'Đăng nhập thất bại, vui lòng kiểm tra lại thông tin');
			} else {
				await SharedPreferencesService().setUserInfo(user);
				if (!mounted) return;
				Navigator.of(context).pushAndRemoveUntil(
					MaterialPageRoute(builder: (_) => const HomeScreen()),
					(route) => false,
				);
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

	bool _isValidEmail(String value) {
		final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
		return emailRegex.hasMatch(value);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF4F2EF),
			body: SafeArea(
				child: Stack(
					fit: StackFit.expand,
					children: [
						Image.asset('assets/images/backgroundlogin.png', fit: BoxFit.cover),
						SingleChildScrollView(
							padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
							child: Column(
								children: [
									const SizedBox(height: 150),
									Container(
										width: double.infinity,
										decoration: BoxDecoration(
											color: const Color(0xFFE9DEE0).withValues(alpha: 0.95),
											borderRadius: BorderRadius.circular(20),
										),
										padding: const EdgeInsets.fromLTRB(16, 24, 16, 18),
										child: Column(
											children: [
												TextField(
													controller: _emailController,
													keyboardType: TextInputType.emailAddress,
													style: const TextStyle(fontSize: 14),
													decoration: InputDecoration(
														hintText: 'Email hoặc số điện thoại',
														hintStyle: const TextStyle(fontSize: 13),
														contentPadding: const EdgeInsets.symmetric(
															horizontal: 14,
															vertical: 14,
														),
														filled: true,
														fillColor: Colors.white,
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
												const SizedBox(height: 10),
												TextField(
													controller: _passwordController,
													obscureText: _obscurePassword,
													style: const TextStyle(fontSize: 14),
													decoration: InputDecoration(
														hintText: 'Mật khẩu',
														hintStyle: const TextStyle(fontSize: 13),
														contentPadding: const EdgeInsets.symmetric(
															horizontal: 14,
															vertical: 14,
														),
														filled: true,
														fillColor: Colors.white,
														suffixIcon: IconButton(
															onPressed: () {
																setState(() {
																	_obscurePassword = !_obscurePassword;
																});
															},
															icon: Icon(
																_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
																size: 18,
																color: AppColors.primary,
															),
														),
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
												const SizedBox(height: 6),
												Align(
													alignment: Alignment.centerRight,
													child: TextButton(
														onPressed: () => _showSnack('Chức năng quên mật khẩu đang được phát triển'),
														child: const Text(
															'Quên Mật Khẩu',
															style: TextStyle(
																decoration: TextDecoration.underline,
																color: AppColors.primaryDark,
																fontSize: 13,
															),
														),
													),
												),
												const SizedBox(height: 2),
												SizedBox(
													width: double.infinity,
													height: 50,
													child: ElevatedButton(
														onPressed: _isLoading ? null : _submitLogin,
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
																: const Text('ĐĂNG NHẬP'),
													),
												),
												const SizedBox(height: 10),
												Row(
													children: const [
														Expanded(child: Divider(color: AppColors.primaryLight)),
														Padding(
															padding: EdgeInsets.symmetric(horizontal: 10),
															child: Text('Hoặc', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
														),
														Expanded(child: Divider(color: AppColors.primaryLight)),
													],
												),
												const SizedBox(height: 10),
												_SocialButton(
													icon: Icons.g_mobiledata,
													label: 'Đăng nhập bằng Google',
													iconColor: const Color(0xFFDB4437),
													onPressed: () => _showSnack('Google Login đang được phát triển'),
												),
												const SizedBox(height: 10),
												_SocialButton(
													icon: Icons.facebook,
													label: 'Đăng nhập bằng FaceBook',
													iconColor: const Color(0xFF1877F2),
													onPressed: () => _showSnack('Facebook Login đang được phát triển'),
												),
											],
										),
									),
									const SizedBox(height: 18),
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											const Text(
												'Bạn chưa có tài khoản? ',
												style: TextStyle(color: AppColors.primaryDark, fontSize: 14),
											),
											GestureDetector(
												onTap: () {
													Navigator.of(context).push(
														MaterialPageRoute(builder: (_) => const RegisterScreen()),
													);
												},
												child: const Text(
													'Đăng Ký Ngay',
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

class _SocialButton extends StatelessWidget {
	const _SocialButton({
		required this.icon,
		required this.label,
		required this.iconColor,
		required this.onPressed,
	});

	final IconData icon;
	final String label;
	final Color iconColor;
	final VoidCallback onPressed;

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: double.infinity,
			height: 50,
			child: OutlinedButton.icon(
				onPressed: onPressed,
				icon: Icon(icon, color: iconColor, size: 24),
				label: Text(
					label,
					style: const TextStyle(
						color: AppColors.primaryDark,
						fontSize: 15,
						fontWeight: FontWeight.w500,
					),
				),
				style: OutlinedButton.styleFrom(
					backgroundColor: Colors.white,
					side: const BorderSide(color: Color(0xFFCFC6C4)),
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
				),
			),
		);
	}
}
