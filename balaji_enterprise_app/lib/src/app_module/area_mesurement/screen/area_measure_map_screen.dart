import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/app_dialogs.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/common_utils.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/database_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MeasureMapScreen extends StatefulWidget {
  final Function(List<LatLng> points) onAreaMeasureDone;

  const MeasureMapScreen({
    super.key,
    required this.onAreaMeasureDone,
  });

  @override
  State<MeasureMapScreen> createState() => _MeasureMapScreenState();
}

class _MeasureMapScreenState extends State<MeasureMapScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  List<LatLng> polygonPoints = [];
  Set<Marker> markers = {};
  bool _isLoading = true;
  bool _isOnTapMeasure = false;

  MapType mapType = MapType.hybrid;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showToast(message: "Location Disabled! Enable location services.");
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToast(
          message: "Permission Denied! Location permission is required.",
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showToast(
        message: "Permission Denied! Location access permanently denied.",
      );
      await Geolocator.openAppSettings();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(currentLocation!, 19.151926040649414),
    );
    // _initializeCoordinates();
  }

  // void _initializeCoordinates() async {
  //   if (widget.coordinates == null || widget.coordinates!.isEmpty) return;
  //   var coordinates = widget.coordinates!;
  //   for (var data in coordinates) {
  //     var location = LatLng(data.latitude, data.longitude);
  //     setState(() {
  //       polygonPoints.add(location);
  //       markers.add(
  //         Marker(
  //           markerId: MarkerId(polygonPoints.length.toString()),
  //           position: location,
  //           infoWindow: InfoWindow(title: 'Point ${polygonPoints.length}'),
  //         ),
  //       );
  //     });
  //   }
  //   setState(() {
  //     currentLocation = LatLng(
  //       coordinates.last.latitude,
  //       coordinates.last.longitude,
  //     );
  //   });
  //   mapController?.animateCamera(
  //     CameraUpdate.newLatLngZoom(currentLocation!, 19.151926040649414),
  //   );
  // }

  void _addPoint() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
    if (currentLocation != null) {
      setState(() {
        polygonPoints.add(currentLocation!);
        markers.add(
          Marker(
            markerId: MarkerId(polygonPoints.length.toString()),
            position: currentLocation!,
            infoWindow: InfoWindow(title: 'Point ${polygonPoints.length}'),
          ),
        );
      });
    }
  }

  void _onTapPoint(LatLng point) async {
    if (!_isOnTapMeasure) return;
    setState(() {
      polygonPoints.add(point);
      markers.add(
        Marker(
          markerId: MarkerId(polygonPoints.length.toString()),
          position: point,
          infoWindow: InfoWindow(title: 'Point ${polygonPoints.length}'),
        ),
      );
    });
  }

  void _reset() {
    setState(() {
      polygonPoints.clear();
      markers.clear();
    });
  }

  void _save() {
    if (polygonPoints.length < 3) {
      showToast(
        message: 'Please draw a polygon with at least 3 points.',
        delay: 3,
      );
      return;
    }
    double area = CommonUtils.calculateAreaInSquareMeters(polygonPoints);
    // double acres = CommonUtils.convertSquareMetersToAcres(area);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Saved Measurement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              const Text(
                'Points:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              ...polygonPoints
                  .map((p) => Text('Lat: ${p.latitude}, Lng: ${p.longitude}'))
                  .take(10),
              const SizedBox(height: 10),
              Text(
                'Total Point : ${polygonPoints.length}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Area : ${area.toStringAsFixed(2)} sq. meters',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              // Text(
              //   'Acre : ${acres.toStringAsFixed(2)}',
              //   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              // ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // widget.onAreaMeasureDone( polygonPoints);

                await DatabaseHelper().saveAdminRange(
                rangeId: 1,
                name: 'Office',
                rangePoints: polygonPoints,
                );
              },
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void unDo() {
    setState(() {
      polygonPoints.removeLast();
      markers.remove(markers.last);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measure Area'),
        actions: [
          polygonPoints.isNotEmpty
              ? IconButton(
                  tooltip: 'Save',
                  onPressed: unDo,
                  icon: Icon(Icons.undo),
                )
              : SizedBox(),
          IconButton(tooltip: 'Save', onPressed: _save, icon: Icon(Icons.done)),
          _buildMapTypeButton(),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      onMapCreated: (controller) => mapController = controller,
                      mapType: mapType,
                      initialCameraPosition: CameraPosition(
                        target:
                            currentLocation ?? LatLng(22.2470433, 70.7972683),
                        zoom: 19.151926040649414,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onTap: (position) => _onTapPoint(position),
                      markers: markers,
                      polygons: polygonPoints.length >= 3
                          ? {
                              Polygon(
                                polygonId: PolygonId("area"),
                                points: polygonPoints,
                                strokeColor: Colors.green,
                                strokeWidth: 2,
                                fillColor: Colors.green.shade100,
                              ),
                            }
                          : {},
                    ),
                  ),
                  _buildOnTapMeasureButton(),
                  _buildActionButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildMapTypeButton() {
    return PopupMenuButton(
      tooltip: 'Map Type',
      itemBuilder: (context) => MapType.values
          .map(
            (type) => PopupMenuItem(
              onTap: () {
                setState(() {
                  mapType = type;
                });
              },
              child: Text(type.name),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            onPressed: _addPoint,
            label: Text("Add Point"),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.close),
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            label: Text("Reset"),
          ),
        ],
      ),
    );
  }

  Widget _buildOnTapMeasureButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FilterChip(
        selected: _isOnTapMeasure,
        label: Text(
          'Measure by Tapping',
          style: TextStyle(
            color: _isOnTapMeasure ? Colors.white : Colors.black,
          ),
        ),
        checkmarkColor: _isOnTapMeasure ? Colors.white : Colors.black,

        autofocus: true,
        selectedColor: _isOnTapMeasure ? Colors.black : Colors.black,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10),
        //   side: BorderSide(color: Colors.black),
        // ),
        backgroundColor: _isOnTapMeasure ? Colors.black : Colors.white,
        onSelected: (bool value) {
          setState(() {
            _isOnTapMeasure = value;
          });
        },
      ),
    );
  }
}
