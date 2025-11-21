import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DotEyeAnimation extends StatefulWidget {
  const DotEyeAnimation({super.key});

  @override
  State<DotEyeAnimation> createState() => _DotEyeAnimationState();
}

class _DotEyeAnimationState extends State<DotEyeAnimation> {
  List<List<int>> grid = List.generate(64, (_) => List.filled(64, 0));
  Timer? _timer;
  int _pupilXOffset = 0;
  bool _isLookingRight = true;
  Color _scleraColor = Colors.white;
  Color _backgroundColor = const Color(0xFF2a2a2a);

  @override
  void initState() {
    super.initState();
    _drawEye();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _scleraColor,
              onColorChanged: (Color color) {
                setState(() {
                  _scleraColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showBackgroundColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a background color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _backgroundColor,
              onColorChanged: (Color color) {
                setState(() {
                  _backgroundColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        if (_isLookingRight) {
          if (_pupilXOffset < 2) {
            _pupilXOffset++;
          } else {
            _isLookingRight = false;
          }
        } else {
          if (_pupilXOffset > -2) {
            _pupilXOffset--;
          } else {
            _isLookingRight = true;
          }
        }
        _drawEye();
      });
    });
  }

  void _drawEye() {
    grid = List.generate(64, (_) => List.filled(64, 0));

    int eye1CenterX = 22;
    int eye2CenterX = 42;
    int eyeCenterY = 32;

    // Sclera (the white part of the eye)
    _drawOval(grid, eye1CenterX, eyeCenterY, 10, 14, 1);
    _drawOval(grid, eye2CenterX, eyeCenterY, 10, 14, 1);

    // Pupil (the black part of the eye)
    _drawOval(grid, eye1CenterX + _pupilXOffset, eyeCenterY, 6, 6, 2);
    _drawOval(grid, eye2CenterX + _pupilXOffset, eyeCenterY, 6, 6, 2);
  }

  void _drawOval(List<List<int>> grid, int centerX, int centerY, int radiusX, int radiusY, int value) {
    for (int y = 0; y < 64; y++) {
      for (int x = 0; x < 64; x++) {
        double dx = (x - centerX).toDouble();
        double dy = (y - centerY).toDouble();
        if ((dx * dx) / (radiusX * radiusX) + (dy * dy) / (radiusY * radiusY) <= 1) {
          grid[y][x] = value;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dot Matrix Eye Animation'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.width * 0.95,
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 64,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                ),
                itemCount: 64 * 64,
                itemBuilder: (context, index) {
                  final row = index ~/ 64;
                  final col = index % 64;
                  final cellValue = grid[row][col];
                  Color color;
                  switch (cellValue) {
                    case 1:
                      color = _scleraColor; // Sclera
                      break;
                    case 2:
                      color = Colors.black; // Pupil
                      break;
                    default:
                      color = _backgroundColor;
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showColorPicker,
              child: const Text('Change Eye Color'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showBackgroundColorPicker,
              child: const Text('Change Background Color'),
            ),
          ],
        ),
      ),
    );
  }
}
