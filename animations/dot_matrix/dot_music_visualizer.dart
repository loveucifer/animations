import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class DotMusicVisualizer extends StatefulWidget {
  const DotMusicVisualizer({super.key});

  @override
  State<DotMusicVisualizer> createState() => _DotMusicVisualizerState();
}

class _DotMusicVisualizerState extends State<DotMusicVisualizer> {
  List<List<int>> grid = List.generate(64, (_) => List.filled(64, 0));
  Timer? _timer;
  int animationStep = 0;

  @override
  void initState() {
    super.initState();
    _startVisualizer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startVisualizer() {
    // Simulate music visualization with a timer
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        animationStep++;
        _updateGrid();
      });
    });
  }

  void _updateGrid() {
    // Clear the grid
    grid = List.generate(64, (_) => List.filled(64, 0));

    // Create a music visualization based on the current animation step
    final random = Random();
    
    // Draw a bar graph visualization on the bottom half of the grid
    for (int col = 0; col < 64; col++) {
      // Calculate bar height with some random variation to simulate music
      int baseHeight = 10 + (sin(animationStep * 0.1 + col * 0.2) * 5).abs().round();
      int variation = random.nextInt(3);
      int barHeight = baseHeight + variation;
      
      // Draw the bar from bottom to top
      for (int row = 63; row > 63 - barHeight; row--) {
        if (row >= 0) {
          grid[row][col] = 1;
        }
      }
    }

    // Add some peaks with more intensity
    for (int i = 0; i < 5; i++) {
      int peakCol = (animationStep * 2 + i * 12) % 64;
      int peakHeight = 20 + (sin(animationStep * 0.05 + i) * 10).abs().round();
      
      for (int row = 63; row > 63 - peakHeight; row--) {
        if (row >= 0 && peakCol < 64) {
          grid[row][peakCol] = 1;
        }
      }
    }

    // Add some particles that move up and down
    for (int i = 0; i < 8; i++) {
      int particleCol = (animationStep * 3 + i * 8) % 64;
      int particleRow = (32 + sin(animationStep * 0.2 + i) * 15).round();
      
      if (particleRow >= 0 && particleRow < 64 && particleCol < 64) {
        grid[particleRow][particleCol] = 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dot Matrix Music Visualizer'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Music Visualizer',
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

                          Color color = isActive 
                              ? Colors.purple.shade300 
                              : const Color(0xFF2a2a2a);

                          if (isActive) {
                            // Add some variation to active dots to simulate different intensities
                            int rowDiff = (row - 32).abs();
                            if (rowDiff < 5) {
                              color = Colors.blue.shade300;
                            } else if (rowDiff < 15) {
                              color = Colors.green.shade300;
                            }
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: color,
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