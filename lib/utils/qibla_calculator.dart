// lib/utils/qibla_calculator.dart
import 'dart:math';

class QiblaCalculator {
  // Coordinates of Kaaba in Mecca
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculate Qibla direction from current location
  static double calculateQiblaDirection(double lat, double lng) {
    // Convert to radians
    final double lat1 = _degreesToRadians(lat);
    final double lng1 = _degreesToRadians(lng);
    final double lat2 = _degreesToRadians(kaabaLatitude);
    final double lng2 = _degreesToRadians(kaabaLongitude);

    final double dLng = lng2 - lng1;

    final double y = sin(dLng);
    final double x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLng);

    // Calculate angle
    double qibla = atan2(y, x);
    qibla = _radiansToDegrees(qibla);

    // Normalize to 0-360
    qibla = (qibla + 360) % 360;

    return qibla;
  }

  /// Get cardinal direction (N, NE, E, SE, S, SW, W, NW)
  static String getCardinalDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  static double _degreesToRadians(double degrees) => degrees * pi / 180;
  static double _radiansToDegrees(double radians) => radians * 180 / pi;
}
