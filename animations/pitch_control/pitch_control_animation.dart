import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Add error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pitch Control 3D',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22C55E), // Green-500
          secondary: Color(0xFF4ADE80), // Green-400
        ),
      ),
      home: const PitchControlScreen(),
    );
  }
}

class PitchControlScreen extends StatefulWidget {
  const PitchControlScreen({super.key});

  @override
  State<PitchControlScreen> createState() => _PitchControlScreenState();
}

class _PitchControlScreenState extends State<PitchControlScreen>
    with SingleTickerProviderStateMixin {
  // --- Configuration Constants ---
  static const double MIN_VALUE = -100.0;
  static const double MAX_VALUE = 100.0;

  // State
  double _pitch = 0.0;
  double _lastIntegerValue = 0.0;

  // Physics State
  double _velocity = 0.0;
  bool _isDragging = false;
  late Ticker _ticker;

  // Constants for easy tuning
  final double _friction = 0.96;
  final double _sensitivity = 0.25;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _hasVibration = false;

  @override
  void initState() {
    super.initState();
    // Create a ticker for the physics loop (runs every frame)
    _ticker = createTicker(_onTick)..start();
    _checkVibration();
    _lastIntegerValue = _pitch.round().toDouble();
  }

  Future<void> _checkVibration() async {
    _hasVibration = await Vibration.hasVibrator() ?? false;
  }

  void _triggerFeedback() {
    // Haptic feedback
    if (_hasVibration) {
      Vibration.vibrate(duration: 10, amplitude: 50);
    } else {
      HapticFeedback.lightImpact();
    }

    // Sound effect - generate a subtle tick programmatically
    _playTickSound();
  }

  void _playTickSound() async {
    // Play a short beep/tick sound
    // Since we don't have an audio file, we'll use system sound
    HapticFeedback.selectionClick();
  }

  void _checkValueChange(double newPitch) {
    double newIntegerValue = newPitch.round().toDouble();
    if (newIntegerValue != _lastIntegerValue) {
      _lastIntegerValue = newIntegerValue;
      _triggerFeedback();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    // Apply inertia if not dragging and velocity is significant
    if (!_isDragging && _velocity.abs() > 0.005) {
      setState(() {
        double oldPitch = _pitch;
        _pitch -= _velocity;
        _velocity *= _friction;

        // Clamp
        if (_pitch < MIN_VALUE) {
          _pitch = MIN_VALUE;
          _velocity = 0;
        } else if (_pitch > MAX_VALUE) {
          _pitch = MAX_VALUE;
          _velocity = 0;
        }

        _checkValueChange(_pitch);
      });
    } else if (!_isDragging && _velocity.abs() <= 0.005 && _velocity != 0) {
      _velocity = 0; // Stop completely
    }
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _velocity = 0;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Delta is positive when moving right, negative left.
      // We subtract to drag "surface" naturally.
      double delta = details.delta.dx;
      _pitch -= delta * _sensitivity;
      _velocity = delta * _sensitivity; // Store velocity for inertia

      _checkValueChange(_pitch);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  void _increment() {
    setState(() {
      _pitch = math.min(MAX_VALUE, _pitch + 1);
      _velocity = 0;
      _checkValueChange(_pitch);
    });
  }

  void _decrement() {
    setState(() {
      _pitch = math.max(MIN_VALUE, _pitch - 1);
      _velocity = 0;
      _checkValueChange(_pitch);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Left/Right Gradient Masks
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.transparent, Colors.black],
                    stops: [0.0, 0.2, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Value Display
                _buildValueDisplay(),

                const SizedBox(height: 20),

                // Canvas & Gesture Area
                GestureDetector(
                  onHorizontalDragStart: _onDragStart,
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: PitchDialPainter(
                        pitch: _pitch,
                        primaryColor: const Color(0xFF22C55E),
                        secondaryColor: const Color(0xFF334155),
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),

                // Bottom Controls
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay() {
    return Column(
      children: [
        RollingNumberDisplay(value: _pitch),
        const SizedBox(height: 10),
        // Triangle Pointer
        CustomPaint(
          size: const Size(20, 12),
          painter: TrianglePainter(color: const Color(0xFF22C55E)),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white54),
            onPressed: _decrement,
            iconSize: 32,
          ),
          const Text(
            "PITCH",
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              fontSize: 12,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white54),
            onPressed: _increment,
            iconSize: 32,
          ),
        ],
      ),
    );
  }
}

// --- Rolling Number Display Widget ---

class RollingNumberDisplay extends StatelessWidget {
  final double value;

  const RollingNumberDisplay({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    String valueStr = value.toStringAsFixed(1);
    bool isNegative = value < 0;
    String absValueStr = value.abs().toStringAsFixed(1);

    List<String> chars = absValueStr.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sign with proper spacing
        SizedBox(
          width: 45,
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                isNegative ? '-' : (value > 0 ? '+' : ''),
                key: ValueKey(isNegative ? 'neg' : value > 0 ? 'pos' : 'zero'),
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                  shadows: [Shadow(color: Color(0xFF22C55E), blurRadius: 10)],
                ),
              ),
            ),
          ),
        ),
        // Digits with rolling animation
        ...chars.asMap().entries.map((entry) {
          return RollingDigit(
            char: entry.value,
            key: ValueKey('digit_${entry.key}'),
          );
        }),
      ],
    );
  }
}

class RollingDigit extends StatefulWidget {
  final String char;

  const RollingDigit({super.key, required this.char});

  @override
  State<RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<RollingDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _previousChar = '';

  @override
  void initState() {
    super.initState();
    _previousChar = widget.char;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(RollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.char != widget.char) {
      _previousChar = oldWidget.char;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.char == '.' ? 20 : 40,
      height: 80,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Calculate the offset for rolling effect
            double offset = _animation.value;

            // Determine direction (up or down)
            int prevDigit = int.tryParse(_previousChar) ?? 0;
            int currentDigit = int.tryParse(widget.char) ?? 0;
            bool rollingUp = currentDigit > prevDigit;

            if (widget.char == '.' || _previousChar == '.') {
              // No animation for decimal point
              return Center(
                child: Text(
                  widget.char,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                    shadows: [Shadow(color: Color(0xFF22C55E), blurRadius: 10)],
                  ),
                ),
              );
            }

            // Blur amount based on speed (more blur in the middle of transition)
            double blurAmount = (offset < 0.5 ? offset : 1 - offset) * 6.0;

            return Stack(
              children: [
                // Previous number (fading out and moving)
                if (_controller.isAnimating)
                  Transform.translate(
                    offset: Offset(0, rollingUp ? -80 * offset : 80 * offset),
                    child: Opacity(
                      opacity: 1 - offset,
                      child: ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: blurAmount,
                          sigmaY: blurAmount * 1.5,
                          tileMode: TileMode.decal,
                        ),
                        child: Center(
                          child: Text(
                            _previousChar,
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFeatures: [FontFeature.tabularFigures()],
                              shadows: [
                                Shadow(color: Color(0xFF22C55E), blurRadius: 10)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Current number (fading in and moving into place)
                Transform.translate(
                  offset: Offset(
                      0, rollingUp ? 80 * (1 - offset) : -80 * (1 - offset)),
                  child: Opacity(
                    opacity: offset,
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: blurAmount,
                        sigmaY: blurAmount * 1.5,
                        tileMode: TileMode.decal,
                      ),
                      child: Center(
                        child: Text(
                          widget.char,
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()],
                            shadows: [
                              Shadow(color: Color(0xFF22C55E), blurRadius: 10)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --- Custom Painter for the 3D Drum ---

class PitchDialPainter extends CustomPainter {
  final double pitch;
  final Color primaryColor;
  final Color secondaryColor;

  PitchDialPainter({
    required this.pitch,
    required this.primaryColor,
    required this.secondaryColor,
  });

  // Configuration (Must match React logic for same effect)
  static const double DRUM_RADIUS = 600.0;
  static const double VIEW_ANGLE = 55.0;
  static const double TILT_ANGLE_DEG = 22.0;
  static const double TICK_SPACING_DEG = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 60; // Push down for curve

    final visibleRange = VIEW_ANGLE / TICK_SPACING_DEG;
    final startIdx = (pitch - visibleRange).floor();
    final endIdx = (pitch + visibleRange).ceil();

    final Paint linePaint = Paint()..strokeCap = StrokeCap.round;
    final Paint dotPaint = Paint()..style = PaintingStyle.fill;

    // Track line Paint
    final Paint trackPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    // Removed MaskFilter.blur

    // Pre-calculate tilt tangent
    final tiltTan = math.tan(TILT_ANGLE_DEG * math.pi / 180);

    // Loop through visible ticks
    for (int i = startIdx; i <= endIdx; i++) {
      final angleDeg = (i - pitch) * TICK_SPACING_DEG;
      final angleRad = angleDeg * math.pi / 180;

      // 3D Projection Math
      final x3d = DRUM_RADIUS * math.sin(angleRad);
      final z3d = DRUM_RADIUS * math.cos(angleRad);

      final x = cx + x3d;

      // Curve Logic: y = y_base - (radius - z) * tan(tilt)
      final yCurve = (DRUM_RADIUS - z3d) * tiltTan;
      final y = cy - 100 - yCurve;

      // Opacity calculation
      double alpha = 1.0 - (angleDeg.abs() / (VIEW_ANGLE * 0.85));
      alpha = alpha.clamp(0.0, 1.0);

      if (alpha <= 0) continue;

      // Active state logic
      bool isActive = false;
      if (pitch > 0) {
        isActive = i >= 0 && i <= pitch;
      } else {
        isActive = i <= 0 && i >= pitch;
      }
      bool isZero = (i == 0);

      // 1. Draw Tick
      bool isMajor = (i % 10 == 0);
      double tickHeight = isMajor ? 24.0 : 12.0;

      linePaint.color = (isActive || isZero)
          ? primaryColor.withOpacity(alpha)
          : secondaryColor.withOpacity(alpha);
      linePaint.strokeWidth = isMajor ? 3.0 : 1.5;

      // Removed the MaskFilter logic here to prevent blur
      linePaint.maskFilter = null;

      canvas.drawLine(Offset(x, y), Offset(x, y - tickHeight), linePaint);

      // 2. Draw Dots (Dot Matrix)
      if (i % 1 == 0) {
        int dotRows = 6;
        double dotSpacing = 9.0;
        double dotStartY = y + 18.0;

        dotPaint.color = (isActive)
            ? primaryColor.withOpacity(alpha)
            : secondaryColor.withOpacity(alpha);

        for (int row = 0; row < dotRows; row++) {
          double dotY = dotStartY + row * dotSpacing;
          double dotSize = 1.5 * (1 - angleDeg.abs() / 180);
          if (dotSize < 0.5) dotSize = 0.5;

          canvas.drawCircle(Offset(x, dotY), dotSize, dotPaint);
        }
      }
    }

    // Optional: Draw Active Track Line
    if (pitch.abs() > 0.5) {
      Path trackPath = Path();
      bool pathStarted = false;

      double startTrack = math.max(math.min(0, pitch), startIdx.toDouble());
      double endTrack = math.min(math.max(0, pitch), endIdx.toDouble());

      if (startTrack > endTrack) {
        final temp = startTrack;
        startTrack = endTrack;
        endTrack = temp;
      }

      for (double j = startTrack; j <= endTrack; j += 0.5) {
        final aDeg = (j - pitch) * TICK_SPACING_DEG;
        if (aDeg.abs() > VIEW_ANGLE) continue;

        final aRad = aDeg * math.pi / 180;
        final x3 = DRUM_RADIUS * math.sin(aRad);
        final z3 = DRUM_RADIUS * math.cos(aRad);
        final yc = (DRUM_RADIUS - z3) * tiltTan;

        final px = cx + x3;
        final py = cy - 100 - yc;

        if (!pathStarted) {
          trackPath.moveTo(px, py);
          pathStarted = true;
        } else {
          trackPath.lineTo(px, py);
        }
      }
      if (pathStarted) {
        canvas.drawPath(trackPath, trackPaint);
      }
    }
  }

  @override
  bool shouldRepaint(PitchDialPainter oldDelegate) {
    return oldDelegate.pitch != pitch;
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    // Removed MaskFilter.blur

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
