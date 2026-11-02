import 'dart:convert';
import 'dart:io';

import 'package:disable_battery_optimizations_latest/disable_battery_optimizations_latest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/area_mesurement/screen/employee_range_map_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/background_service/background_service_state.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/custom_widget/battery_optimization_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/custom_widget/location_disclosure_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/screen/attendance_management_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/database_helper.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/permission_dialogs.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/helper/api_service.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/base_response.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/login_response.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/mobile_data_response.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/screens/webview_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_routes.dart';
import 'package:flutter_face_detection_balaji_enterprise/widgets/primary_text_input_widget.dart';
import 'package:flutter_face_detection_balaji_enterprise/widgets/primary_title_text_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List<Color> colors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.yellow,
  Colors.pink,
];

class Feature {
  final String title;
  final IconData icon;

  Feature({required this.title, required this.icon});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String baseUrl = 'http://13.127.180.155:8088/';
  bool loading = false;
  List<MobileDataItem> mobileDataList = [];
  LoginResponse? loginResponse;
  List<Feature> features = [
    Feature(title: 'Face Register', icon: Icons.app_registration),
    Feature(title: 'Face Authentication', icon: Icons.approval),
    Feature(title: 'Web View', icon: Icons.webhook),
    Feature(title: 'Update Attendance', icon: Icons.update),
    Feature(title: 'Api Call', icon: Icons.api),
  ];

  Future<void> initSetup() async {
    setState(() {
      loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('loginResponse');

    if (jsonData != null) {
      setState(() {
        loginResponse = LoginResponse.fromJson(jsonDecode(jsonData));
      });
      debugPrint("loginResponse: ${loginResponse?.toJson().toString()}");
      debugPrint("loginResponse: ${loginResponse?.data?.displayUserName}");
      mobileDataList =
          await ApiService().getMobileDataApi(loginResponse?.data?.roleId) ??
              [];

      mobileDataList.add(MobileDataItem(menuName: "Mesure setup",));
      mobileDataList.add(MobileDataItem(menuName: "Show Mesure",));
      mobileDataList.add(MobileDataItem(menuName: "Punch In-out",));
    }
    setState(() {
      loading = false;
    });

    await PermissionUtil.requestNotificationPermission();
   await checkLocationPermissionCondition().then((val){
     checkService();
   });
  }

  @override
  void initState() {
    super.initState();
    initSetup();
  }

  void showCustomDialog(BuildContext context, int? companyId) {
    DateTime? selectedDate;
    TextEditingController employeeCodeController = TextEditingController();
    TextEditingController employeeHourController = TextEditingController();
    TextEditingController employeeDateController = TextEditingController();

    Future<void> selectDate(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1970),
          lastDate: DateTime(3000));
      if (pickedDate != null) {
        selectedDate = pickedDate;
        employeeDateController.text =
            DateFormat('dd/MM/yyyy').format(pickedDate);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manual Attendance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: PrimaryTextInputWidget(
                        textController: employeeCodeController,
                        textInputAction: TextInputAction.done,
                        hintText: 'Employee Code',
                        fillColor: AppColors.textInputFill)),
                // Date Picker
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GestureDetector(
                        onTap: () {
                          selectDate(context);
                        },
                        child: AbsorbPointer(
                            child: PrimaryTextInputWidget(
                                suffixIcon: const Icon(Icons.calendar_month),
                                textController: employeeDateController,
                                textInputAction: TextInputAction.done,
                                textInputType: TextInputType.datetime,
                                hintText: 'Select Date',
                                fillColor: AppColors.textInputFill)))),
                // Employee Hours
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: PrimaryTextInputWidget(
                        textController: employeeHourController,
                        textInputAction: TextInputAction.done,
                        textInputType: TextInputType.number,
                        hintText: 'Employee Hours',
                        fillColor: AppColors.textInputFill)),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text('Cancel')),
            // Submit Button
            TextButton(
              onPressed: () async {
                if (employeeCodeController.text.trim().isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Please enter employee code.',
                    backgroundColor: AppColors.error
                  );
                } else if (employeeDateController.text.trim().isEmpty ||
                    selectedDate == null) {
                  Fluttertoast.showToast(
                      msg: 'Please select attendance date.',
                      backgroundColor: AppColors.error);
                } else if (employeeHourController.text.trim().isEmpty) {
                  Fluttertoast.showToast(
                      msg: 'Please add working hours.',
                      backgroundColor: AppColors.error);
                } else {
                  // API Call
                  BaseResponse? result = await ApiService()
                      .updateAttendanceByCodeApi(
                          companyId,
                          employeeCodeController.text.trim(),
                          employeeHourController.text.trim(),
                          selectedDate);

                  Fluttertoast.showToast(msg: result?.message ?? '');
                  Navigator.of(context).pop(); // Close dialog
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(loginResponse?.data?.company?.companyName ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        actions: [
          GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await DatabaseHelper().deleteUserData();
                await DatabaseHelper().clearAdminRangeTable();
                Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.routeLoginScreen,
                    (Route<dynamic> route) => false);
              },
              child: const Icon(Icons.exit_to_app)),
          const SizedBox(width: 16)
        ],
      ),
      body: Container(
        color: AppColors.scaffold,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: const [
                    BoxShadow(
                        spreadRadius: 0.1,
                        color: AppColors.grey,
                        blurRadius: 0.1,
                        offset: Offset(0, 0)),
                  ],
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 12),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                          (loginResponse?.data?.company?.logo ?? '').isNotEmpty
                              ? '$baseUrl${loginResponse?.data?.company?.logo ?? ''}'
                              : '',
                          height: 100,
                          width: 100,
                          errorBuilder: (a, b, c) => const SizedBox(),
                          fit: BoxFit.contain)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loginResponse?.data?.displayUserName ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Visibility(
                            visible: (loginResponse?.data?.employeeCode ?? '')
                                .isNotEmpty,
                            child: Text(loginResponse?.data?.employeeCode ?? '',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500))),
                        Visibility(
                            visible: (loginResponse?.data?.roleName ?? '')
                                .isNotEmpty,
                            child: Text(loginResponse?.data?.roleName ?? '',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            loading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()))
                : mobileDataList.isEmpty
                    ? const Expanded(
                        child: Center(
                            child: PrimaryTitleTextWidget(
                                title: 'No Records Found')))
                    : Expanded(
                        child: GridView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 2.85),
                            itemCount: mobileDataList.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = mobileDataList[index];

                              return GestureDetector(
                                  onTap: () {
                                    onItemTap(
                                        title: item.menuName ?? '',
                                        isWebView: item.isWebMenu ?? false,
                                        url: item.url ?? '');
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                                spreadRadius: 0.1,
                                                color: AppColors.grey,
                                                blurRadius: 0.1,
                                                offset: Offset(0, 0)),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          item.menuIcon != null
                                              ? Image.network(
                                                  item.menuIcon ?? '',
                                                  height: 32,
                                                  width: 32,
                                                  fit: BoxFit.contain)
                                              : const Icon(Icons.apps,
                                                  size: 32),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: Text(
                                                  mobileDataList[index]
                                                          .menuName ??
                                                      '',
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87))),
                                        ],
                                      )));
                            })),
          ],
        ),
      ),
    );
  }

  void onItemTap(
      {required String title, bool isWebView = false, required String url}) {
    switch (title) {
      case 'Face Register':
        TextEditingController employeeIdController = TextEditingController();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Center(
                  child: Text('Face Register',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18))),
              content: PrimaryTextInputWidget(
                  textController: employeeIdController,
                  textInputAction: TextInputAction.done,
                  hintText: 'Employee Code'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.black))),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12)),
                    onPressed: () {
                      if (employeeIdController.text.isNotEmpty) {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          AppRoutes.routeFaceRegistrationScreen,
                          arguments: {
                            'employeeCode': employeeIdController.text.trim(),
                            'companyId': loginResponse?.data?.companyId
                          },
                        );
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Please enter employee code',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      }
                    },
                    child: const Text('Submit',
                        style: TextStyle(color: AppColors.white))),
              ],
            );
          },
        );

        break;
      case 'Attendance':
        Navigator.pushNamed(context, AppRoutes.routeUpdateAttendanceScreen,
            arguments: {'companyId': loginResponse?.data?.companyId});
        break;
      case 'Manual Attendance':
        int? companyId = loginResponse?.data?.companyId ?? 0;
        showCustomDialog(context, companyId);
        break;
        case 'Mesure setup':
          Get.toNamed(AppRoutes.measureMapScreen);
          case 'Show Mesure':
          Get.to(const EmployeeRangeMapScreen());
        break;
        case 'Punch In-out':
          Get.to(const AddAttendanceScreen());
        break;
      default:
        Navigator.pushNamed(context, AppRoutes.routeWebViewScreen,
            arguments: WebViewModel(
                title: 'Web View',
                url: '$url?token=${loginResponse?.data?.token ?? ''}',
                token: loginResponse?.data?.token ?? ''));
        break;
    }
  }

  Future<void> checkLocationPermissionCondition() async {
    try {
      // 1. Check Android
      if (!Platform.isAndroid) {
        await BackgroundServiceState.setTrackingEnabled(false);
        return;
      }

      await BackgroundServiceState.setTrackingEnabled(true);

      // 2. Check GPS enabled
      final isLocationEnabled =
      await PermissionUtil.requestEnableLocation();

      if (!isLocationEnabled) {
        debugPrint("GPS is disabled");
        return;
      }

      // 3. Check location permission
      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.always) {
        debugPrint("Always location permission not granted");

        if (mounted) {
          Get.to(
                () => LocationDisclosureScreen(
              onSuccessfullyGrantPermission: () async {
                await checkLocationPermissionMethod();
              },
            ),
          );
        }
        return;
      }

      // 4. Check battery optimization
      await checkLocationPermissionMethod();

    } catch (e) {
      debugPrint("Location permission error: $e");
    }
  }

  Future<void> checkLocationPermissionMethod() async {
    await manageBackgroundService('');
  }

  Future<void> manageBackgroundService(String localStatus) async {
    try {
      // if (!Platform.isAndroid) return;

      // Check battery optimization
      final bool isBatteryOptimizationDisabled =
          await DisableBatteryOptimizationLatest
              .isBatteryOptimizationDisabled ??
              false;

      if (!isBatteryOptimizationDisabled) {
        debugPrint("Battery optimization is enabled");

        if (mounted) {
          Get.to(
                () => BatteryOptimizationScreen(
              onSuccessfullyGrantPermission: () async {
                await checkLocationPermissionMethod();
              },
            ),
          );
        }

        return;
      }

      // Both permissions granted
      debugPrint("GPS: Enabled");
      debugPrint("Location Permission: Always");
      debugPrint("Battery Optimization: Disabled");
      debugPrint("All permission checks completed successfully.");

    } catch (e) {
      debugPrint("Battery permission error: $e");
    }
  }

 /* Future<void> checkLocationPermissionCondition() async {
    final isAndroid = Platform.isAndroid;
    const isRelease = kDebugMode;
    // final isSalesUser = dashCtrl.isSalesEmployee.value;

    // Employee is NOT eligible for background tracking

    if (!isAndroid ) {
      await BackgroundServiceState.setTrackingEnabled(false);
      await stopBackgroundService();
      return;
    }

    // Employee is eligible
    await BackgroundServiceState.setTrackingEnabled(true);

    final checkLocation = await PermissionUtil.requestEnableLocation();

    if (!checkLocation) {
      await stopBackgroundService();
      return;
    }

    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission != LocationPermission.always) {
      Get.to(
            () => LocationDisclosureScreen(
          onSuccessfullyGrantPermission: () {
            checkLocationPermissionMethod();
          },
        ),
      );
    } else {
      checkLocationPermissionMethod();
    }
  }

  Future<void> checkLocationPermissionMethod() async {
    // await dashCtrl.getTodayPunchInOutTimeApi();
    // if ((dashCtrl.punchDetail.value.inTime.trim().isEmpty) &&
    //     (dashCtrl.punchDetail.value.outTime.trim().isEmpty)) {
    //   await manageBackgroundService('punchNotFound');
    // } else if ((dashCtrl.punchDetail.value.inTime.trim().isNotEmpty) &&
    //     (dashCtrl.punchDetail.value.outTime.trim().isEmpty)) {
    //   await manageBackgroundService('punchFound');
    // } else {
    //   await manageBackgroundService('');
    // }
    await manageBackgroundService('');
  }

  Future<void> manageBackgroundService(String localStatus) async {
    try {
      var checkBatteryOptimize = Platform.isAndroid
          ? await DisableBatteryOptimizationLatest
          .isBatteryOptimizationDisabled ??
          false
          : true;
      if (!checkBatteryOptimize) {
        if (mounted) {
          Get.to(
                () => BatteryOptimizationScreen(
              onSuccessfullyGrantPermission: () =>
                  checkLocationPermissionMethod(),
            ),
          );
        }
        // if (localStatus == "punchFound") {
        //   startBackgroundService();
        // } else {
        //   stopBackgroundService();
        // }
      }
    } catch (e) {
      // print("EE=> ${e}");
      // if (localStatus == "punchNotFound") {
      //   // Get.to(() => const AttendanceManagementScreen());
      // } else if (localStatus == "punchFound") {
      //   startBackgroundService();
      // } else {
      //   stopBackgroundService();
      // }
      // return;
    }
  }*/

  void checkService() async {
      bool isRunning = await isBackgroundServiceRunning();

    if (isRunning) {
      print("Background service is running");
    } else {
      print("Background service is stopped");
    }
  }

  Future<bool> isBackgroundServiceRunning() async {
    return await FlutterBackgroundService().isRunning();
  }
}
