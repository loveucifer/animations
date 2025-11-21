import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class DotMoonPhaseTracker extends StatefulWidget {
  const DotMoonPhaseTracker({super.key});

  @override
  State<DotMoonPhaseTracker> createState() => _DotMoonPhaseTrackerState();
}

class _DotMoonPhaseTrackerState extends State<DotMoonPhaseTracker> {
  List<List<int>> grid = List.generate(64, (_) => List.filled(64, 0));
  String phaseName = "Full Moon";
  Timer? _timer;
  int dayCount = 0;

  @override
  void initState() {
    super.initState();
    _updateMoonPhase();
    _startPhaseUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPhaseUpdates() {
    // Update the phase approximately every 30 seconds to simulate the lunar cycle
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        dayCount = (dayCount + 1) % 29; // 29 days for a lunar cycle
        _updateMoonPhase();
      });
    });
  }

  void _updateMoonPhase() {
    // Calculate the current moon phase based on the day in the lunar cycle
    double phase = dayCount / 29.0;
    phaseName = _getPhaseName(phase);
    _drawMoonPhase(phase);
  }

  String _getPhaseName(double phase) {
    // Determine the name of the moon phase based on the position in the cycle
    if (phase < 0.02 || phase > 0.98) return "New Moon";
    if (phase >= 0.23 && phase <= 0.27) return "First Quarter";
    if (phase >= 0.48 && phase <= 0.52) return "Full Moon";
    if (phase >= 0.73 && phase <= 0.77) return "Last Quarter";
    
    if (phase > 0.48 && phase < 0.52) return "Full Moon";
    if (phase > 0.02 && phase < 0.23) return "Waxing Crescent";
    if (phase > 0.23 && phase < 0.27) return "First Quarter";
    if (phase > 0.27 && phase < 0.48) return "Waxing Gibbous";
    if (phase > 0.52 && phase < 0.73) return "Waning Gibbous";
    if (phase > 0.73 && phase < 0.77) return "Last Quarter";
    if (phase > 0.77 && phase < 0.98) return "Waning Crescent";
    
    return "Unknown";
  }

  void _drawMoonPhase(double phase) {
    // Clear the grid
    grid = List.generate(64, (_) => List.filled(64, 0));
    
    // Center of the moon on the grid (32, 32) with radius 28
    int centerX = 32;
    int centerY = 32;
    int radius = 28;
    
    // Draw a circle for the moon
    for (int x = centerX - radius; x <= centerX + radius; x++) {
      for (int y = centerY - radius; y <= centerY + radius; y++) {
        if (x >= 0 && x < 64 && y >= 0 && y < 64) {
          double distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
          
          if (distance <= radius) {
            // Determine if this point should be lit based on the moon phase
            bool isLit = _isPointLit(x, y, centerX, centerY, radius, phase);
            grid[y][x] = isLit ? 1 : 0;
          }
        }
      }
    }
  }

  bool _isPointLit(int x, int y, int centerX, int centerY, int radius, double phase) {
    // Calculate the angle from the center
    double dx = (x - centerX).toDouble();
    double dy = (y - centerY).toDouble();
    double distance = sqrt(dx * dx + dy * dy);
    
    if (distance > radius) {
      return false;
    }
    
    // For different phases, calculate whether the point is on the lit side
    if (phase < 0.25) {
      // Waxing phases - right side is lit
      double phaseAngle = -phase * 2 * pi;
      double rotatedX = dx * cos(phaseAngle) - dy * sin(phaseAngle);
      return rotatedX >= 0;
    } else if (phase >= 0.25 && phase < 0.5) {
      // Waxing gibbous - mostly lit but left side dark
      double phaseAngle = -(phase - 0.25) * 2 * pi;
      double rotatedX = dx * cos(phaseAngle) - dy * sin(phaseAngle);
      return rotatedX >= -(radius * (0.5 - phase) * 4); // More dark as we approach full
    } else if (phase >= 0.5 && phase < 0.75) {
      // Waning gibbous - mostly lit but right side dark
      double phaseAngle = -(phase - 0.5) * 2 * pi;
      double rotatedX = dx * cos(phaseAngle) - dy * sin(phaseAngle);
      return rotatedX <= (radius * (phase - 0.5) * 4); // More dark as we approach new
    } else {
      // Waning phases - left side is lit
      double phaseAngle = -(phase - 0.75) * 2 * pi;
      double rotatedX = dx * cos(phaseAngle) - dy * sin(phaseAngle);
      return rotatedX <= 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dot Matrix Moon Phase'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Phase: $phaseName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = MediaQuery.of(context).size;
                    final dimension = size.width < size.height
                        ? size.width * 0.95
                        : size.height * 0.8;

                    return Container(
                      width: dimension,
                      height: dimension,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1a1a1a),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(128),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 64,
                              mainAxisSpacing: 1,
                              crossAxisSpacing: 1,
                            ),
                        itemCount: 64 * 64,
                        itemBuilder: (context, index) {
                          final row = index ~/ 64;
                          final col = index % 64;
                          final isActive = grid[row][col] == 1;

                          return Container(
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.yellow.shade300
                                  : const Color(0xFF2a2a2a),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}