import 'package:flutter/material.dart';
import 'package:treasureflow/shared/widgets/map/treasure_map_widget.dart';

class Step3LocationData extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3LocationData({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TreasureMapWidget(
        onNext: onNext,
        onBack: onBack,
      ),
    );
  }
}