import 'dart:async';

import 'package:flutter/material.dart';

const _darkBg = Color(0xFF070D19);
const _lightBg = Color(0xFFF5F5F5);

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _stage = 0;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _schedule(100, 1);
    _schedule(700, 2);
    _schedule(1300, 3);
    _timers.add(Timer(const Duration(milliseconds: 2600), widget.onFinished));
  }

  void _schedule(int ms, int stage) {
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (mounted) setState(() => _stage = stage);
      }),
    );
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _stage >= 1;
    final isLeft = _stage >= 2;
    final showText = _stage >= 3;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
        color: isDark ? _darkBg : _lightBg,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: _darkBg,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: showText
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: showText ? 1 : 0,
                          child: const Text(
                            'OFTGENIX',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(width: isLeft ? 140 : 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
