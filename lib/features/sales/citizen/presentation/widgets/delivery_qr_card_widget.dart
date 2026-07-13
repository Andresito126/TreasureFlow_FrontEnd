import 'package:flutter/material.dart';



class DeliveryQrCardWidget extends StatelessWidget {
  final String payload;

  const DeliveryQrCardWidget({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Código de entrega',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth.clamp(0.0, 220.0);
              return Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
                ),
                child: CustomPaint(
                  painter: _FakeQrPainter(seed: payload.hashCode),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class _FakeQrPainter extends CustomPainter {
  final int seed;

  _FakeQrPainter({required this.seed});

  static const _modules = 21;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1A1A1A);
    final cell = size.width / _modules;

    var state = seed;
    bool nextBit() {
      
      state = (state * 1103515245 + 12345) & 0x7fffffff;
      return (state >> 16) & 1 == 1;
    }

    for (int row = 0; row < _modules; row++) {
      for (int col = 0; col < _modules; col++) {
        final inFinder = _isFinderArea(row, col);
        if (inFinder) continue;
        if (nextBit()) {
          canvas.drawRect(
            Rect.fromLTWH(col * cell, row * cell, cell, cell),
            paint,
          );
        }
      }
    }

    _drawFinder(canvas, paint, cell, 0, 0);
    _drawFinder(canvas, paint, cell, _modules - 7, 0);
    _drawFinder(canvas, paint, cell, 0, _modules - 7);
  }

  bool _isFinderArea(int row, int col) {
    return (row < 8 && col < 8) ||
        (row < 8 && col >= _modules - 8) ||
        (row >= _modules - 8 && col < 8);
  }

  void _drawFinder(Canvas canvas, Paint paint, double cell, int col, int row) {
    canvas.drawRect(
      Rect.fromLTWH(col * cell, row * cell, cell * 7, cell * 7),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH((col + 1) * cell, (row + 1) * cell, cell * 5, cell * 5),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH((col + 2) * cell, (row + 2) * cell, cell * 3, cell * 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FakeQrPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
