import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../data/customer_store.dart';
import '../widgets/luxury_toast.dart';
import 'home_screen.dart';

/// Mandatory login screen (only two fields: the customer's name and phone
/// number). The account is bound to the phone number, so the same number
/// always restores the same account (its bookings and cart) on any device.
/// The home screen never opens until the login is completed.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final overlayContext = navigator.context;
    setState(() => _submitting = true);
    final profile = await CustomerStore.instance.ensureProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    if (profile.customerId.isEmpty || !overlayContext.mounted) {
      if (mounted) setState(() => _submitting = false);
      return;
    }
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
    await showLuxuryToast(
      overlayContext,
      'مرحباً بك ${profile.fullName}',
    );
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'حقل الاسم مطلوب';
    if (v.length < 2) return 'الاسم قصير جداً';
    return null;
  }

  String? _validatePhone(String? value) {
    final v = value?.trim() ?? '';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'رقم الهاتف مطلوب';
    if (!RegExp(r'^(71|73|77|78)\d{7}$').hasMatch(digits)) {
      return 'يبدأ بـ 71 أو 73 أو 77 أو 78 ويتكون من 9 أرقام';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF241735),
              Color(0xFF1A1326),
              AppColors.backgroundDark,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Ambient gold glow drifting at the top.
              const Positioned(
                top: -140,
                left: -100,
                child: _GlowOrb(radius: 300, color: Color(0x33D4AF37)),
              ),
              const Positioned(
                bottom: -160,
                right: -140,
                child: _GlowOrb(radius: 340, color: Color(0x223F9CE0)),
              ),
              // Faint ornamental dots.
              const Positioned(
                top: 120,
                right: 30,
                child: _Dot(color: Color(0x66D4AF37), size: 4),
              ),
              const Positioned(
                top: 210,
                left: 24,
                child: _Dot(color: Color(0x33D4AF37), size: 6),
              ),

              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.85 + 0.15 * value,
                          child: child,
                        ),
                      ),
                      child: const _LaurelEmblem(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'حفلة',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: AppColors.primaryGold,
                            blurRadius: 28,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'سجّل بياناتك لخطّط مناسبتك بلمسة فخمة',
                      style: TextStyle(color: AppColors.textGray, fontSize: 13),
                    ),
                    const SizedBox(height: 28),

                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 850),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 28 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: _buildCard(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.18),
            blurRadius: 34,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إنشاء حسابك',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'خانتان فقط: اسمك ورقم هاتفك',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _FieldLabel('الاسم', required: true),
            const SizedBox(height: 6),
            AppGoldTextField(
              controller: _nameCtrl,
              hintText: 'اكتب اسمك الكامل',
              icon: Icons.badge_outlined,
              validator: _validateName,
            ),
            const SizedBox(height: 14),
            const _FieldLabel('رقم الهاتف', required: true),
            const SizedBox(height: 6),
            AppGoldTextField(
              controller: _phoneCtrl,
              hintText: 'مثال: 0771234567',
              icon: Icons.phone_iphone,
              keyboardType: TextInputType.phone,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              validator: _validatePhone,
            ),
            const SizedBox(height: 22),
            _LuxButton(
              label: 'بدء الرحلة',
              loading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_outlined, color: AppColors.textGray, size: 13),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'بياناتك تُحفظ بأمان في سحابة Firebase',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textGray, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ornamental gold emblem above the title.
class _LaurelEmblem extends StatelessWidget {
  const _LaurelEmblem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGold, AppColors.lightGold],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.55),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.celebration, color: Colors.black87, size: 46),
    );
  }
}

/// Soft radial glow used as a background ornament.
class _GlowOrb extends StatelessWidget {
  final double radius;
  final Color color;

  const _GlowOrb({required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          radius: 0.6,
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;

  const _Dot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _FieldLabel(this.label, {required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: AppColors.primaryGold, fontSize: 14),
          ),
        ],
      ],
    );
  }
}

/// Luxury dark text field with a soft gold focus glow.
class AppGoldTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;

  const AppGoldTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.icon,
    this.keyboardType,
    this.formatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 13),
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: AppColors.primaryGold, size: 20),
        suffixIcon: const Icon(
          Icons.edit_outlined,
          color: AppColors.textGray,
          size: 18,
        ),
        filled: true,
        fillColor: AppColors.backgroundDark.withValues(alpha: 0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryGold.withValues(alpha: 0.22),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.3),
        ),
        errorStyle: const TextStyle(color: Color(0xFFE57373), fontSize: 11),
      ),
    );
  }
}

/// Luxurious full-width gold gradient button.
class _LuxButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _LuxButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryGold, AppColors.lightGold],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.45),
              blurRadius: 20,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: loading ? null : onPressed,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.black87,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}