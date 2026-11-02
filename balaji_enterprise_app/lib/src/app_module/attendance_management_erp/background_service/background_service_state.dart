import 'package:shared_preferences/shared_preferences.dart';

class BackgroundServiceState {
  static const String _trackingEnabledKey =
      'background_location_tracking_enabled';
  static const String _backgroundLocationRangeKey = 'background_location_range';

  // ============================================================
  // SET TRACKING STATE
  // ============================================================

  static Future<void> setTrackingEnabled(
    bool enabled,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _trackingEnabledKey,
      enabled,
    );
  }

  // ============================================================
  // GET TRACKING STATE
  // ============================================================

  static Future<bool> isTrackingEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(
          _trackingEnabledKey,
        ) ??
        false;
  }

  static Future<bool> setLocationRange(
    double range,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final save = await prefs.setDouble(
      _backgroundLocationRangeKey,
      range,
    );

    return save;
  }

  // ============================================================
  // GET TRACKING STATE
  // ============================================================

  static Future<double> getLocationRange() async {
    final prefs = await SharedPreferences.getInstance();

    var range = prefs.getDouble(
          _backgroundLocationRangeKey,
        ) ??
        50.0;

    return range;
  }
}
