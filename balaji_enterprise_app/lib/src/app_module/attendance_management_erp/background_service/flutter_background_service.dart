import 'dart:async';
import 'dart:ui';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/api_manager/api_config_erp_dio.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/insert_gps_treking_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/database_helper.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/permission_dialogs.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'background_service_state.dart';

// -----------------------------------------------------------------------------
// Configuration
// -----------------------------------------------------------------------------

const String notificationChannelId = 'FORGROUND_SERVICE';
const int notificationId = 888;

/// Get a location and check the employee's admin range every 30 seconds.
const Duration locationCheckInterval = Duration(seconds: 30);

/// If GPS is disabled, report it no more than once every 10 minutes.
const Duration gpsDisabledApiInterval = Duration(minutes: 10);

/// Must match the range ID saved by the admin screen.
const int employeeRangeId = 1;

final FlutterBackgroundService service = FlutterBackgroundService();

Timer? _locationTimer;
bool _isServiceRunning = false;
bool _isLocationProcessing = false;
DateTime? _lastGpsDisabledAttemptTime;
int checkGpsStatus = 0;

// -----------------------------------------------------------------------------
// Initialize service
// -----------------------------------------------------------------------------

Future<void> initializeService() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'Background Service',
    description: 'Location tracking service',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  await notifications
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onStart,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Location Service',
      initialNotificationContent: 'Tracking enabled',
      foregroundServiceNotificationId: notificationId,
    ),
  );
}

// -----------------------------------------------------------------------------
// Start / stop service
// -----------------------------------------------------------------------------

Future<void> startBackgroundService() async {
  try {
    final bool running = await service.isRunning();

    debugPrint('[UI] Background service running: $running');

    if (running) {
      debugPrint('[UI] Service is already running.');
      return;
    }

    debugPrint('[UI] Requesting background service start...');

    await service.startService();

    debugPrint('[UI] startService() request completed.');
  } catch (e, stackTrace) {
    debugPrint('[UI] Failed to start service: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> stopBackgroundService() async {
  try {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isLocationProcessing = false;
    _lastGpsDisabledAttemptTime = null;

    service.invoke('stop');
    _isServiceRunning = false;

    if (kDebugMode) debugPrint('Background service stop requested.');
  } catch (e, stackTrace) {
    debugPrint('Stop background service error: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

// -----------------------------------------------------------------------------
// Background service entry point
// -----------------------------------------------------------------------------

@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance serviceInstance) async {
  DartPluginRegistrant.ensureInitialized();

  _locationTimer?.cancel();
  _locationTimer = null;
  _isLocationProcessing = false;
  _lastGpsDisabledAttemptTime = null;

  serviceInstance.on('stop').listen((_) {
    if (kDebugMode) debugPrint('Stop event received in background isolate.');
    _locationTimer?.cancel();
    _locationTimer = null;
    serviceInstance.stopSelf();
  });

  // Check immediately at service start, then every 30 seconds.
  final Timer timer = Timer.periodic(locationCheckInterval, (timer) async {
    await _processLocation(serviceInstance, timer);
  });
  _locationTimer = timer;
  unawaited(_processLocation(serviceInstance, timer));

  return true;
}

// -----------------------------------------------------------------------------
// Main 30-second process
// -----------------------------------------------------------------------------

Future<void> _processLocation(
    ServiceInstance serviceInstance,
    Timer timer,
    ) async {
  if (_isLocationProcessing) {
    if (kDebugMode) {
      debugPrint('Previous location check is still running; skipped.');
    }
    return;
  }

  _isLocationProcessing = true;

  try {
    // 1. Check attendance tracking
    final trackingEnabled =
    await BackgroundServiceState.isTrackingEnabled();

    if (!trackingEnabled) {
      await _stopFromBackground(serviceInstance, timer);
      return;
    }

    // 2. Check GPS
    final locationServiceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!locationServiceEnabled) {
      checkGpsStatus = 0;

      if (serviceInstance is AndroidServiceInstance) {
        serviceInstance.setForegroundNotificationInfo(
          title: 'Location Disabled',
          content: 'Please enable device location',
        );
      }

      await _sendGpsDisabledHeartbeat();
      return;
    }

    // 3. Check existing permission only
    final LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      checkGpsStatus = 0;

      if (serviceInstance is AndroidServiceInstance) {
        serviceInstance.setForegroundNotificationInfo(
          title: 'Location Permission Disabled',
          content: 'Please allow location permission',
        );
      }

      await _sendGpsDisabledHeartbeat();
      return;
    }

    // 4. Get current GPS location
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    checkGpsStatus = 1;
    _lastGpsDisabledAttemptTime = null;

    if (kDebugMode) {
      debugPrint(
        'Current GPS: ${position.latitude}, ${position.longitude}',
      );
    }

    // 5. Sync pending offline events
    final connectivity = await Connectivity().checkConnectivity();

    final bool isOnline =
    !connectivity.contains(ConnectivityResult.none);

    if (isOnline) {
      await BackgroundLocationApi.syncPendingRangeEvents();

      final pendingEvents =
      await DatabaseHelper().getPendingRangeEvents();

      if (pendingEvents.isEmpty) {
        await _checkEmployeeRange(position);
      } else if (kDebugMode) {
        debugPrint('Pending events remain. Range check postponed.');
      }
    } else {
      await _checkEmployeeRange(position);
    }

    if (serviceInstance is AndroidServiceInstance) {
      serviceInstance.setForegroundNotificationInfo(
        title: 'Location Active',
        content: 'Checking employee range',
      );
    }

  } catch (e, stackTrace) {
    debugPrint('Background location process error: $e');
    debugPrintStack(stackTrace: stackTrace);
  } finally {
    _isLocationProcessing = false;
  }
}

// -----------------------------------------------------------------------------
// Geofence check and exit/return transitions
// -----------------------------------------------------------------------------

Future<void> _checkEmployeeRange(Position position) async {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  try {
    final user = await databaseHelper.fetchStoredUser();
    final String employeeId = user.empId;

    if (employeeId.isEmpty || employeeId == '0') {
      if (kDebugMode) debugPrint('Range check skipped: employee ID is missing.');
      return;
    }

    final List<LatLng> rangePoints =
    await databaseHelper.fetchAdminRange(employeeRangeId);

    if (rangePoints.length < 3) {
      if (kDebugMode) {
        debugPrint('Range check skipped: range $employeeRangeId has fewer than 3 points.');
      }
      return;
    }

    final LatLng currentLocation =
    LatLng(position.latitude, position.longitude);
    final bool isInside = isInsidePolygon(currentLocation, rangePoints);

    // rangeId identifies the admin polygon. isUserOut is a separate status.
    final int rangeId = employeeRangeId;
    final int isUserOut = isInside ? 0 : 1;

    final bool hasExitRecord =
    await databaseHelper.hasActiveRangeExit(
      employeeId: employeeId,
      rangeId: rangeId,
    );

    // EMPLOYEE INSIDE
    if (isInside) {
      if (!hasExitRecord) {
        if (kDebugMode) debugPrint('Employee is inside; no transition required.');
        return;
      }

      // true means the API succeeded OR the event was safely queued offline.
      final bool savedOrSent =
      await BackgroundLocationApi.processLocation(
        position: position,
        gpsStatus: 1,
        isUserOut: isUserOut,
      );

      if (!savedOrSent) {
        debugPrint('Return event failed and was not queued. Exit state retained.');
        return;
      }

      // Clear only after the return event is delivered or safely queued.
      await databaseHelper.clearActiveRangeExit(
        employeeId: employeeId,
        rangeId: rangeId,
      );

      if (kDebugMode) {
        debugPrint('Return event sent/queued. Active exit state cleared.');
      }
      return;
    }

    // EMPLOYEE OUTSIDE
    if (hasExitRecord) {
      if (kDebugMode) {
        debugPrint('Employee is still outside; exit record exists. API skipped.');
      }
      return;
    }

    // Save active exit state first to prevent repeated exit events.
    await databaseHelper.saveActiveRangeExit(
      employeeId: employeeId,
      rangeId: rangeId,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    final bool recordSaved =
    await databaseHelper.hasActiveRangeExit(
      employeeId: employeeId,
      rangeId: rangeId,
    );

    if (!recordSaved) {
      debugPrint('Exit event skipped: active exit state could not be saved.');
      return;
    }

    final bool savedOrSent =
    await BackgroundLocationApi.processLocation(
      position: position,
      gpsStatus: 1,
      isUserOut: isUserOut,
    );

    if (!savedOrSent) {
      // Neither API nor local queue succeeded, so allow retry next tick.
      await databaseHelper.clearActiveRangeExit(
        employeeId: employeeId,
        rangeId: rangeId,
      );
      debugPrint('Exit event failed and was not queued; active state reset.');
      return;
    }

    if (kDebugMode) {
      debugPrint('Exit event sent/queued. Active exit state retained.');
    }
  } catch (e, stackTrace) {
    debugPrint('Employee range check error: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

/// Returns true if [point] is inside the polygon.
/// Polygon points must be stored in drawing order.
bool isInsidePolygon(LatLng point, List<LatLng> polygon) {
  if (polygon.length < 3) return false;

  bool inside = false;
  int j = polygon.length - 1;

  for (int i = 0; i < polygon.length; i++) {
    final double xi = polygon[i].latitude;
    final double yi = polygon[i].longitude;
    final double xj = polygon[j].latitude;
    final double yj = polygon[j].longitude;

    final bool crosses =
        ((yi > point.longitude) != (yj > point.longitude)) &&
            (point.latitude <
                (xj - xi) * (point.longitude - yi) / (yj - yi) + xi);

    if (crosses) inside = !inside;
    j = i;
  }

  return inside;
}

// -----------------------------------------------------------------------------
// GPS-disabled heartbeat
// -----------------------------------------------------------------------------

Future<void> _sendGpsDisabledHeartbeat() async {
  final DateTime now = DateTime.now();

  // Throttle attempts, including failures, so a failed request does not retry
  // on every 30-second GPS check. GPS becoming available resets this timestamp.
  if (_lastGpsDisabledAttemptTime != null &&
      now.difference(_lastGpsDisabledAttemptTime!) < gpsDisabledApiInterval) {
    if (kDebugMode) debugPrint('GPS-disabled heartbeat is not due yet.');
    return;
  }

  final bool trackingEnabled = await BackgroundServiceState.isTrackingEnabled();
  if (!trackingEnabled) return;

  _lastGpsDisabledAttemptTime = now;

  if (kDebugMode) debugPrint('Sending GPS-disabled heartbeat.');

  final bool success = await BackgroundLocationApi.processGpsDisabledLocation();
  if (kDebugMode) {
    debugPrint(success
        ? 'GPS-disabled heartbeat succeeded.'
        : 'GPS-disabled heartbeat failed; next attempt after the interval.');
  }
}

// -----------------------------------------------------------------------------
// Stop service after tracking is disabled
// -----------------------------------------------------------------------------

Future<void> _stopFromBackground(
    ServiceInstance serviceInstance,
    Timer timer,
    ) async {
  timer.cancel();
  _locationTimer = null;
  _isLocationProcessing = false;
  _lastGpsDisabledAttemptTime = null;
  serviceInstance.stopSelf();
  _isServiceRunning = false;

  if (kDebugMode) debugPrint('Background service stopped: tracking disabled.');
}

// -----------------------------------------------------------------------------
// API and offline location handling
// -----------------------------------------------------------------------------

class BackgroundLocationApi {
  /// Sends the current location when internet is available. If offline, it saves
  /// the location in the existing location table and returns true if saved.
  static Future<bool> processLocation({
    required Position position,
    required int gpsStatus,
    required int isUserOut,
  }) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();

    try {
      final user = await databaseHelper.fetchStoredUser();

      if (kDebugMode) {
        debugPrint('userId => ${user.userId}');
        debugPrint('empId => ${user.empId}');
      }

      if (user.userId == '0' || user.empId == '0') {
        if (kDebugMode) debugPrint('Invalid stored user information.');
        return false;
      }

      int battery = 0;
      String address = '';

      try {
        battery = await Battery().batteryLevel;
      } catch (_) {
        battery = 0;
      }

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = '${place.street}, ${place.subLocality}, '
              '${place.locality}, ${place.administrativeArea}';
        }
      } catch (_) {
        address = 'No address found';
      }

      final connectivity = await Connectivity().checkConnectivity();
      final bool isOnline =
      !connectivity.contains(ConnectivityResult.none);

      if (isOnline) {
        final bool apiSuccess = await insertTrackDetailApi(
          token: user.token,
          baseURL: user.baseUrl,
          employeeId: user.empId,
          longitude: position.longitude.toString(),
          latitude: position.latitude.toString(),
          gpsStatus: gpsStatus.toString(),
          batteryStatus: battery.toString(),
          address: address,
          isUserOut: isUserOut,
          companyId: user.companyId,
        );

        if (apiSuccess) return true;

        // If the online request fails, preserve the transition for retry.
        final int queuedId =
        await databaseHelper.insertPendingRangeEvent(
          employeeId: user.empId,
          rangeId: employeeRangeId,
          latitude: position.latitude,
          longitude: position.longitude,
          isUserOut: isUserOut,
          gpsStatus: gpsStatus,
          batteryStatus: battery.toString(),
          address: address,
        );

        if (kDebugMode) {
          debugPrint(queuedId > 0
              ? 'API failed. Transition saved in pending queue.'
              : 'API failed and pending queue insert failed.');
        }
        return queuedId > 0;
      }

      // Offline: save only the exit/return transition, not every GPS tick.
      final int queuedId =
      await databaseHelper.insertPendingRangeEvent(
        employeeId: user.empId,
        rangeId: employeeRangeId,
        latitude: position.latitude,
        longitude: position.longitude,
        isUserOut: isUserOut,
        gpsStatus: gpsStatus,
        batteryStatus: battery.toString(),
        address: address,
      );

      if (kDebugMode) {
        debugPrint(queuedId > 0
            ? 'Offline transition saved in pending queue.'
            : 'Offline transition queue insert failed.');
      }

      return queuedId > 0;
    } catch (e, stackTrace) {
      debugPrint('Process location error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// Upload pending exit/return events in insertion order.
  /// Delete an event only after the API confirms success.
  static Future<void> syncPendingRangeEvents() async {
    final DatabaseHelper databaseHelper = DatabaseHelper();

    try {
      final user = await databaseHelper.fetchStoredUser();
      if (user.userId == '0' || user.empId == '0') return;

      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;

      final pendingEvents = await databaseHelper.getPendingRangeEvents();
      if (pendingEvents.isEmpty) return;

      if (kDebugMode) {
        debugPrint('Pending range events to upload: ${pendingEvents.length}');
      }

      for (final event in pendingEvents) {
        final currentConnectivity =
        await Connectivity().checkConnectivity();

        if (currentConnectivity.contains(ConnectivityResult.none)) {
          debugPrint('Internet disconnected. Remaining events retained.');
          break;
        }

        final bool success = await insertTrackDetailApi(
          token: user.token,
          baseURL: user.baseUrl,
          employeeId: event['employee_id'].toString(),
          companyId: user.companyId,
          latitude: event['latitude'].toString(),
          longitude: event['longitude'].toString(),
          gpsStatus: event['gps_status'].toString(),
          batteryStatus: event['battery_status'].toString(),
          address: event['address'].toString(),
          isUserOut: (event['is_user_out'] as num).toInt(),
        );

        if (!success) {
          debugPrint('Pending upload failed. This and later events remain queued.');
          break;
        }

        await databaseHelper.deletePendingRangeEvent(
          (event['id'] as num).toInt(),
        );

        if (kDebugMode) {
          debugPrint('Pending event ${event['id']} uploaded and deleted.');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Pending range event sync error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Reports GPS unavailable, no more than once every 10 minutes while enabled.
  static Future<bool> processGpsDisabledLocation() async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    final user = await databaseHelper.fetchStoredUser();

    if (user.userId == '0' || user.empId == '0') {
      return false;
    }

    int battery = 0;
    try {
      battery = await Battery().batteryLevel;
    } catch (_) {
      // Keep default battery value.
    }

    final connectivity = await Connectivity().checkConnectivity();
    final bool isOnline = !connectivity.contains(ConnectivityResult.none);
    if (!isOnline) {
      if (kDebugMode) {
        debugPrint('No internet: cannot send GPS-disabled heartbeat.');
      }
      return false;
    }

    // final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    return insertTrackDetailApi(
      token: user.token,
        baseURL: user.baseUrl,
        companyId: user.companyId,
        latitude: '0.0',
        longitude: '0.0',
        gpsStatus: '0',
        batteryStatus: battery.toString(),
        address: 'Location Disabled',
        isUserOut: 2,
        employeeId: user.empId
    );
  }

  /// Sends a GPS tracking detail to the existing endpoint.
  static Future<bool> insertTrackDetailApi({
    required String baseURL,
    required String batteryStatus,
    required String gpsStatus,
    required String latitude,
    required String longitude,
    required String address,
    required String employeeId,
    required String token,
    required String companyId,
    required int isUserOut
  }) async {
    if (employeeId == '0') return false;

    try {
      final bool enabled = await BackgroundServiceState.isTrackingEnabled();
      if (!enabled) {
        if (kDebugMode) debugPrint('Tracking disabled; API skipped.');
        return false;
      }

      final Map<String, dynamic> body = {
        "employee_id": employeeId,
        "company_id": companyId,
        "latitude": latitude,
        "longitude": longitude,
        "location_address": address,
        "punch_in_out_flag": isUserOut
      };

      // ErpDio's configured client is expected to contain the base URL.
      // baseURL is retained in this method signature to match existing callers.
      final response = await ErpDio.getDioClient().post(
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        'api/location-attendance-tracking',
        data: body,
      );

      final responseData = response.data;
      var result = InsertGpsTrackingDetailResponse.fromJson(responseData);

      final bool success = result.status == 1;

      if (kDebugMode) {
        debugPrint(success
            ? 'Location tracking API succeeded.'
            : 'Location tracking API returned an unsuccessful status.');
      }

      return success;
    } catch (e, stackTrace) {
      debugPrint('Location tracking API error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}
