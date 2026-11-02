import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/api_manager/api_implementor.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/background_service/flutter_background_service.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/location_track_by_company_data_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/today_in_out_time_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/app_dialogs.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/database_helper.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/permission_dialogs.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/login_response.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceManagementController extends GetxController {
  // final dateFormat = DateFormat('yyyy-MM-dd');
  // var today = DateTime.now();
  // RxString selectedFromDate = ''.obs;
  // RxString selectedToDate = ''.obs;
  // RxInt userType = 0.obs;
  // DateTime? fromDate;
  // DateTime? toDate;
  // Rx<GetTodayInOutTimeModel> punchDetail = GetTodayInOutTimeModel().obs;

  // ===== For Add Attendance =====

  List<ConnectivityResult> connectionStatusOnly = [ConnectivityResult.none];
  final Connectivity connectivityCheck = Connectivity();
  late StreamSubscription<List<ConnectivityResult>>
  connectivitySubscriptionCheck;

  final Completer<GoogleMapController> googleMapController =
      Completer<GoogleMapController>();

  CameraPosition kGooglePlex = const CameraPosition(
    target: LatLng(22.2470433, 70.7972683),
    zoom: 14.4746,
  );

  Rx<File> pickImage = File("").obs;

  RxBool hasErrorGoogleMap = false.obs;
  RxBool isLoadingGoogleMap = true.obs;
  RxInt isConnect = 0.obs;
  RxString currentCity = ''.obs;

  RxBool isPunchInLoading = false.obs;
  RxBool isPunchStatusLoading = false.obs;
  RxBool isOnWorkPlace = true.obs;

  Placemark? currentLocationData;
  Position? currentPositionData;
  RxString fullAddress = ''.obs;

  RxInt punchInOutStatus = 0.obs;

  final DatabaseHelper databaseHelper = DatabaseHelper();

  RxList<LocationDatum> locationDataByCompany =<LocationDatum>[].obs;

  @override
  void onInit() {
    super.onInit();
    // initData();
    initializeApiData();
  }

  @override
  void dispose() {
    super.dispose();
    disposeGoogleMap();
  }

  Future<void> initializeApiData() async {
   await locationDataByCompanyListApi();
   await checkInOutByUserIdListApi();
    await getCurrentLocation();
    // getTodayPunchInOutTimeApi();
  }

  Future<void> disposeGoogleMap() async {
    final GoogleMapController controller = await googleMapController.future;
    controller.dispose();
  }

  Future<void> getCurrentLocation() async {
    try {
      hasErrorGoogleMap.value = false;
      isLoadingGoogleMap.value = true;
      var checkLocation = await PermissionUtil.requestEnableLocation();
      if (checkLocation) {
        var position = await Geolocator.getCurrentPosition();
        currentPositionData = position;
        var currentPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19.151926040649414,
        );

        var address = await GeocodingPlatform.instance!
            .placemarkFromCoordinates(position.latitude, position.longitude);
        currentLocationData = address.first;
        currentCity.value = address.first.locality ?? '';
        fullAddress.value =
            "${currentLocationData!.street},${currentLocationData!.subLocality},${currentLocationData!.name},${currentLocationData!.locality},${currentLocationData!.administrativeArea},${currentLocationData!.postalCode}";

        final GoogleMapController controller = await googleMapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(currentPosition),
        );
        isLoadingGoogleMap.value = false;
        // print("Map Load $isLoadingGoogleMap ANd Has Error $hasErrorGoogleMap");
        return;
      } else {
        isLoadingGoogleMap.value = false;
        hasErrorGoogleMap.value = true;
        Get.defaultDialog(
          onWillPop: () async {
            Get.back();
            return false;
          },
          radius: 6.0,
          title: 'Required Permission!',
          middleText:
              'Location Permission Required to access this feature,You have to manually allow location permission by click on open setting button and find locations and then allow permission!',
          textConfirm: 'OPEN SETTINGS',
          textCancel: 'Cancel',
          onConfirm: () {
            Geolocator.openAppSettings().then((value) => Get.back());
          },
          onCancel: () => Get.back(),
        );
        // print("Map Load $isLoadingGoogleMap ANd Has Error $hasErrorGoogleMap");
        return;
      }
    } catch (e) {
      isLoadingGoogleMap.value = false;
      hasErrorGoogleMap.value = true;
      // print("Map Load $isLoadingGoogleMap ANd Has Error $hasErrorGoogleMap");
      return;
    }
  }

  Future<void> savePunchInData({required String punchInOrOutFlag}) async {
    try {
      final user = await databaseHelper.fetchStoredUser();
      final String employeeId = user.empId;
      final String companyId = user.companyId;
      final String token = user.token;

      if (pickImage.value.path.isEmpty) {
        showToast(message: 'Please Capture Your Picture');
        return;
      } else if (currentLocationData == null || currentPositionData == null) {
        showToast(message: 'Please Map Reload To Fetch Your Proper Location');
        return;
      }
      var tmpcurDt = currentLocationData!;
      var tmpPositionDt = currentPositionData!;
      if (isPunchInLoading.value) {
        return;
      }

      isPunchInLoading.value = true;
      String localCity = tmpcurDt.locality ?? "";
      String name = tmpcurDt.name ?? "";
      String subLocality = tmpcurDt.subLocality ?? "";
      String administrativeArea = tmpcurDt.administrativeArea ?? "";
      String postalCode = tmpcurDt.postalCode ?? "";
      String country = tmpcurDt.country ?? "";
      var address =
          "$name, $subLocality, $localCity, $administrativeArea $postalCode, $country";
      var response = await ApiImplementor.insertPunchInOutApi(
        latitude: '${tmpPositionDt.latitude}',
        longitude: '${tmpPositionDt.longitude}',
        companyId: companyId,
        employeeId: employeeId,
        authToken: token,
        locationAddress: address,
        punchInOutFlag: punchInOrOutFlag,
        // for Punch In = 0 & Punch Out = 1
        gpsFlag: '1',
      );

      if (response.status == 1) {
        if (punchInOrOutFlag == "0") {
          service.startService();
          // punchDetail.value.erpInAttendance = response.punchDateAndTime;
          update();
        } else if (punchInOrOutFlag == "1") {
          stopBackgroundService();
          // punchDetail.value.erpOutAttendance = response.punchDateAndTime;
          update();
        } else {}
        Get.back();
        Get.back();
        showToast(message: response.message, type: Toast.success);
      } else {
        Get.back();
        showToast(message: response.message);
      }
      isPunchInLoading.value = false;
    } catch (e) {
      isPunchInLoading.value = false;
      showToast(message: "Something went Wrong!", type: Toast.error);
    }
  }

  // Future<void> getTodayPunchInOutTimeApi() async {
  //   try {
  //     var response = await ApiImplementor.getTodayInOutApiImplementor();
  //     punchDetail.value = response;
  //
  //     var userName = await SharedPref.getString(StringConstants.userName);
  //     var password = await SharedPref.getString(StringConstants.password);
  //     var compId = await SharedPref.getString(StringConstants.compId);
  //     var branchId = await SharedPref.getString(StringConstants.branchId);
  //
  //     final checkLoginResponse = await ErpLoginModel.erpLoginApiCall(
  //       userName: userName,
  //       password: password,
  //       compId: compId,
  //       branchId: branchId,
  //     );
  //     if (checkLoginResponse.flag == 1) {
  //       await SharedPref.save(
  //         StringConstants.loginUser,
  //         checkLoginResponse.toJson(),
  //       );
  //       await LoginUserDetail.fillUserDetailBucket();
  //     }
  //
  //     if (punchDetail.value.isTakeRangeAction == 1) {
  //       isOnWorkPlace.value = checkUserOnWorkPlace();
  //     }
  //     update();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  // }

  // bool checkUserOnWorkPlace() {
  //   double range = punchDetail.value.range;
  //   var isNotDefaultValsCheck =
  //       punchDetail.value.attendanceLatitude.trim().isNotEmpty &&
  //       punchDetail.value.attendanceLongitude.trim().isNotEmpty &&
  //       range > 0.0;
  //   if (isNotDefaultValsCheck) {
  //     double punchLat = double.parse(punchDetail.value.attendanceLatitude);
  //     double punchLong = double.parse(punchDetail.value.attendanceLongitude);
  //     var distanceInMeters = Geolocator.distanceBetween(
  //       currentPositionData!.latitude,
  //       currentPositionData!.longitude,
  //       punchLat,
  //       punchLong,
  //     );
  //     if (distanceInMeters < range) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else {
  //     return false;
  //   }
  // }

  Future<void> checkInOutByUserIdListApi() async {
    final user = await databaseHelper.fetchStoredUser();
    final String employeeId = user.empId;
    final String companyId = user.companyId;
    final String token = user.token;
    isPunchStatusLoading.value = true;
    punchInOutStatus.value = 0;
    try {
      var response = await ApiImplementor.getPunchInOutStatusApiImplementer(employeeId: employeeId,companyId: companyId,authToken: token);
      if (response.status == 1) {
        punchInOutStatus.value = response.data!.punchInOutFlag;
      }
        isPunchStatusLoading.value = false;
      return;
    } catch (e) {
      punchInOutStatus.value = 0;
      isPunchStatusLoading.value = false;
      if (kDebugMode) {
        print(e);
      }
    }
  }


  Future<void> locationDataByCompanyListApi() async {
    locationDataByCompany.clear();
    final user = await databaseHelper.fetchStoredUser();
    final String companyId = user.companyId;
    final String token = user.token;
    isPunchStatusLoading.value = true;
    punchInOutStatus.value = 0;
    await DatabaseHelper().clearAdminRangeTable();
    try {
      var response = await ApiImplementor.getLocationByCompanyApiImplementer(companyId: companyId,authToken: token);
      if (response.status == 1) {
        locationDataByCompany.addAll(response.data!.locationData);
        isOnWorkPlace.value  = await checkUserInRange();

        await DatabaseHelper().saveAdminRange(
          rangeId: 1,
          name: 'Office',
          rangePoints: locationDataByCompany,
        );
      }
        isPunchStatusLoading.value = false;
      return;
    } catch (e) {
      punchInOutStatus.value = 0;
      isPunchStatusLoading.value = false;
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<bool> checkUserInRange() async {
    // Get current user location
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    double userLat = position.latitude;
    double userLong = position.longitude;

    // Allowed radius in meters
    double allowedDistance = 50;

    for (var location in locationDataByCompany) {
      double distance = Geolocator.distanceBetween(
        userLat,
        userLong,
        location.lat,
        location.long,
      );

      print("Distance: $distance meters");

      if (distance <= allowedDistance) {
        return true;
      }
    }

    return false;
  }
}
