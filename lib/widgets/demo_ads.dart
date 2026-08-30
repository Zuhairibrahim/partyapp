import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'luxury_toast.dart';

/// Demo ad components for the customer app.
///
/// These are NOT third-party ads and do NOT use the AdMob SDK, so there is
/// nothing to warn about on the AdMob side and no Google-declared ad SDK to
/// review on the Play Console side. They are clearly-labeled in-app
/// "Sponsored" promotions whose links are dummy (tapping just shows an
/// in-app toast; nothing ever opens an external URL). Set [kDemoAdsEnabled]
/// to `false` to remove every demo ad instantly.
const bool kDemoAdsEnabled = true;

const List<String> _demoTitles = [
  'عرض خاص · خصم ١٥٪ على حجز القاعات هذا الأسبوع',
  'احجز قاعتك المفضلة الآن بأفضل الأسعار',
  'خدمة الضيافة متوفرة في جميع قاعاتنا',
];

/// A small banner-style promoted card placed between content sections. The
/// dummy link only opens an in-app toast.
class DemoAdsBanner extends StatefulWidget {
  const DemoAdsBanner({super.key});

  @override
  State<DemoAdsBanner> createState() => _DemoAdsBannerState();
}

class _DemoAdsBannerState extends State<DemoAdsBanner> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _demoTitles.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF221F14), Color(0xFF3A2F10)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.containerBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_offer_outlined,
                color: Color(0xFF141414), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(end: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Sponsored',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF141414)),
                      ),
                    ),
                    const Icon(Icons.spa, color: AppColors.lightGold, size: 12),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _demoTitles[_index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textWhite),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => showLuxuryToast(context, 'هذا إعلان تجريبي',
                title: 'إعلان', icon: Icons.local_offer_outlined),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGold, AppColors.lightGold],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'عرض',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF141414)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interstitial-style promoted overlay shown once per app session (plus a
/// cooldown), never during booking/cart flows. The dummy link only closes the
/// overlay or shows an in-app toast.
Future<bool> showDemoAdsInterstitial(BuildContext context,
    {bool onlyOncePerSession = true}) async {
  if (!kDemoAdsEnabled) return false;
  if (onlyOncePerSession && _DemoAdsGate.shownThisSession) return false;
  final last = _DemoAdsGate.lastShown;
  if (last != null &&
      DateTime.now().difference(last) < const Duration(minutes: 3)) {
    return false;
  }
  _DemoAdsGate.lastShown = DateTime.now();
  _DemoAdsGate.shownThisSession = true;
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, _, _) => const _DemoInterstitialBox(),
  );
  return true;
}

class _DemoAdsGate {
  static DateTime? lastShown;
  static bool shownThisSession = false;
}

class _DemoInterstitialBox extends StatefulWidget {
  const _DemoInterstitialBox();

  @override
  State<_DemoInterstitialBox> createState() => _DemoInterstitialBoxState();
}

class _DemoInterstitialBoxState extends State<_DemoInterstitialBox> {
  bool _closable = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _closable = true);
    });
    Timer(const Duration(seconds: 5), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1D26), Color(0xFF2A2410)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.primaryGold, width: 1.4),
            ),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Sponsored',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF141414)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_closable)
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close,
                              color: AppColors.textGray, size: 20),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.celebration_outlined,
                      color: Color(0xFF141414), size: 34),
                ),
                const SizedBox(height: 18),
                const Text(
                  'عروض حفلة',
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'خصومات حصرية على حجز القاعات وقاعات الضيافة، فقط عبر التطبيق.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textWhite),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    showLuxuryToast(context, 'هذا إعلان تجريبي',
                        title: 'إعلان', icon: Icons.local_offer_outlined);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryGold,
                          AppColors.lightGold,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text(
                        'متابعة',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF141414)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}