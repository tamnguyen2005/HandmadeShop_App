import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../configurations/colors.dart';
import '../models/Auth/ForgotPasswordRequest.dart';
import '../models/Auth/VerifyResetOtpRequest.dart';
import '../models/Auth/ResetPasswordRequest.dart';
import '../services/APIClient.dart';
import '../services/UserService.dart';

class ForgotPasswordScreen extends StatefulWidget {
	const ForgotPasswordScreen({super.key});

	@override
	State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
	final UserService _userService = UserService(apiClient: APIClient());
	int _currentStep = 1; // 1: Email, 2: OTP, 3: Password
	String _email = '';
	String _otp = '';

	void _goToStep(int step) {
		setState(() {
			_currentStep = step;
		});
	}

	void _goBack() {
		if (_currentStep > 1) {
			_goToStep(_currentStep - 1);
		} else {
			Navigator.of(context).pop();
		}
	}

	Future<void> _showMessageDialog(String message, {bool isError = true}) async {
		if (!mounted) return;
		await showGeneralDialog<void>(
			context: context,
			barrierDismissible: true,
			barrierLabel: 'Thông báo',
			barrierColor: Colors.black.withOpacity(0.45),
			transitionDuration: const Duration(milliseconds: 220),
			pageBuilder: (dialogContext, animation, secondaryAnimation) {
				return SafeArea(
					child: Center(
						child: Padding(
							padding: const EdgeInsets.all(24),
							child: Material(
								color: Colors.transparent,
								child: Container(
									width: double.infinity,
									constraints: const BoxConstraints(maxWidth: 360),
									decoration: BoxDecoration(
										color: const Color(0xFFFFF8F4),
										borderRadius: BorderRadius.circular(28),
										boxShadow: [
											BoxShadow(
												color: Colors.black.withOpacity(0.14),
												blurRadius: 30,
												offset: const Offset(0, 18),
											),
										],
									),
									child: Column(
										mainAxisSize: MainAxisSize.min,
										children: [
											Container(
												height: 8,
												width: double.infinity,
												decoration: BoxDecoration(
													borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
													gradient: LinearGradient(
														colors: isError
															? [const Color(0xFFB96B4B), const Color(0xFF8E4F31)]
															: [const Color(0xFF3AA76D), const Color(0xFF2E8B57)],
													),
												),
											),
											const SizedBox(height: 24),
											Container(
												padding: const EdgeInsets.all(14),
												decoration: BoxDecoration(
													shape: BoxShape.circle,
													color: isError
														? const Color(0xFFF5E4DD)
														: const Color(0xFFE3F4EA),
												),
												child: Icon(
													isError ? Icons.error_outline_rounded : Icons.check_rounded,
													color: isError ? const Color(0xFFB65C3B) : const Color(0xFF2E8B57),
													size: 32,
												),
											),
											const SizedBox(height: 18),
											Padding(
												padding: const EdgeInsets.symmetric(horizontal: 20),
												child: Text(
													isError ? 'Có lỗi xảy ra' : 'Hoàn tất',
													textAlign: TextAlign.center,
													style: const TextStyle(
														fontSize: 20,
														fontWeight: FontWeight.w800,
														color: AppColors.primaryDark,
													),
												),
											),
											const SizedBox(height: 10),
											Padding(
												padding: const EdgeInsets.symmetric(horizontal: 22),
												child: Text(
													message,
													textAlign: TextAlign.center,
													style: const TextStyle(
														fontSize: 14,
														height: 1.45,
														color: AppColors.textSecondary,
													),
												),
											),
											const SizedBox(height: 22),
											Padding(
												padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
												child: SizedBox(
													width: double.infinity,
													height: 50,
													child: ElevatedButton(
														onPressed: () => Navigator.of(dialogContext).pop(),
														style: ElevatedButton.styleFrom(
															backgroundColor: isError ? const Color(0xFF9E6448) : const Color(0xFF2E8B57),
															foregroundColor: Colors.white,
															shape: RoundedRectangleBorder(
																borderRadius: BorderRadius.circular(16),
															),
															elevation: 0,
														),
														child: Text(isError ? 'Đã hiểu' : 'Tiếp tục'),
													),
												),
											),
										],
									),
								),
							),
						),
					),
				);
			},
			transitionBuilder: (context, animation, secondaryAnimation, child) {
				final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
				return FadeTransition(
					opacity: animation,
					child: ScaleTransition(scale: curved, child: child),
				);
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		return WillPopScope(
			onWillPop: () async {
				_goBack();
				return false;
			},
			child: Scaffold(
				backgroundColor: const Color(0xFFF4F2EF),
				body: SafeArea(
					child: Column(
						children: [
							/// Header
							Padding(
								padding: const EdgeInsets.all(16.0),
								child: Row(
									children: [
										IconButton(
											icon: const Icon(Icons.arrow_back),
											onPressed: _goBack,
										),
										Expanded(
											child: Text(
												_currentStep == 1
													? 'Khôi phục mật khẩu'
													: _currentStep == 2
														? 'Xác thực OTP'
														: 'Đặt mật khẩu mới',
												style: const TextStyle(
													fontSize: 18,
													fontWeight: FontWeight.w700,
													color: AppColors.primaryDark,
												),
											),
										),
									],
								),
							),
							/// Content
							Expanded(
								child: SingleChildScrollView(
									padding: const EdgeInsets.all(16.0),
									child: _currentStep == 1
										? _EmailStepWidget(
											userService: _userService,
											onEmailSent: (email) {
												_email = email;
												_goToStep(2);
											},
											onError: (message) => _showMessageDialog(message),
										)
										: _currentStep == 2
											? _OtpStepWidget(
												email: _email,
												userService: _userService,
												onOtpVerified: (otp) {
													_otp = otp;
													_goToStep(3);
												},
												onError: (message) => _showMessageDialog(message),
											)
											: _PasswordStepWidget(
												email: _email,
												otp: _otp,
												userService: _userService,
												onPasswordReset: () {
													_showMessageDialog(
														'Đặt lại mật khẩu thành công',
														isError: false,
													).then((_) {
														if (mounted) {
															Navigator.of(context).pop();
														}
													});
												},
												onError: (message) => _showMessageDialog(message),
											),
								),
							),
						],
					),
				),
			),
		);
	}
}

class _EmailStepWidget extends StatefulWidget {
	final UserService userService;
	final Function(String) onEmailSent;
	final Function(String) onError;

	const _EmailStepWidget({
		required this.userService,
		required this.onEmailSent,
		required this.onError,
	});

	@override
	State<_EmailStepWidget> createState() => _EmailStepWidgetState();
}

class _EmailStepWidgetState extends State<_EmailStepWidget> {
	final TextEditingController _emailController = TextEditingController();
	bool _isSending = false;

	@override
	void dispose() {
		_emailController.dispose();
		super.dispose();
	}

	bool _isValidEmail(String value) {
		final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
		return emailRegex.hasMatch(value);
	}

	Future<void> _sendOtp() async {
		final email = _emailController.text.trim();
		if (email.isEmpty || !_isValidEmail(email)) {
			widget.onError('Vui lòng nhập email hợp lệ');
			return;
		}

		setState(() {
			_isSending = true;
		});

		final success = await widget.userService.ForgotPassword(
			ForgotPasswordRequest(email: email),
		);

		setState(() {
			_isSending = false;
		});

		if (success) {
			widget.onEmailSent(email);
		} else {
			widget.onError(widget.userService.lastError ?? 'Gửi OTP thất bại');
		}
	}

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				const Text(
					'Nhập email của bạn',
					style: TextStyle(
						fontSize: 16,
						fontWeight: FontWeight.w600,
						color: AppColors.primaryDark,
					),
				),
				const SizedBox(height: 8),
				const Text(
					'Chúng tôi sẽ gửi mã OTP tới email này',
					style: TextStyle(
						fontSize: 13,
						color: AppColors.textSecondary,
					),
				),
				const SizedBox(height: 20),
				TextField(
					controller: _emailController,
					keyboardType: TextInputType.emailAddress,
					decoration: InputDecoration(
						labelText: 'Email',
						prefixIcon: const Icon(Icons.email_outlined),
						border: OutlineInputBorder(
							borderRadius: BorderRadius.circular(12),
						),
						enabledBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(12),
							borderSide: const BorderSide(color: AppColors.primaryLight),
						),
						focusedBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(12),
							borderSide: const BorderSide(color: AppColors.primary),
						),
					),
				),
				const SizedBox(height: 24),
				SizedBox(
					width: double.infinity,
					height: 50,
					child: ElevatedButton(
						onPressed: _isSending ? null : _sendOtp,
						style: ElevatedButton.styleFrom(
							backgroundColor: AppColors.primary,
							foregroundColor: Colors.white,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(12),
							),
						),
						child: _isSending
							? const SizedBox(
								width: 20,
								height: 20,
								child: CircularProgressIndicator(
									strokeWidth: 2,
									color: Colors.white,
								),
							)
							: const Text('Gửi mã OTP'),
					),
				),
			],
		);
	}
}

class _OtpStepWidget extends StatefulWidget {
	final String email;
	final UserService userService;
	final Function(String) onOtpVerified;
	final Function(String) onError;

	const _OtpStepWidget({
		required this.email,
		required this.userService,
		required this.onOtpVerified,
		required this.onError,
	});

	@override
	State<_OtpStepWidget> createState() => _OtpStepWidgetState();
}

class _OtpStepWidgetState extends State<_OtpStepWidget> {
	late List<TextEditingController> _otpControllers;
	late List<FocusNode> _focusNodes;
	bool _isVerifying = false;

	void _fillOtpFromPaste(int startIndex, String rawValue) {
		final digits = rawValue.replaceAll(RegExp(r'\D'), '');
		if (digits.isEmpty) return;

		var writeIndex = startIndex;
		for (var i = 0; i < digits.length && writeIndex < _otpControllers.length; i++) {
			_otpControllers[writeIndex].text = digits[i];
			writeIndex++;
		}

		final nextFocusIndex = writeIndex >= _focusNodes.length
				? _focusNodes.length - 1
				: writeIndex;
		_focusNodes[nextFocusIndex].requestFocus();
	}

	@override
	void initState() {
		super.initState();
		_otpControllers = List.generate(6, (_) => TextEditingController());
		_focusNodes = List.generate(6, (_) => FocusNode());
	}

	@override
	void dispose() {
		for (final controller in _otpControllers) {
			controller.dispose();
		}
		for (final node in _focusNodes) {
			node.dispose();
		}
		super.dispose();
	}

	void _onOtpFieldChanged(int index, String value) {
		if (value.isEmpty) return;

		if (value.length > 1) {
			_fillOtpFromPaste(index, value);
			return;
		}

		// Keep each box numeric and single-char.
		final onlyDigit = value.replaceAll(RegExp(r'\D'), '');
		if (onlyDigit.isEmpty) {
			_otpControllers[index].clear();
			return;
		}
		if (onlyDigit != value) {
			_otpControllers[index].text = onlyDigit[0];
			_otpControllers[index].selection = TextSelection.fromPosition(
				const TextPosition(offset: 1),
			);
		}

		if (index < 5) {
			_focusNodes[index + 1].requestFocus();
		}
	}

	String _getOtp() {
		return _otpControllers.map((c) => c.text).join();
	}

	Future<void> _verifyOtp() async {
		final otp = _getOtp();
		if (otp.length < 6) {
			widget.onError('Vui lòng nhập đầy đủ 6 chữ số OTP');
			return;
		}

		setState(() {
			_isVerifying = true;
		});

		final success = await widget.userService.VerifyResetOtp(
			VerifyResetOtpRequest(email: widget.email, otp: otp),
		);

		setState(() {
			_isVerifying = false;
		});

		if (success) {
			widget.onOtpVerified(otp);
		} else {
			widget.onError(widget.userService.lastError ?? 'OTP không hợp lệ');
		}
	}

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				const Text(
					'Nhập mã OTP',
					style: TextStyle(
						fontSize: 16,
						fontWeight: FontWeight.w600,
						color: AppColors.primaryDark,
					),
				),
				const SizedBox(height: 8),
				Text(
					'Chúng tôi đã gửi mã 6 chữ số tới ${widget.email}',
					style: const TextStyle(
						fontSize: 13,
						color: AppColors.textSecondary,
					),
				),
				const SizedBox(height: 30),
				Row(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: List.generate(
						6,
						(index) => SizedBox(
							width: 50,
							height: 60,
							child: TextField(
								controller: _otpControllers[index],
								focusNode: _focusNodes[index],
								textAlign: TextAlign.center,
								textAlignVertical: TextAlignVertical.center,
								keyboardType: TextInputType.number,
								inputFormatters: [FilteringTextInputFormatter.digitsOnly],
								onChanged: (value) => _onOtpFieldChanged(index, value),
								decoration: InputDecoration(
									isDense: true,
									contentPadding: const EdgeInsets.symmetric(vertical: 14),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
									),
									enabledBorder: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(
											color: AppColors.primaryLight,
										),
									),
									focusedBorder: OutlineInputBorder(
										borderRadius: BorderRadius.circular(10),
										borderSide: const BorderSide(
											color: AppColors.primary,
											width: 2,
										),
									),
								),
								style: const TextStyle(
									fontSize: 22,
									fontWeight: FontWeight.w700,
									height: 1.1,
								),
							),
						),
					),
				),
				const SizedBox(height: 30),
				SizedBox(
					width: double.infinity,
					height: 50,
					child: ElevatedButton(
						onPressed: _isVerifying ? null : _verifyOtp,
						style: ElevatedButton.styleFrom(
							backgroundColor: AppColors.primary,
							foregroundColor: Colors.white,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(12),
							),
						),
						child: _isVerifying
							? const SizedBox(
								width: 20,
								height: 20,
								child: CircularProgressIndicator(
									strokeWidth: 2,
									color: Colors.white,
								),
							)
							: const Text('Xác thực OTP'),
					),
				),
			],
		);
	}
}

class _PasswordStepWidget extends StatefulWidget {
	final String email;
	final String otp;
	final UserService userService;
	final Function() onPasswordReset;
	final Function(String) onError;

	const _PasswordStepWidget({
		required this.email,
		required this.otp,
		required this.userService,
		required this.onPasswordReset,
		required this.onError,
	});

	@override
	State<_PasswordStepWidget> createState() => _PasswordStepWidgetState();
}

class _PasswordStepWidgetState extends State<_PasswordStepWidget> {
	final TextEditingController _passwordController = TextEditingController();
	final TextEditingController _confirmController = TextEditingController();
	bool _obscurePassword = true;
	bool _obscureConfirm = true;
	bool _isResetting = false;

	@override
	void dispose() {
		_passwordController.dispose();
		_confirmController.dispose();
		super.dispose();
	}

	Future<void> _resetPassword() async {
		final password = _passwordController.text;
		final confirm = _confirmController.text;

		if (password.isEmpty || confirm.isEmpty) {
			widget.onError('Vui lòng nhập đầy đủ mật khẩu');
			return;
		}

		if (password.length < 6) {
			widget.onError('Mật khẩu phải có ít nhất 6 ký tự');
			return;
		}

		if (password != confirm) {
			widget.onError('Mật khẩu không khớp');
			return;
		}

		setState(() {
			_isResetting = true;
		});

		final success = await widget.userService.ResetPassword(
			ResetPasswordRequest(
				email: widget.email,
				otp: widget.otp,
				password: password,
			),
		);

		setState(() {
			_isResetting = false;
		});

		if (success) {
			widget.onPasswordReset();
		} else {
			widget.onError(widget.userService.lastError ?? 'Đặt lại mật khẩu thất bại');
		}
	}

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				const Text(
					'Đặt mật khẩu mới',
					style: TextStyle(
						fontSize: 16,
						fontWeight: FontWeight.w600,
						color: AppColors.primaryDark,
					),
				),
				const SizedBox(height: 8),
				const Text(
					'Nhập mật khẩu mới để hoàn tất khôi phục',
					style: TextStyle(
						fontSize: 13,
						color: AppColors.textSecondary,
					),
				),
				const SizedBox(height: 20),
				TextField(
					controller: _passwordController,
					obscureText: _obscurePassword,
					decoration: InputDecoration(
						labelText: 'Mật khẩu mới',
						prefixIcon: const Icon(Icons.lock_outlined),
						suffixIcon: IconButton(
							icon: Icon(
								_obscurePassword
									? Icons.visibility_off_outlined
									: Icons.visibility_outlined,
							),
							onPressed: () {
								setState(() {
									_obscurePassword = !_obscurePassword;
								});
							},
						),
						border: OutlineInputBorder(
							borderRadius: BorderRadius.circular(12),
						),
						enabledBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(12),
							borderSide: const BorderSide(color: AppColors.primaryLight),
						),
						focusedBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(12),
							borderSide: const BorderSide(color: AppColors.primary),
						),
					),
				),
				const SizedBox(height: 12),
				TextField(
					controller: _confirmController,
					obscureText: _obscureConfirm,
					decoration: InputDecoration(
						labelText: 'Xác nhận mật khẩu',
						prefixIcon: const Icon(Icons.lock_outlined),
						suffixIcon: IconButton(
							icon: Icon(
								_obscureConfirm
									? Icons.visibility_off_outlined
									: Icons.visibility_outlined,
							),
							onPressed: () {
								setState(() {
									_obscureConfirm = !_obscureConfirm;
								});
							},
						),
						border: OutlineInputBorder(
							borderRadius: BorderRadius.circular(12),
						),
						enabledBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(12),
							borderSide: const BorderSide(color: AppColors.primaryLight),
						),
						focusedBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(12),
							borderSide: const BorderSide(color: AppColors.primary),
						),
					),
				),
				const SizedBox(height: 24),
				SizedBox(
					width: double.infinity,
					height: 50,
					child: ElevatedButton(
						onPressed: _isResetting ? null : _resetPassword,
						style: ElevatedButton.styleFrom(
							backgroundColor: AppColors.primary,
							foregroundColor: Colors.white,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(12),
							),
						),
						child: _isResetting
							? const SizedBox(
								width: 20,
								height: 20,
								child: CircularProgressIndicator(
									strokeWidth: 2,
									color: Colors.white,
								),
							)
							: const Text('Đặt lại mật khẩu'),
					),
				),
			],
		);
	}
}
