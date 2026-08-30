import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../data/booking_store.dart';
import '../data/cart_store.dart';
import '../models/booking_model.dart';
import '../models/place_item_model.dart';
import '../widgets/app_image.dart';
import '../widgets/luxury_toast.dart';

/// "سلاتك": items added from the details screen via "احجز الآن". The customer
/// then confirms ALL of them at once, which turns them into booking requests
/// that the admin dashboard receives (separated per customer) to accept.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<PlaceItem> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    CartStore.instance.init();
    CartStore.instance.addListener(_onCartChanged);
    // Show whatever is already cached instantly, then refresh from Firestore
    // in the background — no waiting spinner when the cart is known.
    _items = CartStore.instance.items;
    _loading = _items.isEmpty;
    if (_items.isEmpty) CartStore.instance.reload();
  }

  @override
  void dispose() {
    CartStore.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (!mounted) return;
    setState(() {
      _items = CartStore.instance.items;
      _loading = false;
    });
  }

  Future<void> _load() async {
    final items = await CartStore.instance.reload();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _remove(PlaceItem item) async {
    await CartStore.instance.remove(item.id);
  }

  int _priceOf(PlaceItem item) {
    final match = RegExp(r'\d[\d,]*').firstMatch(item.price);
    if (match == null) return 0;
    return int.tryParse(match.group(0)!.replaceAll(',', '')) ?? 0;
  }

  String _formatPrice(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  Future<void> _confirmAll() async {
    if (_items.isEmpty) return;
    final customerId = await BookingStore.instance.getOrCreateCustomerId();
    final now = DateTime.now().toIso8601String();
    // Submit every booking together (parallel) so confirmation is instant even
    // with several items, then clear the cart.
    await Future.wait([
      for (var i = 0; i < _items.length; i++)
        _submitBooking(_items[i], customerId, now, i),
    ]);
    await CartStore.instance.clear();
    if (!mounted) return;
    // Return to the home screen immediately, with the confirmation box shown
    // centered on top of it for 2 seconds.
    final navigator = Navigator.of(context);
    navigator.pop(true);
    showLuxuryToast(navigator.context, 'تم إرسال طلباتك، جاري تلبية طلبك');
  }

  Future<void> _submitBooking(
    PlaceItem item,
    String customerId,
    String now,
    int index,
  ) {
    final booking = Booking(
      id: 'b${DateTime.now().microsecondsSinceEpoch}_${item.id}_$index',
      customerId: customerId,
      itemId: item.id,
      itemName: item.name,
      itemCategory: item.category,
      itemImage: item.mainImage,
      date: item.bookedDate?.isNotEmpty == true ? item.bookedDate! : 'اليوم',
      location: item.location,
      services: item.features,
      totalPrice: _priceOf(item),
      createdAt: now,
    );
    return BookingStore.instance.add(booking);
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.fold<int>(0, (sum, e) => sum + _priceOf(e));
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
                    Icons.receipt_long_outlined,
                    color: AppColors.primaryGold,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سلاتك',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryGold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        '${_items.length} عنصر',
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold,
                      ),
                    )
                  : _items.isEmpty
                      ? const _EmptyCart()
                      : RefreshIndicator(
                          color: AppColors.primaryGold,
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            itemBuilder: (context, index) => _CartCard(
                              item: _items[index],
                              onRemove: () => _remove(_items[index]),
                            ),
                          ),
                        ),
            ),
            if (_items.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.cardDark,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.containerBorder,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ريال ${_formatPrice(total)}',
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'السعر الكلي',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _confirmAll,
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.black,
                        ),
                        label: Text(
                          'تأكيد كل الحجوزات (${_items.length})',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'بعد التأكيد ستصل طلباتك للإدارة ويرد عليك الإشعار',
                      style: TextStyle(color: AppColors.textGray, fontSize: 11),
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

class _CartCard extends StatelessWidget {
  final PlaceItem item;
  final VoidCallback onRemove;

  const _CartCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              width: 72,
              height: 72,
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
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                  ),
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
                if (item.bookedDate?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.event,
                        color: AppColors.primaryGold,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.bookedDate!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.lightGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'إزالة من السلة',
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFE57373),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.remove_shopping_cart_outlined,
            color: AppColors.textGray,
            size: 56,
          ),
          SizedBox(height: 14),
          Text(
            'سلاتك فارغة',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'اضغط "حجز الآن" في أي عنصر ليُضاف هنا',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}