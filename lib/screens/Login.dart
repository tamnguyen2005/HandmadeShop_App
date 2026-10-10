import 'package:flutter/material.dart';

import '../configurations/colors.dart';
import '../models/Auth/LoginRequest.dart';
import '../services/APIClient.dart';
import '../services/SharedPreferencesService.dart';
import '../services/UserService.dart';
import 'forgot_password_screen.dart';
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
	String? _statusMessage;
	bool _statusIsError = true;

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
			_setStatusMessage('Vui lòng nhập email và mật khẩu');
			return;
		}

		if (!_isValidEmail(email)) {
			_setStatusMessage('Email không hợp lệ');
			return;
		}

		setState(() {
			_isLoading = true;
			_statusMessage = null;
		});

		try {
			final user = await _userService.Login(
				LoginRequest(email: email, password: password),
			);
			if (!mounted) return;

			if (user == null) {
				_setStatusMessage(_userService.lastError ?? 'Đăng nhập thất bại');
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
			_setStatusMessage('Không thể kết nối máy chủ, vui lòng thử lại sau');
		} finally {
			if (mounted) {
				setState(() {
					_isLoading = false;
				});
			}
		}
	}

	void _setStatusMessage(String message, {bool isError = true}) {
		if (!mounted) return;
		setState(() {
			_statusMessage = message;
			_statusIsError = isError;
		});
	}

	void _openForgotPasswordScreen() {
		Navigator.of(context).push(
			MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
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
							padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
							child: Column(
								children: [
									const SizedBox(height: 185),
									Container(
										width: double.infinity,
										decoration: BoxDecoration(
											color: Colors.transparent,
											borderRadius: BorderRadius.circular(20),
										),
										padding: const EdgeInsets.fromLTRB(16, 24, 16, 18),
										child: Column(
											children: [
												_AuthInputField(
													controller: _emailController,
													keyboardType: TextInputType.emailAddress,
													label: 'Email',
													prefixIcon: const Icon(
														Icons.alternate_email_rounded,
														size: 20,
														color: AppColors.primary,
													),
												),
												const SizedBox(height: 10),
												_AuthInputField(
													controller: _passwordController,
													obscureText: _obscurePassword,
													label: 'Mật khẩu',
													prefixIcon: const Icon(
														Icons.lock_outline_rounded,
														size: 20,
														color: AppColors.primary,
													),
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
												),
												if (_statusMessage != null) ...[
													const SizedBox(height: 8),
													AnimatedSwitcher(
														duration: const Duration(milliseconds: 180),
														child: Container(
															key: ValueKey<String>(_statusMessage!),
															width: double.infinity,
															padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
															decoration: BoxDecoration(
																color: _statusIsError ? const Color(0xFFFCE8E6) : const Color(0xFFEAF4EA),
																borderRadius: BorderRadius.circular(12),
																border: Border.all(
																	color: _statusIsError ? const Color(0xFFE08A7D) : const Color(0xFF9AC39A),
																),
															),
															child: Row(
																children: [
																	Icon(
																		_statusIsError ? Icons.error_outline : Icons.info_outline,
																		size: 16,
																		color: _statusIsError ? const Color(0xFFD05B4F) : const Color(0xFF4E8B56),
																	),
																	const SizedBox(width: 7),
																	Expanded(
																		child: Text(
																			_statusMessage!,
																			style: TextStyle(
																				fontSize: 12,
																				color: _statusIsError ? const Color(0xFF9F3D35) : const Color(0xFF35673B),
																				fontWeight: FontWeight.w600,
																			),
																			maxLines: 2,
																			overflow: TextOverflow.ellipsis,
																		),
																	),
																],
															),
														),
													),
												],
												const SizedBox(height: 6),
												Align(
													alignment: Alignment.centerRight,
													child: TextButton(
														onPressed: _openForgotPasswordScreen,
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
													leading: ClipRRect(
														borderRadius: BorderRadius.circular(2),
														child: Image.asset(
															'assets/icons/google-logo.png',
															width: 22,
															height: 22,
															fit: BoxFit.contain,
															filterQuality: FilterQuality.high,
															errorBuilder: (_, __, ___) => const Icon(
																Icons.g_mobiledata,
																size: 20,
																color: Color(0xFF4285F4),
															),
														),
													),
													label: 'Đăng nhập bằng Google',
													onPressed: () => _setStatusMessage('Google Login đang được phát triển', isError: false),
												),
												const SizedBox(height: 10),
												_SocialButton(
													icon: Icons.facebook,
													label: 'Đăng nhập bằng FaceBook',
													iconColor: const Color(0xFF1877F2),
													onPressed: () => _setStatusMessage('Facebook Login đang được phát triển', isError: false),
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

class _AuthInputField extends StatelessWidget {
	const _AuthInputField({
		required this.controller,
		required this.label,
		this.keyboardType,
		this.obscureText = false,
		this.prefixIcon,
		this.suffixIcon,
	});

	final TextEditingController controller;
	final String label;
	final TextInputType? keyboardType;
	final bool obscureText;
	final Widget? prefixIcon;
	final Widget? suffixIcon;

	@override
	Widget build(BuildContext context) {
		return TextField(
			controller: controller,
			keyboardType: keyboardType,
			obscureText: obscureText,
			style: const TextStyle(fontSize: 14),
			decoration: InputDecoration(
				labelText: label,
				floatingLabelBehavior: FloatingLabelBehavior.auto,
				labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
				contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
				filled: false,
				prefixIcon: prefixIcon,
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
		);
	}
}

class _SocialButton extends StatelessWidget {
	const _SocialButton({
		this.leading,
		this.icon,
		required this.label,
		this.iconColor,
		this.googleLogo = false,
		required this.onPressed,
	});

	final Widget? leading;
	final IconData? icon;
	final String label;
	final Color? iconColor;
	final bool googleLogo;
	final VoidCallback onPressed;

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: double.infinity,
			height: 50,
			child: OutlinedButton.icon(
				onPressed: onPressed,
				icon: leading ?? Icon(icon, color: iconColor, size: 21),
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
