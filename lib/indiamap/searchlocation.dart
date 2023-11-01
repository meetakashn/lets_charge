import 'dart:math';

class SearchLocation {
  static double calculateZoomLevel(double radiusInMeters) {
    // The following formula calculates the zoom level based on the radius.
    // You can adjust the values as needed for your map.
    double zoomLevel = 25 - log(radiusInMeters) / log(2);

    // Ensure the zoom level is within a reasonable range (e.g., between 1 and 20)
    return max(1, min(20, zoomLevel));
  }
}
