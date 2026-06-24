enum BasuriniMood {
  welcome,
  happy,
  thinking,
  error,
  sad,
  celebrating,
  idle,
  working
}

enum BasuriniBubbleType {
  neutral,
  success,
  error,
  warning
}
enum BubbleTailPosition {
  bottomLeft,
  bottomRight,
  topLeft,
  topRight
}

extension BasuriniMoodExtension on BasuriniMood {
  String get assetPath {
    switch (this) {
      case BasuriniMood.welcome: return 'assets/svg/basurini_welcome.svg';
      case BasuriniMood.error: return 'assets/svg/basurini_error.svg';
      default: return 'assets/svg/basurini_idle.svg';
    }
  }
}