import 'package:flutter/material.dart';

class QrScanScreen extends StatelessWidget {
  const QrScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Escanear código',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              'Apunta al código del ciudadano',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    ..._corners(colors),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'El código vincula la venta con tu establecimiento.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: const Text('Simular escaneo (demo)'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _corners(ColorScheme colors) {
    Widget corner({required Alignment alignment}) {
      final isTop = alignment.y < 0;
      final isLeft = alignment.x < 0;
      return Align(
        alignment: alignment,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            border: Border(
              top: isTop
                  ? BorderSide(color: colors.primary, width: 4)
                  : BorderSide.none,
              bottom: !isTop
                  ? BorderSide(color: colors.primary, width: 4)
                  : BorderSide.none,
              left: isLeft
                  ? BorderSide(color: colors.primary, width: 4)
                  : BorderSide.none,
              right: !isLeft
                  ? BorderSide(color: colors.primary, width: 4)
                  : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return [
      corner(alignment: Alignment.topLeft),
      corner(alignment: Alignment.topRight),
      corner(alignment: Alignment.bottomLeft),
      corner(alignment: Alignment.bottomRight),
    ];
  }
}
