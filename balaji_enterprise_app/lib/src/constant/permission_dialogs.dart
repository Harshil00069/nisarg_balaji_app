// ignore_for_file: use_build_context_synchronously
import 'package:flutter/foundation.dart'
    show kDebugMode, debugPrint, debugPrintStack;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_dialogs.dart';

class PermissionUtil {
  // static Future<bool> checkLocationPermission() async {
  //   var checkLocationEnable = await Geolocator.isLocationServiceEnabled();
  //   if (!checkLocationEnable) {
  //     showToast(message: 'Please Turn ON Your Location');
  //     return false;
  //   }
  //
  //   var permission = await Geolocator.checkPermission();
  //
  //   if (permission == LocationPermission.denied) {
  //     bool checkPermission = false;
  //     await Geolocator.requestPermission().then((value) {
  //       if (value == LocationPermission.denied ||
  //           value == LocationPermission.deniedForever) {
  //         checkPermission = false;
  //       } else {
  //         checkPermission = true;
  //       }
  //     });
  //     return checkPermission;
  //   } else if (permission == LocationPermission.deniedForever) {
  //     Geolocator.openAppSettings();
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  static Future<bool> checkLocationPermission() async {
    var checkLocationEnable = await Geolocator.isLocationServiceEnabled();
    if (!checkLocationEnable) {
      showToast(message: 'Please Turn ON Your Location');
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      bool checkPermission = false;
      await Geolocator.requestPermission().then((value) {
        if (value == LocationPermission.denied ||
            value == LocationPermission.deniedForever) {
          checkPermission = false;
        } else {
          checkPermission = true;
        }
      });
      return checkPermission;
    } else if (permission == LocationPermission.deniedForever) {
      Geolocator.openAppSettings();
      return false;
    } else {
      return true;
    }
  }


  static Future<bool> requestEnableLocation() async {
    try {
      // 1. Check device GPS status.
      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      debugPrint('[LOCATION] GPS enabled: $serviceEnabled');

      if (!serviceEnabled) {
        debugPrint('[LOCATION] Returning false: GPS is disabled.');
        return false;
      }

      // 2. Check app permission without requesting a dialog.
      final LocationPermission permission = await Geolocator.checkPermission();

      debugPrint('[LOCATION] Permission: $permission');

      if (permission == LocationPermission.denied) {
        bool checkPermission = false;
        await Geolocator.requestPermission().then((value) {
          if (value == LocationPermission.denied ||
              value == LocationPermission.deniedForever) {
            checkPermission = false;
          } else {
            checkPermission = true;
          }
        });
        return checkPermission;
      }
      // 3. Confirm GPS remains enabled.
      final bool gpsStillEnabled =
      await Geolocator.isLocationServiceEnabled();

      debugPrint('[LOCATION] Final GPS status: $gpsStillEnabled');

      return gpsStillEnabled;
    } catch (e, stackTrace) {
      debugPrint('[LOCATION] Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }



  static Future<bool> requestBackgroundPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // _showToast('Location Service are off!');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (kDebugMode) {
      print("permission=> $permission");
    }
    if (permission == LocationPermission.deniedForever) {
      // Location permissions are permanently denied, open app settings
      await Geolocator.openAppSettings();
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      if (permission != LocationPermission.always) {
        // Request background location permission explicitly
        await Geolocator.requestPermission();
      }
    }
    return true;
  }

  static Future<bool> requestAlwaseLocation() async {
    var status = await Permission.locationAlways.status;

    if (status.isGranted) {
      return true;
      // Permission is already granted
    } else if (status.isDenied) {
      // Request permission if it was denied

      status = await Permission.locationAlways.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      // Open app settings if permission is permanently denied
      openAppSettings();
    }
    return false;
  }

  static Future<bool> requestLocationPermissions() async {
    // Request foreground location permission
    PermissionStatus foregroundStatus =
        await Permission.locationWhenInUse.request();

    if (foregroundStatus.isGranted) {
      // Now request background location permission
      PermissionStatus backgroundStatus =
          await Permission.locationAlways.request();

      if (backgroundStatus.isGranted) {
        // print("Background location permission granted");
        return true;
      } else {
        // print("Background location permission denied");
        return false;
      }
    } else {
      // print("Foreground location permission denied");
      return false;
    }
  }

  static Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (kDebugMode) {
      print('Notification Permission :- $status');
    }
    if (!status.isGranted) {
      // You can also use `await Permission.notification.request();` to request permission directly
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      // Permission granted, you can now show notifications
      if (kDebugMode) {
        print("Notification permission granted");
      }
    } else {
      // Permission denied
      if (kDebugMode) {
        print("Notification permission denied");
      }
    }
  }

  static Future<bool> requestContactPermission() async {
    var status = await Permission.contacts.status;
    var isPermissionGranted = false;

    if (status != PermissionStatus.granted &&
        status != PermissionStatus.permanentlyDenied) {
      var permissionStatus = await Permission.contacts.request();

      if (permissionStatus.isGranted) {
        isPermissionGranted = true;
      } else {
        isPermissionGranted = false;
      }
    } else {
      isPermissionGranted = true;
    }

    return isPermissionGranted;
  }
}
