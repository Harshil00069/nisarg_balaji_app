import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/today_in_out_time_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/permission_dialogs.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class AttendanceManagementController extends GetxController {
  final dateFormat = DateFormat('yyyy-MM-dd');
  var today = DateTime.now();
  RxString selectedFromDate = ''.obs;
  RxString selectedToDate = ''.obs;
  RxInt userType = 0.obs;
  DateTime? fromDate;
  DateTime? toDate;
  Rx<GetTodayInOutTimeModel> punchDetail = GetTodayInOutTimeModel().obs;

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
  RxBool isPunchOutLoading = false.obs;
  RxBool isOnWorkPlace = true.obs;

  Placemark? currentLocationData;
  Position? currentPositionData;
  RxString fullAddress = ''.obs;

  // RxList<CheckInOut> checkInOutUserDataList = <CheckInOut>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeApiData();
  }

  @override
  void dispose() {
    super.dispose();
    disposeGoogleMap();
  }

  Future<void> initializeApiData() async {
    // checkInOutByUserIdListApi();
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

/*  Future<void> savePunchInData({required String punchInOrOutFlag}) async {
    try {
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
      String localSt = tmpcurDt.administrativeArea ?? "";
      String localCountry = tmpcurDt.administrativeArea ?? "";
      String name = tmpcurDt.name ?? "";
      String subLocality = tmpcurDt.subLocality ?? "";
      String administrativeArea = tmpcurDt.administrativeArea ?? "";
      String postalCode = tmpcurDt.postalCode ?? "";
      String country = tmpcurDt.country ?? "";
      var address =
          "$name, $subLocality, $localCity, $administrativeArea $postalCode, $country";
      var response = await ApiImplementor.insertAttendanceDataApi(
        latitude: '${tmpPositionDt.latitude}',
        longitude: '${tmpPositionDt.longitude}',
        address: address,
        city: localCity,
        district: localCity,
        taluka: localCity,
        state: localSt,
        country: localCountry,
        punchInOutFlag: punchInOrOutFlag,
        // for Punch In = 0 & Punch Out = 1
        gpsFlag: '1',
        file: pickImage.value,
        fileName: getFileName,
      );

      if (response.flag == 1) {
        await getTodayPunchInOutTimeApi();

        if (punchInOrOutFlag == "0") {
          service.startService();
          punchDetail.value.erpInAttendance = response.punchDateAndTime;
          update();
        } else if (punchInOrOutFlag == "1") {
          stopBackgroundService();
          punchDetail.value.erpOutAttendance = response.punchDateAndTime;
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
  }*/

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

  bool checkUserOnWorkPlace() {
    double range = punchDetail.value.range;
    var isNotDefaultValsCheck =
        punchDetail.value.attendanceLatitude.trim().isNotEmpty &&
        punchDetail.value.attendanceLongitude.trim().isNotEmpty &&
        range > 0.0;
    if (isNotDefaultValsCheck) {
      double punchLat = double.parse(punchDetail.value.attendanceLatitude);
      double punchLong = double.parse(punchDetail.value.attendanceLongitude);
      var distanceInMeters = Geolocator.distanceBetween(
        currentPositionData!.latitude,
        currentPositionData!.longitude,
        punchLat,
        punchLong,
      );
      if (distanceInMeters < range) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  // Future<void> checkInOutByUserIdListApi() async {
  //   try {
  //     checkInOutUserDataList.clear();
  //
  //     var response = await ApiImplementor.getCheckInOutByUserIdListApi();
  //     if (response.checkInOutRecords.isNotEmpty) {
  //       checkInOutUserDataList.addAll(response.checkInOutRecords);
  //     }
  //     return;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  // }

  String get getFileName => pickImage.value.path.split('/').last;
}
