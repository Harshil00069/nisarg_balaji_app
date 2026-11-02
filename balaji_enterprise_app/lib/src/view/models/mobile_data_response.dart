class MobileDataResponse {
  MobileDataResponse({
      this.status, 
      this.message, 
      this.mobileDataList,
      this.messageTitle,});

  MobileDataResponse.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      mobileDataList = [];
      json['data'].forEach((v) {
        mobileDataList?.add(MobileDataItem.fromJson(v));
      });
    }
    messageTitle = json['messageTitle'];
  }
  num? status;
  String? message;
  List<MobileDataItem>? mobileDataList;
  dynamic messageTitle;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (mobileDataList != null) {
      map['data'] = mobileDataList?.map((v) => v.toJson()).toList();
    }
    map['messageTitle'] = messageTitle;
    return map;
  }

}

class MobileDataItem {
  MobileDataItem({
      this.roleId, 
      this.menuSequence, 
      this.menuIcon, 
      this.menuName, 
      this.url, 
      this.isWebMenu, 
      this.check, 
      this.other,});

  MobileDataItem.fromJson(dynamic json) {
    roleId = json['roleId'];
    menuSequence = json['menuSequence'];
    menuIcon = json['menuIcon'];
    menuName = json['menuName'];
    url = json['url'];
    isWebMenu = json['isWebMenu'];
    check = json['check'];
    other = json['other'];
  }
  num? roleId;
  String? menuSequence;
  String? menuIcon;
  String? menuName;
  String? url;
  bool? isWebMenu;
  bool? check;
  dynamic other;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['roleId'] = roleId;
    map['menuSequence'] = menuSequence;
    map['menuIcon'] = menuIcon;
    map['menuName'] = menuName;
    map['url'] = url;
    map['isWebMenu'] = isWebMenu;
    map['check'] = check;
    map['other'] = other;
    return map;
  }

}