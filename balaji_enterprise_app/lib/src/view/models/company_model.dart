class CompanyModel {
  CompanyModel({
    int? companyId,
    String? companyName,
  }) {
    _companyId = companyId;
    _companyName = companyName;
  }

  CompanyModel.fromJson(dynamic json) {
    _companyId = json['id'];
    _companyName = json['companyName'];
  }

  int? _companyId;
  String? _companyName;

  int? get companyId => _companyId;
  String? get companyName => _companyName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _companyId;
    map['companyName'] = _companyName;
    return map;
  }
}
