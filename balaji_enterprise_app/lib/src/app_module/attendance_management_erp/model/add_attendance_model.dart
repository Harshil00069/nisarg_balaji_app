class ErpAttendanceModel {
  late int flag;
  late String message;
  late String punchDateAndTime;

  ErpAttendanceModel(
      {this.flag = 0, this.message = '', this.punchDateAndTime = ''});

  ErpAttendanceModel.fromJson(Map<String, dynamic> json) {
    flag = json['FLG'] ?? 0;
    message = json['MSG'] ?? '';
    punchDateAndTime = json['PUNCH_DNT'] ?? '';
  }
}
