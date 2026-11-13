import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/check_punch_in_out_data_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/location_track_by_company_data_model.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/model/punch_in_out_model.dart';

import 'api_config_erp_dio.dart';
import 'api_user_read_error_handler.dart';

class ApiImplementor {
  static void logResponse(Object object) {
    if (kDebugMode) {
      print("Response : $object");
    }
  }

  static void logUrl(Object object) {
    if (kDebugMode) {
      print("URL : $object");
    }
  }

  static void logBody(Object object) {
    if (kDebugMode) {
      print("Body : $object");
    }
  }

  static Future<PunchInOutModel> insertPunchInOutApi({
    required String latitude,
    required String longitude,
    required String locationAddress,
    required String punchInOutFlag,
    required String gpsFlag,
    required String employeeId,
    required String companyId,
    required String authToken,
  }) async {
    try {
      Map<String, dynamic> body = {
        'employee_id': employeeId,
        'company_id': companyId,
        'latitude': latitude,
        'longitude': longitude,
        'location_address': locationAddress,
        'punch_in_out_flag': punchInOutFlag,
        'gps_flag': gpsFlag,
      };
      // print("1930 body=> $body");
      final response = await ErpDio.getDioClient().post(
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        'api/location-attendance',
        data: body,
      );
      return PunchInOutModel.fromJson(response.data);
    } catch (error) {
      return PunchInOutModel(
        message: "Internal Server Error During Fetch Customer",
        status: 0,
        data: null,
        messageTitle: '',
      );
    }
  }

  static Future<CheckPunchInOutDataModel> getPunchInOutStatusApiImplementer({
    required String employeeId,
    required String companyId,
    required String authToken,
  }) async {
    try {
      Map<String, String> body = {
        'employee_id': employeeId,
        'company_id': companyId,
      };
      final response = await ErpDio.getDioClient().get(
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        'api/location-attendance',
        queryParameters: body,
      );
      if (response.statusCode == 200) {
        CheckPunchInOutDataModel version = CheckPunchInOutDataModel.fromJson(
          response.data,
        );
        return version;
      } else {
        throw HandleException(exceptionMsg: response.statusMessage.toString());
      }
    } catch (error) {
      rethrow;
    }
  }

  static Future<LocationTrackByCompanyDataModel>
      getLocationByCompanyApiImplementer({
    required String companyId,
    required String authToken,
  }) async {
    try {
      Map<String, String> body = {
        'company_id': companyId,
      };
      final response = await ErpDio.getDioClient().get(
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        'api/location-track-company',
        queryParameters: body,
      );
      if (response.statusCode == 200) {
        LocationTrackByCompanyDataModel version =
            LocationTrackByCompanyDataModel.fromJson(
          response.data,
        );
        return version;
      } else {
        throw HandleException(exceptionMsg: response.statusMessage.toString());
      }
    } catch (error) {
      rethrow;
    }
  }

  static Future<PunchInOutModel> setLocationByCompanyApiImplementer({
    required String companyId,
    required String authToken,
    required List jsonDetail,
  }) async {
    try {
      Map<String, dynamic> body = {
        'company_id': companyId,
        'location_data': jsonDetail,
      };
      final response = await ErpDio.getDioClient().post(
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        'api/location-track-company',
        data: body,
      );
      if (response.statusCode == 200) {
        PunchInOutModel punchInOutModel = PunchInOutModel.fromJson(
          response.data,
        );
        return punchInOutModel;
      } else {
        throw HandleException(exceptionMsg: response.statusMessage.toString());
      }
    } catch (error) {
      rethrow;
    }
  }
}
