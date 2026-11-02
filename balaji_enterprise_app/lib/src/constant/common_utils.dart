import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class CommonUtils {
  static const String applicationName = "Hr";

  static Future<bool> isPermissionGranted() async {
    PermissionStatus storagePermissionStatus = await Permission.storage.status;
    if (storagePermissionStatus.isGranted) {
      return true;
    } else if (storagePermissionStatus.isDenied) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  static logMessage(Object message) {
    if (kDebugMode) {
      print(message);
    }
  }

  static String greetings() {
    int hour = TimeOfDay.now().hour;
    if (hour < 12) {
      return "Good Morning!";
    } else if (hour >= 12 && hour <= 16) {
      return "Good Afternoon!";
    } else if (hour > 16 && hour < 20) {
      return "Good Evening!";
    } else {
      return "Welcome Back";
    }
  }

  static IconData getGreetingsIcon() {
    int hour = TimeOfDay.now().hour;
    if (hour < 12) {
      return Icons.sunny;
    } else if (hour >= 12 && hour <= 16) {
      return Icons.brightness_5;
    } else if (hour > 16 && hour < 20) {
      return Icons.brightness_4_outlined;
    } else {
      return Icons.dark_mode;
    }
  }

  static String getMonthNameByNumber(int month) {
    switch (month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
    }

    return '';
  }

  static int getMonthNoFromShortName(String monthName) {
    switch (monthName) {
      case "Jan":
        return 1;
      case "Feb":
        return 2;
      case "Mar":
        return 3;
      case "Apr":
        return 4;
      case "May":
        return 5;
      case "Jun":
        return 6;
      case "Jul":
        return 7;
      case "Aug":
        return 8;
      case "Sep":
        return 9;
      case "Oct":
        return 10;
      case "Nov":
        return 11;
      case "Dec":
        return 12;
    }
    return -1;
  }

  static String roundAmountNumber(String amount) {
    String clearAmount = amount.replaceAll(',', '').replaceAll('₹', '').trim();
    return double.parse(clearAmount).round().toString();
  }

  static Widget isDeviceBottomButtonOn(
    BuildContext pageContext, {
    required Widget child,
  }) {
    // This gives the padding that system UI uses (like status bar, notch, and system navigation)
    EdgeInsets viewPadding = MediaQuery.of(pageContext).viewPadding;
    // EdgeInsets padding = MediaQuery.of(pageContext).padding;

    double bottomInset = viewPadding.bottom;

    bool isGestureMode = bottomInset == 0;

    return Padding(
      padding: EdgeInsets.only(bottom: isGestureMode ? 0 : (35)),
      child: child,
    );
  }

  static String generateCurl(RequestOptions options) {
    try {
      final method = options.method.toUpperCase();
      final uri = options.uri.toString();

      StringBuffer curl = StringBuffer(
        "curl --location --request $method '$uri' \\\n",
      );

      // -----------------------------
      // HEADERS
      // -----------------------------
      options.headers.forEach((k, v) {
        curl.write("--header '$k: $v' \\\n");
      });

      // -----------------------------
      // HANDLE GET (NO BODY)
      // -----------------------------
      if (method == "GET") {
        return curl.toString();
      }

      final data = options.data;

      // -----------------------------
      // x-www-form-urlencoded
      // -----------------------------
      if (options.headers["Content-Type"] ==
              "application/x-www-form-urlencoded" ||
          options.headers["content-type"] ==
              "application/x-www-form-urlencoded") {
        if (data is Map) {
          final encoded = data.entries
              .map(
                (e) =>
                    "${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}",
              )
              .join("&");

          curl.write("--data '$encoded' \\\n");
        }

        return curl.toString();
      }

      // -----------------------------
      // FormData (files + fields)
      // -----------------------------
      if (data is FormData) {
        // fields
        for (var field in data.fields) {
          curl.write("--form '${field.key}=${field.value}' \\\n");
        }

        // files
        for (var file in data.files) {
          curl.write("--form '${file.key}=@\"${file.value.filename}\"' \\\n");
        }

        return curl.toString();
      }

      // -----------------------------
      // Default JSON body
      // -----------------------------
      if (data != null) {
        curl.write("--data '${jsonEncode(data)}' \\\n");
      }

      return curl.toString();
    } catch (e) {
      return "Error generating cURL: $e";
    }
  }

  static void logErrorMessage(Object message) {
    if (kDebugMode) {
      developer.log('', name: "Error", error: message);
    }
  }

  static double _toRadians(double degree) => degree * pi / 180;

  static double calculateAreaInSquareMeters(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    const double radius = 6371000; // Earth's radius in meters
    double area = 0;

    for (int i = 0; i < points.length; i++) {
      final LatLng p1 = points[i];
      final LatLng p2 = points[(i + 1) % points.length];

      double lat1 = _toRadians(p1.latitude);
      double lon1 = _toRadians(p1.longitude);
      double lat2 = _toRadians(p2.latitude);
      double lon2 = _toRadians(p2.longitude);

      area += (lon2 - lon1) * (2 + sin(lat1) + sin(lat2));
    }

    area = area * radius * radius / 2;
    return area.abs();
  }
}
