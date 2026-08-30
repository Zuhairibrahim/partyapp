import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../data/vendors_data.dart';
import '../models/vendor_model.dart';

/// Artists (photographers, videographers...) office contact number.
const kArtistsOfficePhone = '778066436';

/// Shows all wedding vendors; filtered by governorate when one is chosen.
class WeddingVendorsSection extends StatelessWidget {
  final String? governorate;

  const WeddingVendorsSection({super.key, this.governorate});

  @override
  Widget build(BuildContext context) {
    final vendors = governorate == null
        ? allVendors
        : allVendors.where((v) => v.governorate == governorate).toList();

    if (vendors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'لا توجد خدمات مسجلة في هذه المحافظة حالياً',
            style: const TextStyle(color: AppColors.textGray, fontSize: 13),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vendors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return VendorCard(
          vendor: vendor,
          onCall: () => _showContact(context, vendor),
        );
      },
    );
  }

  void _showContact(BuildContext context, Vendor vendor) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  vendor.categoryIcon,
                  color: AppColors.primaryGold,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    vendor.name,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'تواصل مع المحل مباشرة',
              style: TextStyle(color: AppColors.textGray, fontSize: 13),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.phone, color: Colors.black, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    vendor.phone,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'تُعرض الأرقام عند الاتصال عبر الجهاز',
              style: TextStyle(color: AppColors.textGray, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onCall;

  const VendorCard({super.key, required this.vendor, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 90,
            width: double.infinity,
            child: Image.network(
              vendor.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                  child: Icon(
                    vendor.categoryIcon,
                    color: AppColors.primaryGold,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        vendor.categoryIcon,
                        color: AppColors.primaryGold,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vendor.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Icon(Icons.star, color: AppColors.primaryGold, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        vendor.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.textGray,
                        size: 11,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          vendor.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onCall,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryGold.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: AppColors.primaryGold,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'اتصال',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Artists (فنانون) section: contact the office to check travel to the
/// selected governorate.
class ArtistsSection extends StatelessWidget {
  final String? governorate;

  const ArtistsSection({super.key, this.governorate});

  static const _artists = [
    (
      'مصور',
      'لتصوير المناسبات والأعراس',
      Icons.photo_camera_outlined,
    ),
    (
      'مصمم فيديو',
      'تصوير ومونتاج احترافي',
      Icons.videocam_outlined,
    ),
    (
      'دي جي ومنسق حفل',
      'موسيقى وتنظيم فقرات',
      Icons.music_note_outlined,
    ),
    (
      'مزين/مصور الأعراس',
      'فريق فني متكامل',
      Icons.palette_outlined,
    ),
  ];

  void _showOfficeContact(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.headset_mic, color: AppColors.primaryGold, size: 30),
            const SizedBox(height: 10),
            const Text(
              'مكتب الفنانين',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              governorate == null
                  ? 'تواصل مع المكتب للاستفسار عن توفر الفنانين'
                  : 'تواصل مع المكتب للاستفسار عن نزول الفنانين إلى $governorate',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGray, fontSize: 13),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.phone, color: Colors.black, size: 22),
                  SizedBox(height: 6),
                  Text(
                    kArtistsOfficePhone,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'رقم التواصل الخاص بالفنانين',
              style: TextStyle(color: AppColors.textGray, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showOfficeContact(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.5),
              ),
            ),
            child: const Column(
              children: [
                Icon(Icons.headset_mic, color: AppColors.primaryGold, size: 26),
                SizedBox(height: 6),
                Text(
                  'مكتب الفنانيين',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'اضغط للتواصل مع المكتب والتأكد من توفر الفنانين',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGray, fontSize: 12),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: AppColors.primaryGold, size: 15),
                    SizedBox(width: 6),
                    Text(
                      kArtistsOfficePhone,
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _artists.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            final a = _artists[index];
            return GestureDetector(
              onTap: () => _showOfficeContact(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(a.$3, color: AppColors.primaryGold, size: 26),
                    const SizedBox(height: 8),
                    Text(
                      a.$1,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      a.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
