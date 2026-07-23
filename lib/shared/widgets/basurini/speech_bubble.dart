import 'package:flutter/material.dart';
import 'basurini_types.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final BasuriniBubbleType type;
  final String? highlightText;
  final BubbleTailPosition tailPosition;

  const SpeechBubble({
    super.key,
    required this.text,
    this.type = BasuriniBubbleType.neutral,
    this.highlightText,
    this.tailPosition = BubbleTailPosition.bottomLeft, 
  });

  Color _getBackgroundColor(ColorScheme colors) {
    switch (type) {
      case BasuriniBubbleType.success: return colors.primary.withOpacity(0.1);
      case BasuriniBubbleType.error: return colors.error.withOpacity(0.1);
      case BasuriniBubbleType.warning: return Colors.orange.withOpacity(0.1);
      case BasuriniBubbleType.neutral: return colors.surface;
    }
  }

  Color _getTextColor(ColorScheme colors) {
    switch (type) {
      case BasuriniBubbleType.success: return colors.primary;
      case BasuriniBubbleType.error: return colors.error;
      case BasuriniBubbleType.warning: return Colors.orange;
      case BasuriniBubbleType.neutral: return colors.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = _getBackgroundColor(theme.colorScheme);
    final textColor = _getTextColor(theme.colorScheme);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: highlightText != null
              ? RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(color: textColor, fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(text: text.split(highlightText!)[0]),
                      TextSpan(
                        text: highlightText,
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: text.split(highlightText!)[1]),
                    ],
                  ),
                )
              : Text(
                  text,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: textColor, fontWeight: FontWeight.w600),
                ),
        ),

        
        Positioned(
          
          bottom: (tailPosition == BubbleTailPosition.bottomLeft || tailPosition == BubbleTailPosition.bottomRight) ? -6 : null,
          top: (tailPosition == BubbleTailPosition.topLeft || tailPosition == BubbleTailPosition.topRight) ? -6 : null,
          left: (tailPosition == BubbleTailPosition.bottomLeft || tailPosition == BubbleTailPosition.topLeft) ? 20 : null,
          right: (tailPosition == BubbleTailPosition.bottomRight || tailPosition == BubbleTailPosition.topRight) ? 20 : null,
          
          child: Transform.rotate(
            angle: 0.785398, 
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(2), 
              ),
            ),
          ),
        ),
      ],
    );
  }
}