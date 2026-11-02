class LocationDataModel {
  final int? id;
  late String name;
  final String latitude;
  final String longitude;
  final String createdAt;
  final String batteryLevel;

  LocationDataModel({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.batteryLevel,
  });

  factory LocationDataModel.fromMap(Map<String, dynamic> json) =>
      LocationDataModel(
        id: json["_id"] ?? 0,
        name: json["name"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        createdAt: json["createdAt"],
        batteryLevel: json["batteryLevel"],
      );

  Map<String, dynamic> toMap() => {
        "_id": id,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "createdAt": createdAt,
        "batteryLevel": batteryLevel,
      };
}

class LocationUserDataModel {
  final String empId;
  final String userId;
  final String baseUrl;

  LocationUserDataModel({
    required this.empId,
    required this.userId,
    required this.baseUrl,
  });

  factory LocationUserDataModel.fromMap(Map<String, dynamic> json) =>
      LocationUserDataModel(
        empId: json["loginEmpId"] ?? "0",
        userId: json["loginUserId"] ?? "0",
        baseUrl: json["baseUrl"] ?? "",
      );

  Map<String, dynamic> toMap() => {
    "loginEmpId": empId,
    "loginUserId": userId,
    "baseUrl": baseUrl,
  };
}

