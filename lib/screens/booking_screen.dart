import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/place_item_model.dart';

class BookingScreen extends StatefulWidget {
  final PlaceItem? bookedItem;

  const BookingScreen({super.key, this.bookedItem});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const List<_Service> _services = [
    _Service(id: 'hall', title: 'القاعة', icon: Icons.home_work_outlined, price: 60000),
    _Service(id: 'photographer', title: 'المصور', icon: Icons.photo_camera_outlined, price: 30000),
    _Service(id: 'dj', title: 'الدي جي', icon: Icons.music_note_outlined, price: 25000),
    _Service(id: 'catering', title: 'البوفيه', icon: Icons.restaurant_outlined, price: 15000),
  ];

  final Set<String> _selected = {'hall'};

  int get _totalPrice {
    var total = 0;
    for (final service in _services) {
      if (_selected.contains(service.id)) {
        total += service.price;
      }
    }
    return total;
  }

  String _formatPrice(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
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
                          'تأكيد الحجز',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Selected item summary card
                    if (widget.bookedItem != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.bookedItem!.mainImage,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 64,
                                    height: 64,
                                    color: AppColors.primaryGold
                                        .withValues(alpha: 0.2),
                                    child: Icon(
                                      widget.bookedItem!.defaultIcon,
                                      color: AppColors.primaryGold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.bookedItem!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.bookedItem!.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.bookedItem!.price,
                                    style: const TextStyle(
                                      color: AppColors.primaryGold,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Calendar Card Mock
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'اختر التاريخ',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: const [
                              _DayCell(day: '28', enabled: false),
                              _DayCell(day: '27', enabled: false),
                              _DayCell(day: '26', enabled: false),
                              _SelectedDay(day: '10'),
                              _DayCell(day: '11', enabled: true),
                              _DayCell(day: '15', enabled: true),
                              _DayCell(day: '20', enabled: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Services Selection
                    const Text(
                      'اختر الخدمات',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (final service in _services)
                          _ServiceTile(
                            service: service,
                            isSelected: _selected.contains(service.id),
                            formattedPrice: _formatPrice(service.price),
                            onTap: () => _toggle(service.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Location Input Field
                    const Text(
                      'الموقع',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      style: const TextStyle(color: AppColors.textWhite),
                      decoration: InputDecoration(
                        hintText: 'أدخل الموقع هنا',
                        hintStyle: const TextStyle(
                          color: AppColors.textGray,
                        ),
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textGray,
                        ),
                        filled: true,
                        fillColor: AppColors.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Bottom Bar: Total Price & Confirmation Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ريال ${_formatPrice(_totalPrice)}',
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'السعر الكلي',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم تأكيد الحجز - الاجمالي: ريال ${_formatPrice(_totalPrice)}',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'تأكيد الحجز',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

class _Service {
  final String id;
  final String title;
  final IconData icon;
  final int price;

  const _Service({
    required this.id,
    required this.title,
    required this.icon,
    required this.price,
  });
}

class _ServiceTile extends StatelessWidget {
  final _Service service;
  final bool isSelected;
  final String formattedPrice;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.service,
    required this.isSelected,
    required this.formattedPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.containerBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              service.icon,
              color: isSelected
                  ? AppColors.primaryGold
                  : AppColors.textGray,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                service.title,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              'ريال $formattedPrice',
              style: TextStyle(
                color: isSelected
                    ? AppColors.primaryGold
                    : AppColors.textGray,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.primaryGold
                  : AppColors.textGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String day;
  final bool enabled;

  const _DayCell({required this.day, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: TextStyle(
        color: enabled ? AppColors.textWhite : AppColors.textGray,
      ),
    );
  }
}

class _SelectedDay extends StatelessWidget {
  final String day;

  const _SelectedDay({required this.day});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.primaryGold,
      child: Text(
        day,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}