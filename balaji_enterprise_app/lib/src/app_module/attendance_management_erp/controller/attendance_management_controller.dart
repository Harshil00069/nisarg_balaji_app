import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/api_manager/api_implementor.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/background_service/flutter_background_service.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/location_track_by_company_data_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/app_dialogs.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/database_helper.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/permission_dialogs.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AttendanceManagementController extends GetxController {
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

  RxList<LocationDatum> locationDataByCompany = <LocationDatum>[].obs;

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

      final checkLocation =
      await PermissionUtil.requestEnableLocation();

      if (!checkLocation) {
        isLoadingGoogleMap.value = false;
        hasErrorGoogleMap.value = true;

        Get.defaultDialog(
          title: 'Required Permission!',
          middleText: 'Please enable location permission and GPS.',
          textConfirm: 'OPEN SETTINGS',
          textCancel: 'Cancel',
          onConfirm: () async {
            await Geolocator.openAppSettings();
            Get.back();
          },
          onCancel: () => Get.back(),
        );
        return;
      }

      // Request high-accuracy GPS location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 20),
        ),
      );

      currentPositionData = position;

      // Check GPS accuracy
      debugPrint('========== GPS DETAILS ==========');
      debugPrint('Latitude: ${position.latitude}');
      debugPrint('Longitude: ${position.longitude}');
      debugPrint('Accuracy: ${position.accuracy} meters');
      debugPrint('Timestamp: ${position.timestamp}');
      debugPrint('Speed: ${position.speed}');
      debugPrint('=================================');

      final currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      final currentPosition = CameraPosition(
        target: currentLatLng,
        zoom: 19,
      );

      // Get address
      final address = await GeocodingPlatform.instance!
          .placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (address.isNotEmpty) {
        currentLocationData = address.first;
        currentCity.value = address.first.locality ?? '';

        fullAddress.value =
        "${address.first.street},"
            "${address.first.subLocality},"
            "${address.first.name},"
            "${address.first.locality},"
            "${address.first.administrativeArea},"
            "${address.first.postalCode}";
      }

      // Move camera to actual GPS position
      if (googleMapController.isCompleted) {
        final controller = await googleMapController.future;

        await controller.animateCamera(
          CameraUpdate.newCameraPosition(currentPosition),
        );
      }

      isLoadingGoogleMap.value = false;
    } catch (e, stackTrace) {
      debugPrint('Location Error: $e');
      debugPrint('$stackTrace');

      isLoadingGoogleMap.value = false;
      hasErrorGoogleMap.value = true;
    }
  }

  Future<void> savePunchInData({required String punchInOrOutFlag}) async {
    try {
      final user = await databaseHelper.fetchStoredUser();
      final String employeeId = user.empId;
      final String companyId = user.companyId;
      final String token = user.token;

      final List<LatLng> rangePoints = await databaseHelper.fetchAdminRange(employeeRangeId);

      if (pickImage.value.path.isEmpty) {
        showToast(message: 'Please Capture Your Picture');
        return;
      } else if (currentLocationData == null || currentPositionData == null) {
        showToast(message: 'Please Map Reload To Fetch Your Proper Location');
        return;
      } else if(rangePoints.isEmpty){
        showToast(message: 'Contact to Admin');
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
          await databaseHelper.updateBaseUrl('1');
          await startBackgroundService();
          update();
        } else if (punchInOrOutFlag == "1") {
          await databaseHelper.updateBaseUrl('');
          await stopBackgroundService();
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

  Future<void> checkInOutByUserIdListApi() async {
    final user = await databaseHelper.fetchStoredUser();
    final String employeeId = user.empId;
    final String companyId = user.companyId;
    final String token = user.token;
    isPunchStatusLoading.value = true;
    punchInOutStatus.value = 0;
    try {
      var response = await ApiImplementor.getPunchInOutStatusApiImplementer(
          employeeId: employeeId, companyId: companyId, authToken: token);
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
    await DatabaseHelper().clearAdminRangeTable();
    final user = await databaseHelper.fetchStoredUser();
    final String companyId = user.companyId;
    final String token = user.token;
    isPunchStatusLoading.value = true;
    punchInOutStatus.value = 0;

    try {
      var response = await ApiImplementor.getLocationByCompanyApiImplementer(
          companyId: companyId, authToken: token);
      if (response.status == 1) {
        locationDataByCompany.addAll(response.data!.locationData);
        // isOnWorkPlace.value = await checkUserInRange();
          if(locationDataByCompany.isNotEmpty){
            await DatabaseHelper().saveAdminRange(
              rangeId: 1,
              name: 'Office',
              rangePoints: locationDataByCompany,
            );
          }
      }
      locationDataByCompany.clear();
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

  Set<Polygon> get companyRangePolygons {
    if (locationDataByCompany.length < 3) {
      return {};
    }

    List<LatLng> points = locationDataByCompany.map((location) {
      return LatLng(
        location.lat,
        location.long,
      );
    }).toList();

    return {
      Polygon(
        polygonId: const PolygonId('admin_range'),
        points: points,
        strokeWidth: 3,
        strokeColor: Colors.red,
        fillColor: Colors.red.withValues(alpha: 0.20),
      ),
    };
  }

  /*Future<bool> checkUserInRange() async {
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


      if (distance <= allowedDistance) {
        return true;
      }
    }

    return false;
  }*/
}
