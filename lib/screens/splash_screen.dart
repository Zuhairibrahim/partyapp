import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../data/customer_store.dart';
import 'home_screen.dart';
import 'registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _appName = 'حفلة';

  late final AnimationController _typingController;
  late final AnimationController _discoController;
  late final AnimationController _iconGlowController;
  late final AnimationController _dancersController;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          _goHome();
        }
      });
    _typingController.forward();

    _discoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _iconGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _dancersController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  Future<void> _goHome() async {
    // Mandatory registration: every customer logs in with their four-part name
    // and phone number before entering the app.
    final profile = await CustomerStore.instance.load();
    if (!mounted) return;
    final next = profile == null
        ? const RegistrationScreen()
        : const HomeScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => next),
    );
  }

  @override
  void dispose() {
    _typingController.dispose();
    _discoController.dispose();
    _iconGlowController.dispose();
    _dancersController.dispose();
    super.dispose();
  }

  int get _visibleLetters {
    final count = (_typingController.value * _appName.length).ceil();
    return count.clamp(0, _appName.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Ambient luxurious gradient
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1326),
                    AppColors.backgroundDark,
                  ],
                ),
              ),
            ),
          ),

          // Rotating laser beams sweeping the stage from the top
          AnimatedBuilder(
            animation: _discoController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _DiscoLightsPainter(_discoController.value),
                ),
              );
            },
          ),

          // Disco dance floor at the bottom
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 250,
            child: CustomPaint(
              painter: _DiscoFloorPainter(),
            ),
          ),

          // Dancing people silhouettes on the stage
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 210,
            child: AnimatedBuilder(
              animation: _dancersController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _DancersPainter(_dancersController.value),
                );
              },
            ),
          ),

          // Center: stage spotlight beam + app icon inside the beam
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 180,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Stage spotlight beam
                      Positioned(
                        top: 0,
                        width: 170,
                        height: 200,
                        child: CustomPaint(
                          painter: _SpotlightPainter(_discoController.value),
                        ),
                      ),
                      // Moving lights circling the icon
                      Positioned(
                        top: 44,
                        left: 0,
                        width: 150,
                        height: 150,
                        child: AnimatedBuilder(
                          animation: _iconGlowController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _OrbitLightsPainter(
                                _iconGlowController.value,
                              ),
                            );
                          },
                        ),
                      ),
                      // App icon (stage centerpiece inside the light beam)
                      Positioned(
                        top: 60,
                        left: 10,
                        child: AnimatedBuilder(
                          animation: _iconGlowController,
                          builder: (context, _) {
                            final glow = _iconGlowController.value;
                            final scale =
                                1.0 + 0.05 * math.sin(glow * 2 * math.pi);
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 130,
                                height: 130,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primaryGold,
                                      AppColors.lightGold,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryGold
                                          .withValues(alpha: 0.55),
                                      blurRadius:
                                          30 + 12 * math.sin(glow * 2 * math.pi),
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.celebration,
                                  color: Colors.black87,
                                  size: 62,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Typewriter effect: حفلة written letter by letter
                SizedBox(
                  height: 54,
                  child: AnimatedBuilder(
                    animation: _typingController,
                    builder: (context, _) {
                      final visible =
                          _appName.substring(0, _visibleLetters);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            visible,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  color: AppColors.primaryGold,
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Blinking caret
                          AnimatedBuilder(
                            animation: _discoController,
                            builder: (context, _) {
                              final on = _discoController.value < 0.5;
                              return AnimatedOpacity(
                                opacity: on ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 150),
                                child: Container(
                                  width: 3,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'مناسبتك تبدأ من هنا',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Bottom loading bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 34,
            child: AnimatedBuilder(
              animation: _typingController,
              builder: (context, _) {
                return Column(
                  children: [
                    const Text(
                      'جاري الدخول...',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 180,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _typingController.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGold
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Rotating laser light beams sweeping the stage, originating from the
/// top of the screen (ceiling-mounted disco lasers).
class _DiscoLightsPainter extends CustomPainter {
  final double progress;

  _DiscoLightsPainter(this.progress);

  static const _colors = [
    Color(0xFFD4AF37), // gold
    Color(0xFFE91E63), // pink
    Color(0xFF00BCD4), // cyan
    Color(0xFF9C27B0), // purple
    Color(0xFF3F51B5), // indigo
    Color(0xFFFFEB3B), // yellow
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Lasers hang from the top edge of the screen.
    final origin = Offset(size.width / 2, -10);
    final radius = size.height * 1.1;
    const beamCount = 14;
    const beamWidth = 0.10;
    final rotation = progress * 2 * math.pi;

    for (var i = 0; i < beamCount; i++) {
      final base = (i / beamCount) * 2 * math.pi + rotation;
      final color = _colors[i % _colors.length];

      // Bright core of the laser beam.
      final corePaint = Paint()
        ..color = color.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final mid1 = Offset(
        origin.dx + radius * math.cos(base - beamWidth),
        origin.dy + radius * math.sin(base - beamWidth),
      );
      final mid2 = Offset(
        origin.dx + radius * math.cos(base + beamWidth),
        origin.dy + radius * math.sin(base + beamWidth),
      );
      final tip = Offset(
        origin.dx + (radius * 1.15) * math.cos(base),
        origin.dy + (radius * 1.15) * math.sin(base),
      );

      final beam = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(mid1.dx, mid1.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(mid2.dx, mid2.dy)
        ..close();

      canvas.drawPath(beam, corePaint);

      // Thin intense laser line through the center of the beam.
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawLine(
        origin,
        Offset(
          origin.dx + (radius * 1.12) * math.cos(base),
          origin.dy + (radius * 1.12) * math.sin(base),
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DiscoLightsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Perspective disco dance floor tiles at the bottom of the stage.
class _DiscoFloorPainter extends CustomPainter {
  const _DiscoFloorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [0xFFD4AF37, 0xFF9C27B0, 0xFFE91E63, 0xFF00BCD4];
    final rect = Offset.zero & size;

    final floorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Color(0xFF120C1E)],
      ).createShader(rect);
    canvas.drawRect(rect, floorPaint);

    // Horizontal perspective lines radiating from a vanishing point.
    final vp = Offset(size.width / 2, 0);
    for (var i = 1; i <= 6; i++) {
      final t = i / 6.0;
      final y = size.height * 0.18 + t * t * size.height * 0.82;
      final spread = t * size.width * 0.9;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      final path = Path()
        ..moveTo(vp.dx - spread, y)
        ..quadraticBezierTo(vp.dx, y + 6, vp.dx + spread, y);
      canvas.drawPath(path, paint);
    }

    // Radial perspective tiles.
    for (var i = 0; i < 8; i++) {
      final angle1 = -math.pi / 2 + (i / 8.0) * math.pi / 2;
      final angle2 = -math.pi / 2 + ((i + 0.4) / 8.0) * math.pi / 2;
      final color =
          Color(colors[i % colors.length]).withValues(alpha: 0.10);
      final paint = Paint()..color = color;
      final path = Path()
        ..moveTo(vp.dx, vp.dy)
        ..lineTo(
          vp.dx + size.width * math.cos(angle1),
          vp.dy + size.height * math.sin(angle1).abs(),
        )
        ..lineTo(
          vp.dx + size.width * math.cos(angle2),
          vp.dy + size.height * math.sin(angle2).abs(),
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DiscoFloorPainter oldDelegate) => false;
}

/// The central stage spotlight cone where the icon sits.
class _SpotlightPainter extends CustomPainter {
  final double progress;

  _SpotlightPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final top = Offset(size.width / 2, 0);
    final bottomWidth = size.width * 0.44;

    final intensity =
        0.16 + 0.05 * math.sin(progress * 2 * math.pi);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: intensity * 1.6),
          Colors.white.withValues(alpha: intensity),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(size.width / 2 - bottomWidth, size.height)
      ..lineTo(size.width / 2 + bottomWidth, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Small colored lights orbiting around the app icon.
class _OrbitLightsPainter extends CustomPainter {
  final double progress;

  _OrbitLightsPainter(this.progress);

  static const _colors = [
    Color(0xFFD4AF37),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFFFFEB3B),
    Color(0xFF3F51B5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.46;
    final rotation = progress * 2 * math.pi;

    for (var i = 0; i < _colors.length; i++) {
      final angle = (i / _colors.length) * 2 * math.pi + rotation;
      final pos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final color = _colors[i];
      canvas.drawCircle(
        pos,
        5 + 2 * math.sin(rotation + i),
        Paint()
          ..color = color.withValues(alpha: 0.95)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitLightsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Silhouettes of dancing people on the stage floor.
class _DancersPainter extends CustomPainter {
  final double progress;

  _DancersPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55);

    // Group of dancers across the stage.
    final baseY = size.height * 0.98;
    const dancerDefs = [
      (0.12, 0.66),
      (0.30, 0.80),
      (0.48, 0.92),
      (0.68, 0.76),
      (0.86, 0.70),
    ];

    for (final (xf, h) in dancerDefs) {
      final x = size.width * xf;
      final hgt = size.height * h;
      final sway = math.sin(progress * 2 * math.pi + x * 2.5) * 5;
      _drawDancer(canvas, Offset(x, baseY), hgt, sway, paint);
    }
  }

  void _drawDancer(
    Canvas canvas,
    Offset feet,
    double height,
    double sway,
    Paint paint,
  ) {
    final headR = height * 0.11;
    final shoulderY = feet.dy - height * 0.82;

    // Torso leaning with the sway.
    final torsoTop = Offset(feet.dx + sway, shoulderY);

    final torsoPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = height * 0.14
      ..strokeCap = StrokeCap.round;

    // Head
    canvas.drawCircle(
      Offset(feet.dx + sway, shoulderY - headR),
      headR,
      paint,
    );

    // Torso: a curved stroke from shoulders to hips.
    final hipsY = feet.dy - height * 0.42;
    final hipsX = feet.dx + sway;
    final torso = Path()
      ..moveTo(torsoTop.dx, torsoTop.dy)
      ..quadraticBezierTo(
        (torsoTop.dx + hipsX) / 2,
        (torsoTop.dy + hipsY) / 2,
        hipsX,
        hipsY,
      );
    canvas.drawPath(torso, torsoPaint);

    // Arms raised (dancing).
    final armL =
        Offset(torsoTop.dx - height * 0.28, shoulderY - height * 0.18);
    final armR =
        Offset(torsoTop.dx + height * 0.28, shoulderY - height * 0.18);
    final armPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = height * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(torsoTop.dx, shoulderY),
      armL,
      armPaint,
    );
    canvas.drawLine(
      Offset(torsoTop.dx, shoulderY),
      armR,
      armPaint,
    );

    // Legs.
    final legPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = height * 0.09
      ..strokeCap = StrokeCap.round;
    final legSway = sway * 0.6;
    canvas.drawLine(
      Offset(hipsX, hipsY),
      Offset(feet.dx - legSway, feet.dy),
      legPaint,
    );
    canvas.drawLine(
      Offset(hipsX, hipsY),
      Offset(feet.dx + legSway, feet.dy),
      legPaint,
    );
  }

  @override
  bool shouldRepaint(_DancersPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
