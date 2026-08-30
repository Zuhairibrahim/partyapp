import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../data/booking_store.dart';
import '../models/booking_model.dart';

/// "الإشعارات / طلباتي": the customer's own orders inbox. It only shows the
/// bookings tagged with THIS customer's id (each customer is independent),
/// while the dashboard receives every customer's orders.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Booking> _bookings = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final customerId = await BookingStore.instance.getOrCreateCustomerId();
    final all = await BookingStore.instance.reload();
    final mine =
        all.where((b) => b.customerId == customerId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (!mounted) return;
    setState(() {
      _bookings = mine;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    Icons.notifications_none,
                    color: AppColors.primaryGold,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'طلباتي والإشعارات',
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'طلباتك تصل منفصلة، ويرد عليك الإشعار من الإدارة',
                  style: TextStyle(color: AppColors.textGray, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold,
                      ),
                    )
                  : _bookings.isEmpty
                      ? const _EmptyNotifications()
                      : RefreshIndicator(
                          color: AppColors.primaryGold,
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _bookings.length,
                            itemBuilder: (context, index) => _BookingCard(
                              booking: _bookings[index],
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

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  (IconData, Color) get _status => switch (booking.status) {
        BookingStatus.approved => (
            Icons.check_circle,
            const Color(0xFF4CAF50),
          ),
        BookingStatus.rejected => (
            Icons.cancel,
            const Color(0xFFE57373),
          ),
        BookingStatus.completed => (
            Icons.verified,
            AppColors.primaryGold,
          ),
        BookingStatus.processing => (
            Icons.local_shipping_outlined,
            const Color(0xFF42A5F5),
          ),
        BookingStatus.pending => (
            Icons.schedule,
            AppColors.primaryGold,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _status;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.statusLabel,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (booking.services.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    booking.services.join('، '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _meta(Icons.event, booking.date),
                    _meta(Icons.location_on, booking.location),
                    if (booking.totalPrice > 0)
                      _meta(
                        Icons.attach_money,
                        'ريال ${_formatPrice(booking.totalPrice)}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 13),
          const SizedBox(width: 3),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textGray, fontSize: 11),
          ),
        ],
      );

  static String _formatPrice(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.notifications_off_outlined,
            color: AppColors.textGray,
            size: 56,
          ),
          SizedBox(height: 14),
          Text(
            'لا توجد طلبات بعد',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'عند تأكيد حجوزاتك من "سلاتك" ستظهر هنا',
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