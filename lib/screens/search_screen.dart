import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../data/catalog.dart';
import '../data/place_store.dart';
import '../models/place_item_model.dart';
import '../widgets/app_image.dart';
import 'place_details_screen.dart';
import 'place_list_screen.dart';

/// A found item paired with the section it belongs to.
class _SearchResult {
  final CategoryCatalog catalog;
  final PlaceItem item;

  _SearchResult({required this.catalog, required this.item});
}

/// Global search screen. Searches the needed section/item across every
/// category in the app (built-in catalog + admin-dashboard items).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  List<PlaceItem> _storeItems = const [];

  @override
  void initState() {
    super.initState();
    PlaceStore.instance.addListener(_onStoreChanged);
    // Show instantly from the cache, then refresh from Firestore in the
    // background so the search always has the latest dashboard items.
    _storeItems = PlaceStore.instance.items;
    PlaceStore.instance.reload();
  }

  @override
  void dispose() {
    PlaceStore.instance.removeListener(_onStoreChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (!mounted) return;
    setState(() => _storeItems = PlaceStore.instance.items);
  }

  String _normalize(String value) => value.trim().toLowerCase();

  bool _queryMatches(String value) =>
      _normalize(value).contains(_normalize(_query));

  List<CategoryCatalog> get _sections {
    if (_query.trim().isEmpty) return allCatalogs;
    return allCatalogs
        .where((c) => _queryMatches(c.title) || _queryMatches(c.subtitle))
        .toList();
  }

  List<_SearchResult> get _results {
    final results = <_SearchResult>[];
    for (final catalog in allCatalogs) {
      for (final item in catalog.items) {
        if (_matches(item)) {
          results.add(_SearchResult(catalog: catalog, item: item));
        }
      }
    }
    for (final item in _storeItems) {
      if (item.catalogId == null) continue;
      if (_matches(item)) {
        results.add(
          _SearchResult(
            catalog: catalogFor(item.catalogId!),
            item: item,
          ),
        );
      }
    }
    return results;
  }

  bool _matches(PlaceItem item) {
    final q = _normalize(_query);
    if (q.isEmpty) return true;
    final fields = [
      item.name,
      item.category,
      item.description ?? '',
      item.location,
      item.price,
      item.priceType ?? '',
      item.capacity ?? '',
      item.features.join(' '),
      item.specs.values.join(' '),
    ];
    return fields.any((f) => _normalize(f).contains(q));
  }

  void _openSection(CategoryCatalog catalog) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceListScreen(catalog: catalog),
      ),
    );
  }

  void _openItem(_SearchResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailsScreen(item: result.item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sections;
    final results = _results;
    final hasQuery = _query.trim().isNotEmpty;
    final isEmpty = sections.isEmpty && results.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Row(
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
                        Icons.search,
                        color: AppColors.primaryGold,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'البحث في كل الأقسام',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.primaryGold,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'ابحث عن قاعة، مصور، كوشة...',
                              hintStyle: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(
                              Icons.close,
                              color: AppColors.textGray,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: isEmpty
                  ? const _EmptyResults()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        if (sections.isNotEmpty) ...[
                          const _ResultsHeader(
                            title: 'الأقسام',
                            icon: Icons.grid_view_rounded,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final section in sections)
                                _SectionChip(
                                  section: section,
                                  onTap: () => _openSection(section),
                                ),
                            ],
                          ),
                          const SizedBox(height: 22),
                        ],
                        if (results.isNotEmpty) ...[
                          _ResultsHeader(
                            title: hasQuery
                                ? 'النتائج (${results.length})'
                                : 'كل الخدمات والأماكن',
                            icon: Icons.storefront_outlined,
                          ),
                          const SizedBox(height: 12),
                          for (final result in results)
                            _ResultCard(
                              result: result,
                              onTap: () => _openItem(result),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ResultsHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.6),
            ),
          ),
          child: Icon(icon, color: AppColors.primaryGold, size: 15),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SectionChip extends StatelessWidget {
  final CategoryCatalog section;
  final VoidCallback onTap;

  const _SectionChip({required this.section, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(section.icon, color: AppColors.primaryGold, size: 18),
            const SizedBox(width: 8),
            Text(
              section.title,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _SearchResult result;
  final VoidCallback onTap;

  const _ResultCard({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final item = result.item;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 84,
                height: 84,
                child: AppImage(
                  source: item.mainImage,
                  fit: BoxFit.cover,
                  fallbackIcon: item.defaultIcon,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      result.catalog.title,
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.textGray,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.price,
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left,
              color: AppColors.textGray,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off,
            color: AppColors.textGray,
            size: 46,
          ),
          const SizedBox(height: 12),
          const Text(
            'لا توجد نتائج',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'لم نجد ما يطابق بحثك، جرّب كلمة أخرى',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}