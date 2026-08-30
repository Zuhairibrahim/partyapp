import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_colors.dart';
import '../data/cart_store.dart';
import '../data/catalog.dart';
import '../data/customer_store.dart';
import '../data/featured_store.dart';
import '../data/governorates.dart';
import '../data/place_store.dart';
import '../models/customer_profile.dart';
import '../models/event_category_model.dart';
import '../models/featured_provider.dart';
import '../models/place_item_model.dart';
import '../widgets/demo_ads.dart';
import 'cart_screen.dart';
import 'featured_details_screen.dart';
import 'notifications_screen.dart';
import 'place_list_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedGovernorate;
  int _cartCount = 0;
  CustomerProfile? _profile;
  List<FeaturedProvider> _featured = const [];
  List<PlaceItem> _places = const [];

  @override
  void initState() {
    super.initState();
    PlaceStore.instance.addListener(_onPlacesChanged);
    _places = PlaceStore.instance.items;
    PlaceStore.instance.reload();
    FeaturedStore.instance.addListener(_onFeaturedChanged);
    _featured = FeaturedStore.instance.items;
    CartStore.instance.init();
    CartStore.instance.addListener(_onCartChanged);
    _loadCartCount();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDemoAdsInterstitial(context);
    });
  }

  @override
  void dispose() {
    PlaceStore.instance.removeListener(_onPlacesChanged);
    FeaturedStore.instance.removeListener(_onFeaturedChanged);
    CartStore.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onPlacesChanged() {
    if (!mounted) return;
    setState(() => _places = PlaceStore.instance.items);
  }

  void _onFeaturedChanged() {
    if (!mounted) return;
    setState(() => _featured = FeaturedStore.instance.items);
  }

  void _loadCartCount() {
    CartStore.instance.init();
    setState(() => _cartCount = CartStore.instance.items.length);
  }

  void _onCartChanged() {
    if (!mounted) return;
    setState(() => _cartCount = CartStore.instance.items.length);
  }

  /// Whether the selected governorate has any service in [catalogId]. When no
  /// governorate is chosen everything is considered available.
  bool _hasServices(String catalogId) {
    final gov = _selectedGovernorate;
    if (gov == null) return true;
    return _places.any(
      (p) => p.catalogId == catalogId && p.location.contains(gov),
    );
  }

  /// Categories with services in the selected governorate.
  List<EventCategory> get _visibleCategories =>
      _categories.where((c) => _hasServices(c.id)).toList();

  /// Party services with services in the selected governorate.
  List<EventCategory> get _visiblePartyServices =>
      _partyServices.where((c) => _hasServices(c.id)).toList();

  /// Featured providers located in the selected governorate.
  List<FeaturedProvider> get _visibleFeatured {
    final gov = _selectedGovernorate;
    if (gov == null) return _featured;
    return _featured.where((f) => f.location == gov).toList();
  }

  Future<void> _loadProfile() async {
    final profile = await CustomerStore.instance.load();
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  Future<void> _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
    _loadCartCount();
  }

  static const List<EventCategory> _categories = [
    EventCategory(
      id: 'photographers',
      title: 'المصورين',
      imagePath:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
      icon: Icons.photo_camera_outlined,
    ),
    EventCategory(
      id: 'halls',
      title: 'القاعات',
      imagePath:
          'https://images.unsplash.com/photo-1505373877841-8d25f7d46678',
      icon: Icons.home_work_outlined,
    ),
    EventCategory(
      id: 'chalets',
      title: 'الشاليهات',
      imagePath:
          'https://images.unsplash.com/photo-1493246507139-91e8fad9978e',
      icon: Icons.holiday_village_outlined,
    ),
    EventCategory(
      id: 'parks',
      title: 'المنتزه',
      imagePath:
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e',
      icon: Icons.park_outlined,
    ),
    EventCategory(
      id: 'salons',
      title: 'الصالات',
      imagePath:
          'https://images.unsplash.com/photo-1519167758481-83f550bb49b3',
      icon: Icons.meeting_room_outlined,
    ),
    EventCategory(
      id: 'photography',
      title: 'التصوير',
      imagePath:
          'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d',
      icon: Icons.camera_alt_outlined,
    ),
    EventCategory(
      id: 'dresses',
      title: 'الفساتين',
      imagePath:
          'https://images.unsplash.com/photo-1509557965870-b8e8d54f7719',
      icon: Icons.checkroom_outlined,
    ),
    EventCategory(
      id: 'lighting',
      title: 'الإضاءات',
      imagePath:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819',
      icon: Icons.highlight_outlined,
    ),
    EventCategory(
      id: 'decoration',
      title: 'الزينة',
      imagePath:
          'https://images.unsplash.com/photo-1519225421980-715cb0215aed',
      icon: Icons.auto_awesome_outlined,
    ),
    EventCategory(
      id: 'kousha',
      title: 'الكوشة',
      imagePath:
          'https://images.unsplash.com/photo-1511795409834-ef04bbd61622',
      icon: Icons.local_florist_outlined,
    ),
  ];

  // Party / event on-day services (منظمين، حراسة، توزيع ماء، بخور)
  static const List<EventCategory> _partyServices = [
    EventCategory(
      id: 'organizers',
      title: 'منظمي الحفلة',
      imagePath:
          'https://images.unsplash.com/photo-1511578314322-379afb476865',
      icon: Icons.event_available_outlined,
    ),
    EventCategory(
      id: 'female_security',
      title: 'حراسة نسائية',
      imagePath:
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
      icon: Icons.verified_user_outlined,
    ),
    EventCategory(
      id: 'water_distribution',
      title: 'توزيع الماء',
      imagePath:
          'https://images.unsplash.com/photo-1548839140-29a749e1cf4d',
      icon: Icons.water_drop_outlined,
    ),
    EventCategory(
      id: 'bakhoor',
      title: 'البخور',
      imagePath:
          'https://images.unsplash.com/photo-1472745433479-4556f22e32c2',
      icon: Icons.air_outlined,
    ),
  ];

  static const String _supportWhatsApp = '967778066436';

  Future<void> _contactSupport() async {
    final uri = Uri.parse(
      'https://wa.me/$_supportWhatsApp'
      '?text=${Uri.encodeComponent('مرحباً، أحتاج مساعدة في تطبيق حفلة')}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Unable to open WhatsApp; quietly keep the app running.
    }
  }

  void _openCategory(BuildContext context, EventCategory category) {
    final catalog = catalogFor(category.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceListScreen(
          catalog: catalog,
          governorate: _selectedGovernorate,
        ),
      ),
    );
  }

  void _openFeaturedDetails(BuildContext context, FeaturedProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeaturedDetailsScreen(provider: provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppHeader(
                onNotificationsTap: _openNotifications,
                onProfileTap: _openProfile,
                greeting: _profile == null
                    ? 'أهلاً بك، خطط مناسبتك بلمسة فخمة'
                    : 'أهلاً ${_profile!.name.trim()}، خطط مناسبتك بلمسة فخمة',
              ),
              const SizedBox(height: 22),
              _LocationSelector(
                selected: _selectedGovernorate,
                onChanged: (value) {
                  setState(() => _selectedGovernorate = value);
                },
              ),
              const SizedBox(height: 18),
              const _SearchBar(),
              const SizedBox(height: 20),
              const _TrustStrip(),
              const SizedBox(height: 14),
              _SupportCard(onPressed: _contactSupport),
              if (kDemoAdsEnabled) ...[
                const SizedBox(height: 16),
                const DemoAdsBanner(),
              ],
              const SizedBox(height: 30),
              const _SectionHeader(
                title: 'أقسامنا',
                subtitle: 'اختر القسم المناسب لمناسبتك',
              ),
              const SizedBox(height: 18),

              // Category cards filtered by the selected governorate
              if (_visibleCategories.isEmpty)
                _NoServicesPlaceholder(governorate: _selectedGovernorate)
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _visibleCategories.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final category = _visibleCategories[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 450 + index * 90),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 24 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _SquareCategoryCard(
                        category: category,
                        onTap: () => _openCategory(context, category),
                      ),
                    );
                  },
                ),
              if (kDemoAdsEnabled) ...[
                const SizedBox(height: 28),
                const DemoAdsBanner(),
                const SizedBox(height: 16),
              ],
              const _SectionHeader(
                title: 'خدمات الحفلة',
                subtitle: 'طاقم متكامل ليوم مناسبتك',
              ),
              const SizedBox(height: 18),

              // Party service cards filtered by the selected governorate
              if (_visiblePartyServices.isEmpty)
                _NoServicesPlaceholder(governorate: _selectedGovernorate)
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _visiblePartyServices.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final service = _visiblePartyServices[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + index * 90),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 24 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _SquareCategoryCard(
                        category: service,
                        onTap: () => _openCategory(context, service),
                      ),
                    );
                  },
                ),
              if (_visibleFeatured.isNotEmpty) ...[
                const SizedBox(height: 30),
                const _SectionHeader(
                  title: 'مقدمون مميزون',
                  subtitle: 'نخبة من أفضل مقدمي الخدمات',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _visibleFeatured.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final v = _visibleFeatured[index];
                      return _VipCard(
                        name: v.name,
                        rating: v.rating,
                        price: v.price,
                        imagePath: v.image,
                        onTap: () => _openFeaturedDetails(context, v),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          border: Border(
            top: BorderSide(
              color: AppColors.containerBorder,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const _BottomNavItem(
              icon: Icons.home,
              label: 'الرئيسية',
              isSelected: true,
            ),
            _BottomNavItem(
              icon: Icons.notifications_none,
              label: 'الإشعارات',
              isSelected: false,
              onTap: _openNotifications,
            ),
            _BottomNavItem(
              icon: Icons.receipt_long_outlined,
              label: 'سلاتك',
              isSelected: false,
              onTap: _openCart,
              badgeCount: _cartCount,
            ),
            _BottomNavItem(
              icon: Icons.person_outline,
              label: 'حسابك',
              isSelected: false,
              onTap: _openProfile,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- App Header
class _AppHeader extends StatelessWidget {
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;
  final String greeting;

  const _AppHeader({
    required this.onNotificationsTap,
    required this.onProfileTap,
    this.greeting = 'أهلاً بك، خطط مناسبتك بلمسة فخمة',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGold.withValues(alpha: 0.6),
                      ),
                    ),
                    child: const Icon(
                      Icons.celebration,
                      color: AppColors.primaryGold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'حفلة',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                greeting,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onNotificationsTap,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
              ),
              Positioned(
                top: 5,
                left: 5,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Color(0xFFE91E63),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGold, AppColors.lightGold],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.black87,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------- Location Selector
class _LocationSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;

  const _LocationSelector({
    required this.selected,
    required this.onChanged,
  });

  void _openSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GovernorateSheet(
        governorates: kGovernorates,
        selected: selected,
        onSelect: (value) {
          onChanged(value);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSelector(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              color: AppColors.primaryGold,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                selected ?? 'حدد المحافظة',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected == null
                      ? AppColors.textWhite
                      : AppColors.primaryGold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryGold,
            ),
          ],
        ),
      ),
    );
  }
}

/// Elegant, luxurious modal list of governorates.
class _GovernorateSheet extends StatelessWidget {
  final List<String> governorates;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _GovernorateSheet({
    required this.governorates,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.of(context).size.height * 0.72;
    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.containerBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_city,
                  color: AppColors.primaryGold,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'اختر المحافظة',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.containerBorder, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: governorates.length,
              itemBuilder: (context, index) {
                final value = governorates[index];
                final isSelected = value == selected;
                return _GovernorateTile(
                  label: value,
                  isSelected: isSelected,
                  onTap: () => onSelect(value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GovernorateTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GovernorateTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primaryGold
                    : AppColors.containerBorder.withValues(alpha: 0.4),
              ),
              child: Icon(
                isSelected
                    ? Icons.check
                    : Icons.location_on_outlined,
                color: isSelected ? Colors.black : AppColors.primaryGold,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.textWhite,
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.verified,
                color: AppColors.primaryGold,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- SearchBar
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  void _openSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSearch(context),
      child: Container(
        height: 50,
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
            Icon(Icons.search, color: AppColors.primaryGold, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'ابحث عن قاعة، مصور، كوشة...',
                style: TextStyle(color: AppColors.textGray, fontSize: 13),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'بحث',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- Trust Strip
class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.containerBorder,
        ),
      ),
      child: const Row(
        children: [
          Expanded(child: _TrustItem(value: '500+', label: 'مناسبة منظمة')),
          _TrustDivider(),
          Expanded(child: _TrustItem(value: '4.9', label: 'تقييم المستخدمين')),
          _TrustDivider(),
          Expanded(child: _TrustItem(value: '24/7', label: 'دعم ومتابعة')),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final String value;
  final String label;

  const _TrustItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _TrustDivider extends StatelessWidget {
  const _TrustDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.containerBorder,
    );
  }
}

// ------------------------------------------------------------ Support Card
class _SupportCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _SupportCard({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGold.withValues(alpha: 0.16),
              AppColors.cardDark,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF25D366).withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التواصل مع الدعم',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'متاحون لمساعدتك عبر واتساب على الرقم 778066436',
                    style: TextStyle(color: AppColors.textGray, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primaryGold,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------- No Services State
class _NoServicesPlaceholder extends StatelessWidget {
  final String? governorate;

  const _NoServicesPlaceholder({this.governorate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              governorate == null
                  ? 'لا توجد خدمات متاحة حالياً'
                  : 'لا توجد خدمات في $governorate حالياً، أضفها من لوحة التحكم وسيظهر القسم هنا',
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold.withValues(alpha: 0.0),
                      AppColors.primaryGold.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.6),
                ),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.primaryGold,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold.withValues(alpha: 0.5),
                      AppColors.primaryGold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Text(
            subtitle,
            style: const TextStyle(color: AppColors.textGray, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------ Square Category Card
class _SquareCategoryCard extends StatelessWidget {
  final EventCategory category;
  final VoidCallback onTap;

  const _SquareCategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.55),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              category.imagePath,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.cardDark, AppColors.primaryGold],
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.cardDark, AppColors.primaryGold],
                    ),
                  ),
                  child: Icon(
                    category.icon,
                    size: 44,
                    color: Colors.black87,
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _GoldTopLine(),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.7),
                  ),
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.primaryGold,
                  size: 16,
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
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

class _GoldTopLine extends StatelessWidget {
  const _GoldTopLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.5,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.primaryGold,
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

// ------------------------------------------------------------------ VIP Card
class _VipCard extends StatelessWidget {
  final String name;
  final double rating;
  final String price;
  final String imagePath;
  final VoidCallback? onTap;

  const _VipCard({
    required this.name,
    required this.rating,
    required this.price,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.4),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imagePath,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.cardDark, AppColors.primaryGold],
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.cardDark, AppColors.primaryGold],
                  ),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.black87,
                  size: 40,
                ),
              );
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.primaryGold,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    rating.toStringAsFixed(1),
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
            left: 10,
            right: 10,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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

// -------------------------------------------------------------- Bottom Nav
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final int? badgeCount;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppColors.primaryGold : AppColors.textGray;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGold.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (badgeCount != null && badgeCount! > 0)
                Positioned(
                  top: -4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.backgroundDark,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}