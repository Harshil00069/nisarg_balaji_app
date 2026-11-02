class LocationTrackByCompanyDataModel {
  LocationTrackByCompanyDataModel({
    required this.status,
    required this.message,
    required this.data,
    required this.messageTitle,
  });

  final int status;
  final String message;
  final LocationTrackByCompanyData? data;
  final String messageTitle;

  factory LocationTrackByCompanyDataModel.fromJson(Map<String, dynamic> json){
    return LocationTrackByCompanyDataModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : LocationTrackByCompanyData.fromJson(json["data"]),
      messageTitle: json["messageTitle"] ?? "",
    );
  }

}

class LocationTrackByCompanyData {
  LocationTrackByCompanyData({
    required this.id,
    required this.companyId,
    required this.locationData,
    required this.createdDate,
    required this.updatedDate,
  });

  final int id;
  final int companyId;
  final List<LocationDatum> locationData;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  factory LocationTrackByCompanyData.fromJson(Map<String, dynamic> json){
    return LocationTrackByCompanyData(
      id: json["id"] ?? 0,
      companyId: json["company_id"] ?? 0,
      locationData: json["location_data"] == null ? [] : List<LocationDatum>.from(json["location_data"]!.map((x) => LocationDatum.fromJson(x))),
      createdDate: DateTime.tryParse(json["created_date"] ?? ""),
      updatedDate: DateTime.tryParse(json["updated_date"] ?? ""),
    );
  }

}

class LocationDatum {
  LocationDatum({
    required this.lat,
    required this.long,
  });

  final double lat;
  final double long;

  factory LocationDatum.fromJson(Map<String, dynamic> json){
    return LocationDatum(
      lat: json["lat"] ?? 0.0,
      long: json["long"] ?? 0.0,
    );
  }

}

/*
{
	"status": 1,
	"message": "Success",
	"data": {
		"id": 1,
		"company_id": 9,
		"location_data": [
			{
				"lat": 23.3039,
				"long": 70.8022
			},
			{
				"lat": 23.31,
				"long": 70.81
			},
			{
				"lat": 23.32,
				"long": 70.82
			}
		],
		"created_date": "2026-10-31T08:04:37.459327",
		"updated_date": "2026-10-31T08:43:17.589894"
	},
	"messageTitle": "Success"
}*/