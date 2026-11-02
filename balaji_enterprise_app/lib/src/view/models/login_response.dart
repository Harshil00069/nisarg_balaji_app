class LoginResponse {
  LoginResponse({
    this.status,
    this.message,
    this.data,
    this.messageTitle,
  });

  LoginResponse.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? LoginItem.fromJson(json['data']) : null;
    messageTitle = json['messageTitle'];
  }

  num? status;
  String? message;
  LoginItem? data;
  dynamic messageTitle;

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

class LoginItem {
  LoginItem(
      {this.username,
      this.userId,
      this.roleName,
      this.roleId,
      this.displayUserName,
      this.employeeCode,
      this.userImage,
      this.companyId,
      this.company,
      this.isEmployeeLogin,
      this.isSuperviserLogin,
      this.isAdmin,
      this.email,
      this.token});

  LoginItem.fromJson(dynamic json) {
    username = json['username'];
    userId = json['userId'];
    roleName = json['roleName'];
    roleId = json['roleId'];
    displayUserName = json['displayUserName'];
    employeeCode = json['employeeCode'];
    userImage = json['userImage'];
    companyId = json['companyId'];
    company =
        json['company'] != null ? Company.fromJson(json['company']) : null;
    isEmployeeLogin = json['isEmployeeLogin'];
    isSuperviserLogin = json['isSuperviserLogin'];
    isAdmin = json['isAdmin'];
    email = json['email'];
    token = json['token'];
  }

  String? username;
  num? userId;
  String? roleName;
  int? roleId;
  String? displayUserName;
  String? employeeCode;
  String? userImage;
  int? companyId;
  Company? company;
  bool? isEmployeeLogin;
  bool? isSuperviserLogin;
  bool? isAdmin;
  String? email;
  String? token;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = username;
    map['userId'] = userId;
    map['roleName'] = roleName;
    map['roleId'] = roleId;
    map['displayUserName'] = displayUserName;
    map['employeeCode'] = employeeCode;
    map['userImage'] = userImage;
    map['companyId'] = companyId;
    if (company != null) {
      map['company'] = company?.toJson();
    }
    map['isEmployeeLogin'] = isEmployeeLogin;
    map['isSuperviserLogin'] = isSuperviserLogin;
    map['isAdmin'] = isAdmin;
    map['email'] = email;
    map['token'] = token;
    return map;
  }
}

class Company {
  Company({
    this.id,
    this.companyName,
    this.logoFile,
    this.logo,
    this.createDate,
    this.createdBy,
    this.modifiedDate,
    this.modifiedBy,
    this.isActive,
    this.requiredWorkingHours,
    this.productionRate,
    this.companyEmail,
    this.empCodePrifix,
    this.isDefault,
    this.mobile,
    this.email,
    this.websiteUrl,
  });

  Company.fromJson(dynamic json) {
    id = json['id'];
    companyName = json['companyName'];
    logoFile = json['logoFile'];
    logo = json['logo'];
    createDate = json['createDate'];
    createdBy = json['createdBy'];
    modifiedDate = json['modifiedDate'];
    modifiedBy = json['modifiedBy'];
    isActive = json['isActive'];
    requiredWorkingHours = json['requiredWorkingHours'];
    productionRate = json['productionRate'];
    companyEmail = json['companyEmail'];
    empCodePrifix = json['empCodePrifix'];
    isDefault = json['isDefault'];
    mobile = json['mobile'];
    email = json['email'];
    websiteUrl = json['websiteUrl'];
  }

  num? id;
  String? companyName;
  dynamic logoFile;
  String? logo;
  dynamic createDate;
  dynamic createdBy;
  dynamic modifiedDate;
  dynamic modifiedBy;
  bool? isActive;
  num? requiredWorkingHours;
  num? productionRate;
  String? companyEmail;
  String? empCodePrifix;
  bool? isDefault;
  String? mobile;
  dynamic email;
  String? websiteUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['companyName'] = companyName;
    map['logoFile'] = logoFile;
    map['logo'] = logo;
    map['createDate'] = createDate;
    map['createdBy'] = createdBy;
    map['modifiedDate'] = modifiedDate;
    map['modifiedBy'] = modifiedBy;
    map['isActive'] = isActive;
    map['requiredWorkingHours'] = requiredWorkingHours;
    map['productionRate'] = productionRate;
    map['companyEmail'] = companyEmail;
    map['empCodePrifix'] = empCodePrifix;
    map['isDefault'] = isDefault;
    map['mobile'] = mobile;
    map['email'] = email;
    map['websiteUrl'] = websiteUrl;
    return map;
  }
}
