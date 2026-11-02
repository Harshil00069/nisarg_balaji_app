class PunchInOutModel {
  PunchInOutModel({
    required this.status,
    required this.message,
    required this.data,
    required this.messageTitle,
  });

  final int status;
  final String message;
  final PunchInOut? data;
  final String messageTitle;

  factory PunchInOutModel.fromJson(Map<String, dynamic> json){
    return PunchInOutModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : PunchInOut.fromJson(json["data"]),
      messageTitle: json["messageTitle"] ?? "",
    );
  }

}

class PunchInOut {
  PunchInOut({
    required this.id,
    required this.employeeId,
    required this.companyId,
    required this.punchInOutFlag,
    required this.createdOn,
  });

  final int id;
  final int employeeId;
  final int companyId;
  final int punchInOutFlag;
  final DateTime? createdOn;

  factory PunchInOut.fromJson(Map<String, dynamic> json){
    return PunchInOut(
      id: json["id"] ?? 0,
      employeeId: json["employee_id"] ?? 0,
      companyId: json["company_id"] ?? 0,
      punchInOutFlag: json["punch_in_out_flag"] ?? 0,
      createdOn: DateTime.tryParse(json["created_on"] ?? ""),
    );
  }

}

/*
{
	"status": 1,
	"message": "Attendance saved successfully.",
	"data": {
		"id": 8,
		"employee_id": 782,
		"company_id": 9,
		"punch_in_out_flag": 1,
		"created_on": "2026-11-01T05:12:43.2301933+00:00"
	},
	"messageTitle": "Success"
}*/