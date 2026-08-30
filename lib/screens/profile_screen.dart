import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../data/customer_store.dart';
import '../models/customer_profile.dart';
import 'registration_screen.dart';

/// "حسابي": shows the registered name, phone and account id, plus a logout
/// button at the bottom. Logging out clears the local session so the customer
/// is taken back to the mandatory registration screen.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CustomerProfile? _profile;
  bool _loading = true;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await CustomerStore.instance.load();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.primaryGold.withValues(alpha: 0.4),
          ),
        ),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(color: AppColors.textWhite, fontSize: 17),
        ),
        content: const Text(
          'هل تريد حقاً تسجيل الخروج؟ ستُطلب منك إعادة التسجيل للدخول مجدداً.',
          style: TextStyle(color: AppColors.textGray, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'خروج',
              style: TextStyle(
                color: Color(0xFFE57373),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _signingOut = true);
    await CustomerStore.instance.clearLocal();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textWhite,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.person_outline,
                    color: AppColors.primaryGold,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'حسابي',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGold,
                  ),
                ),
              )
            else
              Expanded(
                child: profile == null
                    ? const _MissingProfile()
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _ProfileHeader(profile: profile),
                          const SizedBox(height: 20),
                          _InfoTile(
                            icon: Icons.badge_outlined,
                            label: 'الاسم',
                            value: profile.fullName,
                          ),
                          _InfoTile(
                            icon: Icons.phone_iphone,
                            label: 'رقم الهاتف',
                            value: profile.phone,
                            direction: TextDirection.ltr,
                          ),
                          _InfoTile(
                            icon: Icons.key,
                            label: 'المعرّف الخاص',
                            value: profile.customerId,
                            direction: TextDirection.ltr,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'استخدم هذا المعرّف للتواصل مع الإدارة حول طلباتك',
                            style:
                                TextStyle(color: AppColors.textGray, fontSize: 12),
                          ),
                        ],
                      ),
              ),
            if (profile != null && !_loading)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.cardDark,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.containerBorder,
                      width: 0.5,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE57373),
                      side: const BorderSide(color: Color(0xFFE57373)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _signingOut ? null : _logout,
                    icon: _signingOut
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFE57373),
                            ),
                          )
                        : const Icon(Icons.logout, size: 20),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final CustomerProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final initial = profile.name.trim().characters.first.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.14),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryGold, AppColors.lightGold],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.5),
                  blurRadius: 22,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profile.phone,
            style: const TextStyle(
              color: AppColors.primaryGold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextDirection direction;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.direction = TextDirection.rtl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.containerBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: AppColors.primaryGold, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  textDirection: direction,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
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
}

class _MissingProfile extends StatelessWidget {
  const _MissingProfile();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.person_off_outlined, color: AppColors.textGray, size: 56),
          SizedBox(height: 14),
          Text(
            'لا يوجد حساب مسجل',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}