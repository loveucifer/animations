import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRT Heart',
      theme: ThemeData.dark(),
      home: const CRTHeartScreen(),
    );
  }
}

class CRTHeartScreen extends StatelessWidget {
  const CRTHeartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: const CRTMonitor(),
            ),
          ),
        ),
      ),
    );
  }
}

class CRTMonitor extends StatelessWidget {
  const CRTMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 600 ? 600.0 : screenWidth - 40;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.fromLTRB(60, 50, 60, 70),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFc4c4c4), Color(0xFF8a8a8a), Color(0xFF5a5a5a)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(80),
        ),
        border: Border.all(color: const Color(0xFF707070), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(0, 30),
            blurRadius: 80,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const ScreenContainer(),
          Positioned(
            bottom: -40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'CRT-2000',
                style: TextStyle(
                  fontFamily: 'Courier',
                  color: const Color(0xFF555555),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(bottom: -35, right: -10, child: PowerLED()),
        ],
      ),
    );
  }
}

class PowerLED extends StatefulWidget {
  const PowerLED({super.key});

  @override
  State<PowerLED> createState() => _PowerLEDState();
}

class _PowerLEDState extends State<PowerLED>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF00FF00),
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.3, -0.3),
              colors: [Colors.white, Color(0xFF00FF00)],
              stops: [0.1, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF00FF00,
                ).withOpacity(_controller.value * 0.5 + 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ScreenContainer extends StatelessWidget {
  const ScreenContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1a1a1a), width: 4),
        boxShadow: [
          // Standard outer shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            // Inner shadow simulation for screen depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.1, 0.9, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: const ContentBox(),
            ),
            // Screen reflection/glare
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.white.withOpacity(0.08),
                      ],
                      stops: const [0.0, 0.4, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Vignette
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Scanlines
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: ScanLinePainter()),
              ),
            ),
            // Flicker
            const Positioned.fill(child: IgnorePointer(child: ScreenFlicker())),
          ],
        ),
      ),
    );
  }
}

class ContentBox extends StatelessWidget {
  const ContentBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background glow
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [
                  const Color(0xFFef4444).withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        // Main HUD Box
        Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 29, 24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(50),
            ),
            border: Border.all(color: const Color(0xFFef4444), width: 12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFef4444).withOpacity(0.6),
                blurRadius: 20,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Inner shadow simulation for HUD box
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(1),
                      topRight: Radius.circular(1),
                      bottomLeft: Radius.circular(1),
                      bottomRight: Radius.circular(40),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InteractiveHeartIcon(key: const ValueKey(1)),
                  InteractiveHeartIcon(key: const ValueKey(2)),
                  InteractiveHeartIcon(key: const ValueKey(3)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InteractiveHeartIcon extends StatefulWidget {
  const InteractiveHeartIcon({super.key});

  @override
  State<InteractiveHeartIcon> createState() => _InteractiveHeartIconState();
}

class _InteractiveHeartIconState extends State<InteractiveHeartIcon> {
  bool isBroken = false;
  bool isAnimating = false;
  Color tintColor = const Color(0xFFef4444);
  Offset offset = Offset.zero;

  final math.Random _random = math.Random();

  final List<Color> _colors = [
    const Color(0xFFef4444),
    const Color(0xFFfcd34d),
    const Color(0xFFbfdbfe),
  ];

  void _handleClick() {
    if (isAnimating) return;

    setState(() {
      isBroken = !isBroken;
    });

    if (isBroken) {
      _startBreakAnimation();
    } else {
      setState(() {
        tintColor = const Color(0xFFef4444);
        offset = Offset.zero;
      });
    }
  }

  void _startBreakAnimation() {
    setState(() {
      isAnimating = true;
    });

    int frame = 0;
    const totalFrames = 50;

    Timer.periodic(const Duration(milliseconds: 8), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (frame < totalFrames) {
        setState(() {
          tintColor = _colors[_random.nextInt(_colors.length)];
          offset = Offset(_random.nextDouble(), _random.nextDouble());
        });
        frame++;
      } else {
        timer.cancel();
        setState(() {
          tintColor = const Color(0xFF991b1b);
          offset = Offset.zero;
          isAnimating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double translateX = -5.0 + (offset.dx * 10.0);
    final double translateY = -5.0 + (offset.dy * 10.0);

    IconData iconData;
    double strokeWidth;
    bool isFilled;

    if (isBroken) {
      if (isAnimating) {
        iconData = Icons.heart_broken;
        isFilled = true;
        strokeWidth = 0;
      } else {
        iconData = Icons.favorite_border;
        isFilled = false;
        strokeWidth = 2.0;
      }
    } else {
      iconData = Icons.favorite;
      isFilled = true;
      strokeWidth = 0;
    }

    return GestureDetector(
      onTap: _handleClick,
      child: Transform.translate(
        offset: Offset(translateX, translateY),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: CustomPaint(
              size: const Size(64, 64),
              painter: HeartPainter(
                iconData: iconData,
                color: tintColor,
                strokeWidth: strokeWidth,
                isFilled: isFilled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeartPainter extends CustomPainter {
  final IconData iconData;
  final Color color;
  final double strokeWidth;
  final bool isFilled;

  HeartPainter({
    required this.iconData,
    required this.color,
    required this.strokeWidth,
    required this.isFilled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          fontSize: 64,
          color: isFilled ? color : null,
          foreground: isFilled
              ? null
              : (Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = color),
          shadows: [Shadow(blurRadius: 8, color: color)],
        ),
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant HeartPainter oldDelegate) {
    return oldDelegate.iconData != iconData ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.isFilled != isFilled;
  }
}

class ScanLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 2) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScreenFlicker extends StatefulWidget {
  const ScreenFlicker({super.key});

  @override
  State<ScreenFlicker> createState() => _ScreenFlickerState();
}

class _ScreenFlickerState extends State<ScreenFlicker> {
  double _opacity = 0.1;
  Timer? _timer;
  int _index = 0;

  final List<double> _flickerValues = [
    0.27,
    0.34,
    0.23,
    0.90,
    0.18,
    0.83,
    0.65,
    0.67,
    0.26,
    0.84,
    0.96,
    0.08,
    0.20,
    0.71,
    0.53,
    0.37,
    0.71,
    0.70,
    0.70,
    0.36,
    0.24,
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted) {
        setState(() {
          _opacity = _flickerValues[_index] * 0.1;
          _index = (_index + 1) % _flickerValues.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFF121010).withOpacity(_opacity));
  }
}
