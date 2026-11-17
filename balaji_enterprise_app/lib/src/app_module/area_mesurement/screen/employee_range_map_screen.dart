
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/api_manager/api_implementor.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/location_track_by_company_data_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/database_helper.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class EmployeeRangeMapScreen extends StatefulWidget {
  const EmployeeRangeMapScreen({super.key});

  @override
  State<EmployeeRangeMapScreen> createState() =>
      _EmployeeRangeMapScreenState();
}

class _EmployeeRangeMapScreenState
    extends State<EmployeeRangeMapScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<LatLng> rangePoints = [];
  bool isLoading = true;

  // Use the same range ID that the admin saved.
  final int rangeId = 1;

  RxList<LocationDatum> locationDataByCompany = <LocationDatum>[].obs;

  final DatabaseHelper databaseHelper = DatabaseHelper();
  RxBool isPunchStatusLoading = false.obs;
  MapType mapType = MapType.hybrid;
  @override
  void initState() {
    super.initState();
    loadAdminRange();
  }

  Future<void> loadAdminRange() async {
   await  locationDataByCompanyListApi();

    final points = await _dbHelper.fetchAdminRange(rangeId);

    if (!mounted) return;

    setState(() {
      rangePoints = points;
      isLoading = false;
    });
  }


  Future<void> locationDataByCompanyListApi() async {
    locationDataByCompany.clear();
    await DatabaseHelper().clearAdminRangeTable();
    final user = await databaseHelper.fetchStoredUser();
    final String companyId = user.companyId;
    final String token = user.token;
    isPunchStatusLoading.value = true;
    // punchInOutStatus.value = 0;

    try {
      var response = await ApiImplementor.getLocationByCompanyApiImplementer(
          companyId: companyId, authToken: token);
      if (response.status == 1) {
        locationDataByCompany.addAll(response.data!.locationData);
        // isOnWorkPlace.value = await checkUserInRange();

        await DatabaseHelper().saveAdminRange(
          rangeId: 1,
          name: 'Office',
          rangePoints: locationDataByCompany,
        );
      }
      isPunchStatusLoading.value = false;
      return;
    } catch (e) {
      // punchInOutStatus.value = 0;
      isPunchStatusLoading.value = false;
      if (kDebugMode) {
        print(e);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (rangePoints.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No saved admin range found'),
        ),
      );
    }

    final markers = rangePoints.asMap().entries.map((entry) {
      return Marker(
        markerId: MarkerId('range_point_${entry.key}'),
        position: entry.value,
        infoWindow: InfoWindow(
          title: 'Range Point ${entry.key + 1}',
          snippet:
          '${entry.value.latitude}, ${entry.value.longitude}',
        ),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Range Map'),
      ),
      body: Obx(()=> isPunchStatusLoading.value ? const CircularProgressIndicator()  : GoogleMap(
        mapType: mapType,
        initialCameraPosition: CameraPosition(
          target: rangePoints.first,
          zoom: 17,
        ),
        markers: markers,
        polygons: {
          if (rangePoints.length >= 3)
            Polygon(
              polygonId: const PolygonId('admin_range'),
              points: rangePoints,
              strokeColor: Colors.blue,
              strokeWidth: 3,
              fillColor: Colors.blue.withValues(alpha: 0.15),
            ),
        },
        myLocationEnabled: false,
        zoomControlsEnabled: true,
      )),
    );
  }
}
