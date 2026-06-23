import 'package:flutter/material.dart';

class CustomStepperWidget extends StatelessWidget {
  final int currentStep; 
  final List<String> stepLabels; 

  const CustomStepperWidget({
    super.key,
    required this.currentStep,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    final activeColor = colors.primary; 
    final inactiveColor = colors.outline.withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildSteps(theme, activeColor, inactiveColor),
      ),
    );
  }

  
  List<Widget> _buildSteps(ThemeData theme, Color activeColor, Color inactiveColor) {
    List<Widget> children = [];
    
    for (int i = 0; i < stepLabels.length; i++) {
      int stepNumber = i + 1; 
      bool isStepActive = currentStep >= stepNumber;

      
      children.add(
        _buildStepCircle(stepNumber, stepLabels[i], isStepActive, activeColor, inactiveColor, theme),
      );

      
      if (i < stepLabels.length - 1) {
        bool isLineActive = currentStep > stepNumber; 
        children.add(
          _buildLine(isLineActive, activeColor, inactiveColor),
        );
      }
    }
    
    return children;
  }

  Widget _buildStepCircle(int step, String label, bool isActive, Color activeColor, Color inactiveColor, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 8,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive, Color activeColor, Color inactiveColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 18.0),
        height: 2,
        color: isActive ? activeColor : inactiveColor,
      ),
    );
  }
}