class CheckPunchInOutDataModel {
  CheckPunchInOutDataModel({
    required this.status,
    required this.message,
    required this.data,
    required this.messageTitle,
  });

  final int status;
  final String message;
  final CheckPunchInOutData? data;
  final String messageTitle;

  factory CheckPunchInOutDataModel.fromJson(Map<String, dynamic> json){
    return CheckPunchInOutDataModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : CheckPunchInOutData.fromJson(json["data"]),
      messageTitle: json["messageTitle"] ?? "",
    );
  }

}

class CheckPunchInOutData {
  CheckPunchInOutData({
    required this.id,
    required this.punchInOutFlag,
  });

  final int id;
  final int punchInOutFlag;

  factory CheckPunchInOutData.fromJson(Map<String, dynamic> json){
    return CheckPunchInOutData(
      id: json["id"] ?? 0,
      punchInOutFlag: json["punch_in_out_flag"] ?? -1,
    );
  }

}

/*
{
	"status": 1,
	"message": "Success",
	"data": {
		"id": 0,
		"punch_in_out_flag": -1
	},
	"messageTitle": "Success"
}*/