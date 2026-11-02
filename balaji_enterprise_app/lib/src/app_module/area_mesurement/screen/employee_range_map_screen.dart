
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/database_helper.dart';
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

  @override
  void initState() {
    super.initState();
    loadAdminRange();
  }

  Future<void> loadAdminRange() async {
    final points = await _dbHelper.fetchAdminRange(rangeId);

    if (!mounted) return;

    setState(() {
      rangePoints = points;
      isLoading = false;
    });
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
      body: GoogleMap(
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
      ),
    );
  }
}
