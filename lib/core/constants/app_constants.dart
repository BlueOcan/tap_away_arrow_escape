class AppConstants {
  AppConstants._();

  static const int maxLives = 3;

  static const int loopDetectionMultiplier = 2;

  static const Duration arrowRotateDuration = Duration(milliseconds: 150);
  static const Duration ballMoveDuration = Duration(milliseconds: 120);
  static const Duration resultOverlayDelay = Duration(milliseconds: 300);

  static const double cellGapRatio = 0.18;
  static const double arrowStrokeWidth = 6.0;
}
