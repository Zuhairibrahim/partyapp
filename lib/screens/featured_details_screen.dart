import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_colors.dart';
import '../models/featured_provider.dart';
import '../widgets/app_image.dart';
import '../widgets/demo_ads.dart';

/// Full details of a featured provider (مقدمون مميزون): cover photo, name,
/// specialty, rating, price, capacity, description and contact (WhatsApp or a
/// phone call). Opened when the customer taps a card in the home strip.
class FeaturedDetailsScreen extends StatelessWidget {
  final FeaturedProvider provider;

  const FeaturedDetailsScreen({super.key, required this.provider});

  /// Normalizes a phone number into an international dial string for Yemen.
  static String _intlPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00967')) return digits.substring(4);
    if (digits.startsWith('967')) return digits;
    if (digits.startsWith('0')) return '967${digits.substring(1)}';
    return '967$digits';
  }

  Future<void> _call() async {
    final uri = Uri.parse('tel:${_intlPhone(provider.phone ?? '')}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // No dialer available; stay in the app.
    }
  }

  Future<void> _whatsApp() async {
    final number = _intlPhone(provider.phone ?? '');
    final uri = Uri.parse(
      'https://wa.me/$number'
      '?text=${Uri.encodeComponent('مرحباً، تواصلت معك من تطبيق حفلة بخصوص: ${provider.name}')}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // WhatsApp is not installed; stay in the app.
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = this.provider;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    const Expanded(
                      child: Text(
                        'تفاصيل الخدمة',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.workspace_premium_outlined,
                      color: AppColors.primaryGold,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Cover photo
              Container(
                height: 260,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.45),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      source: provider.image,
                      fallbackIcon: Icons.workspace_premium_outlined,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.primaryGold,
                              size: 15,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              provider.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          if (provider.category != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold
                                        .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    provider.category!,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (kDemoAdsEnabled) ...[
                const DemoAdsBanner(),
                const SizedBox(height: 8),
              ],

              // Core info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.location != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primaryGold,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              provider.location!,
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          provider.price,
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (provider.priceType != null) ...[
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '(${provider.priceType})',
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (provider.capacity != null) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryGold.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  color: AppColors.primaryGold,
                                  size: 17,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'السعة: ${provider.capacity}',
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (provider.description != null &&
                        provider.description!.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const Text(
                        'عن الخدمة',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.containerBorder,
                          ),
                        ),
                        child: Text(
                          provider.description!,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Contact actions
              if (provider.phone != null && provider.phone!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ContactButton(
                          icon: Icons.chat,
                          label: 'واتساب',
                          background: const Color(0xFF25D366),
                          onPressed: _whatsApp,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ContactButton(
                          icon: Icons.call,
                          label: 'اتصال',
                          background: AppColors.primaryGold,
                          onPressed: _call,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final VoidCallback onPressed;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: background.withValues(alpha: 0.4),
                blurRadius: 14,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}