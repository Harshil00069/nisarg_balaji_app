class GetEmployeeByFacedataResponse {
  GetEmployeeByFacedataResponse({
    this.status,
    this.message,
    this.data,
    this.messageTitle,
  });

  GetEmployeeByFacedataResponse.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? EmployeeItem.fromJson(json['data']) : null;
    messageTitle = json['messageTitle'];
  }

  num? status;
  String? message;
  EmployeeItem? data;
  String? messageTitle;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['messageTitle'] = messageTitle;
    return map;
  }
}

class EmployeeItem {
  EmployeeItem({this.employeeName, this.employeeId});

  EmployeeItem.fromJson(dynamic json) {
    employeeName = json['employeeName'];
    employeeId = json['employeeId'];
  }

  String? employeeName;
  int? employeeId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['employeeName'] = employeeName;
    map['employeeId'] = employeeId;
    return map;
  }
}
