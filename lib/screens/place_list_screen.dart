import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../data/catalog.dart';
import '../data/place_store.dart';
import '../models/place_item_model.dart';
import '../widgets/app_image.dart';
import '../widgets/demo_ads.dart';
import 'place_details_screen.dart';

/// Generic listing screen for any category. Shows all items of the category
/// in rectangular cards; tapping one opens its details screen.
///
/// Built-in catalog items are merged with any user-added items of the same
/// category that were saved to the shared local store (via the dashboard).
/// When [governorate] is set, only services located in that governorate are
/// shown; if there are none an empty state is displayed.
class PlaceListScreen extends StatefulWidget {
  final CategoryCatalog catalog;
  final String? governorate;

  const PlaceListScreen({
    super.key,
    required this.catalog,
    this.governorate,
  });

  @override
  State<PlaceListScreen> createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  List<PlaceItem> _items = const [];

  /// Items shown after applying the selected governorate filter.
  List<PlaceItem> get _displayItems {
    final gov = widget.governorate;
    if (gov == null || gov.isEmpty) return _items;
    return _items.where((e) => e.location.contains(gov)).toList();
  }

  @override
  void initState() {
    super.initState();
    PlaceStore.instance.addListener(_onItemsChanged);
    // Show instantly from the cache (built-ins are always available), then
    // refresh from Firestore in the background — no loading delay.
    _items = PlaceStore.instance
        .forCategory(widget.catalog.id, widget.catalog.items);
    PlaceStore.instance.reload();
  }

  @override
  void dispose() {
    PlaceStore.instance.removeListener(_onItemsChanged);
    super.dispose();
  }

  void _onItemsChanged() {
    if (!mounted) return;
    setState(_apply);
  }

  void _apply() {
    _items = PlaceStore.instance
        .forCategory(widget.catalog.id, widget.catalog.items);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = widget.catalog;
    final governorate = widget.governorate;
    final displayItems = _displayItems;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
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
                  Icon(catalog.icon, color: AppColors.primaryGold, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      catalog.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Section title + subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catalog.title,
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    governorate == null
                        ? catalog.subtitle
                        : '$governorate • ${catalog.subtitle}',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (kDemoAdsEnabled) ...[
              const SizedBox(height: 12),
              const DemoAdsBanner(),
            ],
            const SizedBox(height: 14),

            Expanded(
              child: displayItems.isEmpty
                  ? _EmptyList(governorate: governorate)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayItems.length,
                      itemBuilder: (context, index) {
                        final item = displayItems[index];
                        return _PlaceCard(
                          item: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PlaceDetailsScreen(item: item),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state shown when the selected governorate has no services yet.
class _EmptyList extends StatelessWidget {
  final String? governorate;

  const _EmptyList({this.governorate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGold.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.location_off_outlined,
                color: AppColors.primaryGold,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              governorate == null
                  ? 'لا توجد خدمات هنا بعد'
                  : 'لا توجد خدمات في $governorate',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'أضف خدمات جديدة من لوحة التحكم وستظهر هنا فوراً.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rectangular elegant card: image on top, name + price below.
class _PlaceCard extends StatelessWidget {
  final PlaceItem item;
  final VoidCallback onTap;

  const _PlaceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (top, rectangular)
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: AppImage(
                    source: item.mainImage,
                    fit: BoxFit.cover,
                    fallbackIcon: item.defaultIcon,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
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
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          item.rating.toStringAsFixed(1),
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
              ],
            ),
            // Name + price
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.capacity != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          color: AppColors.textGray,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'يتسع لـ ${item.capacity}',
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Price
                  Row(
                    children: [
                      Text(
                        item.price,
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.priceType != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(${item.priceType})',
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 11,
                          ),
                        ),
                      ],
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
