import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/demo_ads.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key});

  static const List<_ServiceOption> _services = [
    _ServiceOption(
      title: 'المصور',
      price: 'ريال 3,000',
      imagePath:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    ),
    _ServiceOption(
      title: 'الدي جي',
      price: 'ريال 2,500',
      imagePath:
          'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7',
    ),
    _ServiceOption(
      title: 'الفيديو',
      price: 'ريال 4,000',
      imagePath:
          'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.textWhite,
                        size: 18,
                      ),
                    ),
                    const Text(
                      'حفلك',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Large Hall Image banner with overlay text
              Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1519741497674-611481863552',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.cardDark,
                                AppColors.primaryGold,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Text(
                        'احجز حفلتك الان',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
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

              // Services Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'الباقات والخدمات',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Horizontal Services Options (المصور، الدي جي، الفيديو)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final service in _services) ...[
                      _ServiceCard(service: service),
                      const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceOption {
  final String title;
  final String price;
  final String imagePath;

  const _ServiceOption({
    required this.title,
    required this.price,
    required this.imagePath,
  });
}

class _ServiceCard extends StatelessWidget {
  final _ServiceOption service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 70,
            width: double.infinity,
            child: Image.network(
              service.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.primaryGold,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  service.title,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.price,
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 10,
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