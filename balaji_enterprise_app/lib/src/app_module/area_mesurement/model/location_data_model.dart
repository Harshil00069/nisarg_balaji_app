class LocationDataModel {
  late double lat;
  late double long;


  LocationDataModel({
    required this.lat,
    required this.long,
  });

  Map<String, dynamic> toJson() {
    return {
      "lat": lat,
      "long": long
    };
  }
}