import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luxury Knob Control',
      theme: ThemeData(primarySwatch: Colors.grey, fontFamily: 'monospace'),
      home: const LuxuryKnobScreen(),
    );
  }
}

class LuxuryKnobScreen extends StatefulWidget {
  const LuxuryKnobScreen({Key? key}) : super(key: key);

  @override
  State<LuxuryKnobScreen> createState() => _LuxuryKnobScreenState();
}

class _LuxuryKnobScreenState extends State<LuxuryKnobScreen>
    with SingleTickerProviderStateMixin {
  double intensity = 0.0; // 0 to 100
  double scrollOffset = 0.0;
  double velocity = 0.0;
  Timer? velocityTimer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 100),
        )..addListener(() {
          setState(() {});
        });
    _animationController.forward();
  }

  @override
  void dispose() {
    velocityTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _handleScroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    final delta = event.scrollDelta.dy;

    // LOCKING LOGIC
    if (intensity >= 100 && delta < 0) return;
    if (intensity <= 0 && delta > 0) return;

    setState(() {
      final change = -delta / 3;
      intensity = (intensity + change).clamp(0.0, 100.0);
      scrollOffset += delta;
      velocity = delta;
    });

    velocityTimer?.cancel();
    velocityTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          velocity = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final intensityFloat = intensity / 100;
    const accentColor = Color.fromRGBO(200, 0, 30, 1);
    final texturePosition = -(scrollOffset * 0.4) % 24;
    final rayDensity = 3.5 - (intensityFloat * 2.0);
    final lineWidth = 0.4 + (intensityFloat * 0.8);
    final alphaBase = 0.3 + (intensityFloat * 0.4);
    final alphaHigh = 0.7 + (intensityFloat * 0.3);
    final driveRotation = scrollOffset * 0.15;
    final blurAmount = math.min(4.0, velocity.abs() * 0.05);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F3),
      body: Center(
        child: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              _handleScroll(event);
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeUpDown,
            child: Container(
              width: 700,
              height: 700,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // BACKGROUND LIGHTS
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    opacity: intensity > 0.5 ? (0.1 + intensityFloat * 0.9) : 0,
                    child: Transform.scale(
                      scale: 1 + math.min(0.05, velocity.abs() * 0.0005),
                      child: SizedBox(
                        width: 700,
                        height: 700,
                        child: Stack(
                          children: [
                            // Mask Layer
                            Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.center,
                                  radius: 0.5,
                                  colors: [
                                    const Color(0xFFF0F0F3).withOpacity(0),
                                    const Color(0xFFF0F0F3).withOpacity(0),
                                    const Color(0xFFF0F0F3),
                                    const Color(0xFFF0F0F3),
                                  ],
                                  stops: const [0.0, 0.3, 0.7, 1.0],
                                ),
                              ),
                            ),
                            // Layer A - Conic Gradient Effect
                            Positioned.fill(
                              child: Transform.rotate(
                                angle: driveRotation * math.pi / 180,
                                child: CustomPaint(
                                  painter: ConicGradientPainter(
                                    accentColor: accentColor,
                                    rayDensity: rayDensity,
                                    lineWidth: lineWidth,
                                    alphaBase: alphaBase,
                                    alphaHigh: alphaHigh,
                                    rotation: 0,
                                    blurAmount: 0.5 + blurAmount,
                                  ),
                                ),
                              ),
                            ),
                            // Layer B
                            Positioned.fill(
                              child: Transform.rotate(
                                angle: -driveRotation * 0.5 * math.pi / 180,
                                child: CustomPaint(
                                  painter: ConicGradientPainter(
                                    accentColor: accentColor,
                                    rayDensity: rayDensity * 1.2,
                                    lineWidth: lineWidth * 0.8,
                                    alphaBase: alphaBase * 0.8,
                                    alphaHigh: alphaHigh * 0.8,
                                    rotation: 45,
                                    blurAmount: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // SHADOW BASE
                  Positioned(
                    bottom: 250,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[400]!.withOpacity(0.4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[400]!.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      transform: Matrix4.identity()
                        ..translate(0.0, 40.0)
                        ..scale(1.0, 0.75),
                    ),
                  ),

                  // THE LUXURY KNOB
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      children: [
                        // Sphere Body
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              center: Alignment(-0.4, -0.4),
                              radius: 1.2,
                              colors: [
                                Color(0xFF4A4A4A),
                                Color(0xFF1A1A1A),
                                Color(0xFF000000),
                              ],
                              stops: [0.0, 0.4, 0.85],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 50,
                                offset: const Offset(0, 20),
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Top Highlight
                              Positioned(
                                top: -96,
                                left: -48,
                                child: Container(
                                  width: 336,
                                  height: 192,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Specular Highlight
                              Positioned(
                                top: 36,
                                left: 60,
                                child: Container(
                                  width: 48,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.4),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Groove
                              Center(
                                child: CustomPaint(
                                  size: const Size(68, 240),
                                  painter: GroovePainter(
                                    texturePosition: texturePosition,
                                  ),
                                ),
                              ),
                              // Red Reflection
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 100),
                                opacity: intensityFloat * 0.8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      center: const Alignment(0, 0.6),
                                      radius: 0.8,
                                      colors: [
                                        accentColor.withOpacity(0.8),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Gloss Overlay
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        // Value Bezel (Progress Ring)
                        Transform.rotate(
                          angle: -math.pi / 2,
                          child: CustomPaint(
                            size: const Size(280, 280),
                            painter: ProgressRingPainter(
                              progress: intensityFloat,
                              accentColor: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Percentage Indicator
                  Positioned(
                    top: 470,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      transform: Matrix4.identity()
                        ..translate(0.0, intensity > 0 ? 0.0 : -10.0)
                        ..scale(1 + intensityFloat * 0.1),
                      child: Text(
                        '${intensity.round()}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 9.6,
                          color: intensity > 0
                              ? const Color(0xFF333333)
                              : const Color(0xFFCCCCCC),
                          shadows: intensity > 0
                              ? [
                                  Shadow(
                                    color: const Color(
                                      0xFFB40000,
                                    ).withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        children: [
                          TextSpan(
                            text: ' %',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  (intensity > 0
                                          ? const Color(0xFF333333)
                                          : const Color(0xFFCCCCCC))
                                      .withOpacity(0.5),
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
        ),
      ),
    );
  }
}

// Custom Painter for Conic Gradient Effect
class ConicGradientPainter extends CustomPainter {
  final Color accentColor;
  final double rayDensity;
  final double lineWidth;
  final double alphaBase;
  final double alphaHigh;
  final double rotation;
  final double blurAmount;

  ConicGradientPainter({
    required this.accentColor,
    required this.rayDensity,
    required this.lineWidth,
    required this.alphaBase,
    required this.alphaHigh,
    required this.rotation,
    required this.blurAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw rays
    final totalDegrees = 360.0;
    final stepDegrees = rayDensity + lineWidth + 0.2;
    final numRays = (totalDegrees / stepDegrees).ceil();

    for (int i = 0; i < numRays; i++) {
      final startAngle = (i * stepDegrees + rotation) * math.pi / 180;
      final sweepAngle = lineWidth * math.pi / 180;

      final gradient = SweepGradient(
        colors: [
          accentColor.withOpacity(alphaBase),
          accentColor.withOpacity(alphaHigh),
          accentColor.withOpacity(alphaBase),
        ],
        stops: const [0.0, 0.5, 1.0],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      );

      paint.shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      );
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConicGradientPainter oldDelegate) {
    return oldDelegate.rayDensity != rayDensity ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.alphaBase != alphaBase ||
        oldDelegate.alphaHigh != alphaHigh ||
        oldDelegate.rotation != rotation;
  }
}

// Custom Painter for Groove
class GroovePainter extends CustomPainter {
  final double texturePosition;

  GroovePainter({required this.texturePosition});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Background
    final bgPaint = Paint()..color = const Color(0xFF080808);
    canvas.drawRect(rect, bgPaint);

    // Side borders
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF5A5A5A), Color(0xFFFFFFFF), Color(0xFF5A5A5A)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawLine(
      Offset(0, 0),
      Offset(0, size.height),
      borderPaint..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height),
      borderPaint..strokeWidth = 1,
    );

    // Texture lines with mask
    canvas.save();
    final maskPath = Path()
      ..addRect(
        Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.4),
      );
    canvas.clipPath(maskPath);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1;

    double y = texturePosition;
    while (y < size.height * 2) {
      if (y >= 0 && y < size.height) {
        canvas.drawLine(
          Offset(0, y + 23),
          Offset(size.width, y + 23),
          linePaint,
        );
      }
      y += 24;
    }

    canvas.restore();

    // Inner shadow
    final shadowPaint = Paint()
      ..color = Colors.black
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawRect(rect, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant GroovePainter oldDelegate) {
    return oldDelegate.texturePosition != texturePosition;
  }
}

// Custom Painter for Progress Ring
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  ProgressRingPainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 130.0;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFE5E5E5).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress circle
    final progressPaint = Paint()
      ..color = accentColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
