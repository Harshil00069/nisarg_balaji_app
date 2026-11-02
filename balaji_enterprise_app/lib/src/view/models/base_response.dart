class BaseResponse {
  BaseResponse({
      this.status, 
      this.message, 
      this.data, 
      this.messageTitle,});

  BaseResponse.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'];
    messageTitle = json['messageTitle'];
  }
  num? status;
  String? message;
  String? data;
  String? messageTitle;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    map['data'] = data;
    map['messageTitle'] = messageTitle;
    return map;
  }
}