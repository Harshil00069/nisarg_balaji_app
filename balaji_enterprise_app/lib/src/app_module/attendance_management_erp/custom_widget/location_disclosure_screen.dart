import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/app_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';


class LocationDisclosureScreen extends StatefulWidget {
  final Function() onSuccessfullyGrantPermission;

  const LocationDisclosureScreen({
    super.key,
    required this.onSuccessfullyGrantPermission,
  });

  @override
  State<LocationDisclosureScreen> createState() =>
      _LocationDisclosureScreenState();
}

class _LocationDisclosureScreenState extends State<LocationDisclosureScreen> {
  // late TapGestureRecognizer _longPressRecognizer;

  @override
  void initState() {
    super.initState();
    // _longPressRecognizer = TapGestureRecognizer()..onTap = _handlePress;
  }

  // void _handlePress() async {
  //   var url = Uri.parse(StringConstants.privacyPolicyUrl);
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url);
  //   }
  // }

  // ---------------------------------------------------------
  // STEP 1: REQUEST NORMAL LOCATION (WHEN-IN-USE)
  // ---------------------------------------------------------
  static Future<bool> requestNormalLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      showLocationRequiredDialog();
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // ---------------------------------------------------------
  // STEP 2: SHOW DIALOG ASKING FOR ALWAYS PERMISSION
  // ---------------------------------------------------------
  Future<void> showAlwaysLocationDialog() async {
    await Get.dialog(
      AlertDialog(
        title: Text(
          "Enable Always Location",
          style: AppFonts.subTitle1(color: Colors.black),
        ),
        content: Text(
          "To enable background updates (attendance, routing, field tracking), "
          "you must allow the app to access your location even when not in use.",
          style: AppFonts.bodyText2(color: Colors.black),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("CANCEL")),
          TextButton(
            onPressed: () async {
              Get.back();
              await requestAlwaysLocation();
            },
            child: const Text("ALLOW ALWAYS"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ---------------------------------------------------------
  // STEP 3: REQUEST BACKGROUND (ALWAYS) LOCATION
  // ---------------------------------------------------------
  Future<void> requestAlwaysLocation() async {
    PermissionStatus status = await Permission.locationAlways.status;

    if (status.isGranted) {
      widget.onSuccessfullyGrantPermission.call();
      Navigator.of(context).pop();
      return;
    }

    // Request
    status = await Permission.locationAlways.request();

    if (status.isGranted) {
      widget.onSuccessfullyGrantPermission.call();
      Navigator.of(context).pop();
      return;
    }

    if (status.isPermanentlyDenied) {
      Get.dialog(
        AlertDialog(
          title: Text(
            "Permission Required",
            style: AppFonts.subTitle1(color: Colors.black),
          ),
          content: Text(
            "To continue, enable 'Allow All The Time' for location "
            "from your phone's app settings.",
            style: AppFonts.bodyText2(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
                Get.back();
              },
              child: const Text("OPEN SETTINGS"),
            ),
          ],
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // Permanent denial dialog for normal permission
  // ---------------------------------------------------------
  static void showLocationRequiredDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Permission Required',
          style: AppFonts.subTitle1(color: Colors.black),
        ),
        content: Text(
          'Please enable location permission from settings.',
          style: AppFonts.bodyText2(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Get.back();
            },
            child: const Text('OPEN SETTINGS'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),

                      Text(
                        "Turning on location service allow us to provide feature like : ",
                        style: AppFonts.title2(color: Colors.black),
                      ),
                      const SizedBox(height: 14),

                      // ------------------ All your existing UI ------------------
                      Row(
                        spacing: 6,
                        children: [
                          Icon(Icons.fingerprint),
                          Text(
                            "Attendance Management:",
                            style: AppFonts.subTitle1(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "To accurately track your attendance at designated locations",
                        style: AppFonts.bodyText2(color: Colors.black),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        spacing: 6,
                        children: [
                          Icon(Icons.campaign),
                          Text(
                            "Sales Marketing:",
                            style: AppFonts.subTitle1(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "We provide location-based updates and insights to assist your workflow.",
                        style: AppFonts.bodyText2(color: Colors.black),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        spacing: 6,
                        children: [
                          Icon(Icons.route),
                          Text(
                            "Route Optimization:",
                            style: AppFonts.subTitle1(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ensures efficient routing for your tasks.",
                        style: AppFonts.bodyText2(color: Colors.black),
                      ),

                      const SizedBox(height: 10),
                      Text(
                        "We require your location in the Background even when your app is closed.",
                        style: AppFonts.bodyText2(color: Colors.black),
                      ),

                      const SizedBox(height: 10),

                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'By granting permission, you agree to our',
                              style: AppFonts.bodyText2(color: Colors.black),
                            ),
                            // TextSpan(
                            //   text: ' Privacy Policy. ',
                            //   style: AppFonts.bodyText1(color: Colors.blue),
                            //   recognizer: _longPressRecognizer,
                            // ),
                            TextSpan(
                              text:
                                  'Please review it for more information on how we handle your data. ',
                              style: AppFonts.bodyText2(color: Colors.black),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        "You can change this option later in the app settings.",
                        style: AppFonts.bodyText2(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),

              // ------------------ NEXT BUTTON ------------------
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue),),
                    onPressed: () async {
                      bool granted = await requestNormalLocation();

                      if (granted) {
                        // NORMAL granted → ask ALWAYS permission
                        await showAlwaysLocationDialog();
                      }
                    },
                    child: Text('Next', style: AppFonts.label1()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
