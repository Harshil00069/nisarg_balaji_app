import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/base_response.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/get_employee_by_facedata_response.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/login_response.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/company_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/mobile_data_response.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/face_features.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  List<CompanyModel> postList = [];

  Future<List<CompanyModel>> getAllCompanyApi() async {
    try {
      final response = await http
          .get(Uri.parse('http://13.127.180.155:8088/Base/GetAllCompanies'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        postList = data.map((e) => CompanyModel.fromJson(e)).toList();
        return postList;
      } else {
        debugPrint('Failed to load companies: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return [];
    }
  }

  Future<LoginResponse?> getLoginApi(
      int? companyId, String username, String password) async {
    try {
      final response = await http.post(
          Uri.parse(
              'http://13.127.180.155:8088/Login/authenticate?CompanyId=$companyId&Username=$username&Password=$password'),
          headers: {"Content-Type": "application/json"});
      LoginResponse data = LoginResponse.fromJson(jsonDecode(response.body));

      return data;
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }

  Future<List<MobileDataItem>?> getMobileDataApi(int? roleId) async {
    final url = Uri.parse(
        'http://13.127.180.155:8088/Mobile/getmobiledata?RoleId=$roleId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        MobileDataResponse mobileDataResponse =
            MobileDataResponse.fromJson(jsonDecode(response.body));
        debugPrint('Mobile Data: ${mobileDataResponse.mobileDataList?.length}');
        return mobileDataResponse.mobileDataList ?? [];
      } else {
        debugPrint('Error fetching mobile data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }

  Future<BaseResponse?> getFaceRegisterApi(
      int? companyId, String? employeeCode, FaceFeatures faceFeatures) async {
    final url =
        Uri.parse('http://13.127.180.155:8088/Mobile/register-facedata');

    try {
      Map<String, dynamic> requestBody = {
        "CompanyId": '$companyId',
        "EmployeeCode": employeeCode,
        "FaceData": jsonEncode(faceFeatures.toJson()),
      };

      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody));
      debugPrint('getFaceRegisterApi request: ${response.request.toString()}');
      debugPrint('getFaceRegisterApi response: ${response.body.toString()}');
      debugPrint('getFaceRegisterApi body: ${jsonEncode(requestBody)}');

      final data = BaseResponse.fromJson(jsonDecode(response.body));

      return data;
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }

  //Using Post API
  Future<GetEmployeeByFacedataResponse?> getEmployeeByFaceDataApi(
      int? companyId, FaceFeatures faceFeatures) async {
    final url =
        Uri.parse('http://13.127.180.155:8088/Mobile/getemployeebyfacedata');
    try {
      Map<String, dynamic> requestBody = {
        "CompanyId": '$companyId',
        "FaceData": jsonEncode(faceFeatures.toJson()),
      };
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody));
      debugPrint('updateAttendanceApi request: ${response.request.toString()}');
      debugPrint('updateAttendanceApi response: ${response.body.toString()}');
      debugPrint('updateAttendanceApi body: ${jsonEncode(requestBody)}');

      if (response.statusCode == 200) {
        return GetEmployeeByFacedataResponse.fromJson(
            jsonDecode(response.body));
      } else {
        debugPrint('Error fetching face register data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }

  Future<BaseResponse?> updateAttendanceApi(
      int? companyId, int? employeeId, String? hours, DateTime? date) async {
    final url =
        Uri.parse('http://13.127.180.155:8088/Mobile/update-attendance');

    try {
      Map<String, dynamic> requestBody = {
        "CompanyId": '$companyId',
        "EmployeeId": '$employeeId',
        "AttendanceDate": DateFormat('MM/dd/yyyy').format(date!),
        "Hours": hours,
      };

      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody));
      debugPrint('updateAttendanceApi request: ${response.request.toString()}');
      debugPrint('updateAttendanceApi response: ${response.body.toString()}');
      debugPrint('updateAttendanceApi body: ${jsonEncode(requestBody)}');

      final data = BaseResponse.fromJson(jsonDecode(response.body));

      return data;
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }

  Future<BaseResponse?> updateAttendanceByCodeApi(
      int? companyId, String? employeeCode, String? hours, DateTime? date) async {
    final url = Uri.parse('http://13.127.180.155:8088/Mobile/update-attendance');

    try {
      Map<String, dynamic> requestBody = {
        "CompanyId": '$companyId',
        "EmployeeCode": '$employeeCode',
        "AttendanceDate": DateFormat('MM/dd/yyyy').format(date!),
        "Hours": hours,
      };

      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody));
      debugPrint('updateAttendanceApi request: ${response.request.toString()}');
      debugPrint('updateAttendanceApi response: ${response.body.toString()}');
      debugPrint('updateAttendanceApi body: ${jsonEncode(requestBody)}');
      final data = BaseResponse.fromJson(jsonDecode(response.body));

      return data;
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }
}
