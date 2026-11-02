class InsertGpsTrackingDetailResponse {
  late int status;
  late String msg;

  InsertGpsTrackingDetailResponse({this.status = 0, this.msg = ''});

  InsertGpsTrackingDetailResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'] ?? 0;
    msg = json['msg'] ?? "";
  }
}
