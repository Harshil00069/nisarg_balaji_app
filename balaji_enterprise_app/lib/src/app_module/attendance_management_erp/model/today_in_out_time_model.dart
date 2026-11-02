// import 'package:get/get.dart';


class ListTodayInOutTimeModel {
  late int total;
  late String message;
  late List<GetTodayInOutTimeModel> punchHistory;

  ListTodayInOutTimeModel(
      {this.total = 0, this.message = '', List<GetTodayInOutTimeModel>? punchHistory}) {
    this.punchHistory = punchHistory ?? [];
  }

  ListTodayInOutTimeModel.fromJson(Map<String, dynamic> json) {
    total = json['TOTAL'] ?? 0;
    message = json['MESSAGE'] ?? "";
    punchHistory = <GetTodayInOutTimeModel>[];
    if (json['RECORDS'] != null) {
      json['RECORDS'].forEach((v) {
        punchHistory.add(GetTodayInOutTimeModel.fromJson(v));
      });
    }
  }
}


class GetTodayInOutTimeModel {
  late String inTime;
  late String outTime;
  late String attendanceLatitude;
  late String attendanceLongitude;
  late int isTakeRangeAction;
  late double range;
  late String erpInAttendance;
  late String erpOutAttendance;

  GetTodayInOutTimeModel({
    this.inTime = '',
    this.outTime = '',
    this.erpInAttendance = '',
    this.erpOutAttendance = '',
    this.attendanceLatitude = '',
    this.attendanceLongitude = '',
    this.isTakeRangeAction = 0,
    this.range = 0.0,
  });

  GetTodayInOutTimeModel.fromJson(Map<String, dynamic> json) {
    inTime = "${json['intime'] == "-" ? "" : json['intime'] ?? ""}";
    outTime = "${json['outtime'] == "-" ? "" : json['outtime'] ?? ""}";
    attendanceLatitude = json['attendance_latitude'] ?? "";
    attendanceLongitude = json['attendance_longitude'] ?? "";
    isTakeRangeAction = json['restrict_attendance'] ?? 0;
    range = double.tryParse('${json['range'] ?? "0.0"}') ?? 0.0;
    // canPunch.value = (inTime.trim().isNotEmpty) && (outTime.trim().isNotEmpty)
    //     ? true
    //     : false;
    erpInAttendance = '';
    erpOutAttendance = '';
  }
}
