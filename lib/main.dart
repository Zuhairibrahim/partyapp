// ============================================================================
//  © 2026 Zuhair Ibrahim — ALL RIGHTS RESERVED | جميع الحقوق محفوظة © زهير إبراهيم
//  Project: Party App — حفلة | حجز قاعات الأفراح والمناسبات
//  This code contains a proprietary embedded copyright fingerprint.
//  Selling, redistributing, or removing this notice is strictly forbidden.
//  ============================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_colors.dart';
import 'data/cart_store.dart';
import 'data/featured_store.dart';
import 'data/place_store.dart';
import 'screens/splash_screen.dart';
import 'core/ownership/ownership_guard.dart';

/// بصمة الملكية الفكرية — يُمنع حذفها أو تعديلها (انظر ملف LICENSE)
/// Proprietary ownership fingerprint — must NOT be removed or altered (see LICENSE).
const String kAppOwnershipFingerprint =
    'OWNER:Zuhair-Ibrahim|PROJECT:partyapp|YEAR:2026|'
    'LICENSE:ALL-RIGHTS-RESERVED|SIG:ZI-2026-PTY-PROPRIETARY';

Future<void> main() async {
  assert(ownershipSealsIntact(), 'Ownership seals must remain intact — see LICENSE');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  CartStore.instance.init();
  FeaturedStore.instance.init();
  PlaceStore.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حفلة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryGold,
          secondary: AppColors.lightGold,
          surface: AppColors.cardDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          foregroundColor: AppColors.textWhite,
        ),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}