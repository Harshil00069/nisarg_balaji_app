import 'dart:convert';
import 'dart:io';

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
    final response = await ErpDio.getDioClient().post(options: Options(
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
      status: 0, data: null, messageTitle: '',
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
    final response = await ErpDio.getDioClient().get(options: Options(
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

  static Future<LocationTrackByCompanyDataModel> getLocationByCompanyApiImplementer({
    required String companyId,
    required String authToken,
  }) async {
    try {
      Map<String, String> body = {
        'company_id': companyId,
      };
      final response = await ErpDio.getDioClient().get(options: Options(
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
        LocationTrackByCompanyDataModel version = LocationTrackByCompanyDataModel.fromJson(
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
      final response = await ErpDio.getDioClient().post(options: Options(
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

  // static Future<CheckVersionInfoModel> getVersionInfoApiImplementer() async {
  //   var appVersion = GetVersion.getBuildNumber();
  //   var appVersionName = GetVersion.getVersion();
  //   var platform = Platform.isAndroid ? '0' : '1';
  //   var comId = LoginUserDetail.erpUser.value.compId;
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'version_name': appVersionName,
  //       'version_code': "$appVersion",
  //       'update_severity': '0',
  //       'platform': platform,
  //       'comp_id': '$comId',
  //     });
  //     final response = await ErpDio.getDioClient().get(
  //       'GetLatestVesion',
  //       queryParameters: body,
  //     );
  //     if (response.statusCode == 200) {
  //       CheckVersionInfoModel version = CheckVersionInfoModel.fromJson(
  //         response.data,
  //       );
  //       return version;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<GetAllVendorModel> getAllVendorApiImplementor({
  //   required String venName,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'ven_name': venName,
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Vendor',
  //       queryParameters: body,
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetAllVendorModel getAllVendorModel = GetAllVendorModel.fromJson(
  //         response.data,
  //       );
  //       return getAllVendorModel;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<GetVendorToPONumberModel> getVendorToPONumberApiImplementor({
  //   required String venName,
  //   required int pomBrId,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'ven_name': venName,
  //       'pom_brm_id': "$pomBrId",
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Vendor_To_PO_number',
  //       queryParameters: body,
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetVendorToPONumberModel getVendorToPONumberModel =
  //           GetVendorToPONumberModel.fromJson(response.data);
  //       return getVendorToPONumberModel;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<GetPOToItemDetailsModel> getPONumberToItemDetailApiImplementor({
  //   required String pomIds,
  //   required String pomPodIds,
  //   required int requestFor,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'pom_ids': pomIds,
  //       'pom_pod_ids': pomPodIds,
  //       'request_for': "$requestFor",
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_PO_To_Item_Details',
  //       queryParameters: body,
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetPOToItemDetailsModel getPOToItemDetailsModel =
  //           GetPOToItemDetailsModel.fromJson(response.data);
  //       return getPOToItemDetailsModel;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<GetLocationModel> getGrnItemLocationDetailApiImplementor({
  //   required int locId,
  //   required String locName,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'Loc_id': "$locId",
  //       'loc_name': locName,
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Location',
  //       queryParameters: body,
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetLocationModel getLocationModel = GetLocationModel.fromJson(
  //         response.data,
  //       );
  //       return getLocationModel;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<GetVehicleGatePassSrNoModel>
  // getVehicleGatePassSrNoDetailApiImplementor() async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Vehical_Gate_Pass_SrNo',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetVehicleGatePassSrNoModel model =
  //           GetVehicleGatePassSrNoModel.fromJson(response.data);
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<GetVehicleGatePassDataModel>
  // getVehicleGatePassDetailListApiImplementor({
  //   required String fromDate,
  //   required String toDate,
  //   required int gvgpType,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'fromdate': fromDate,
  //       'todate': toDate,
  //       'gvgp_type': "$gvgpType",
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Vehical_Gate_Pass_Data',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetVehicleGatePassDataModel model =
  //           GetVehicleGatePassDataModel.fromJson(response.data);
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<AddIntoSalesOrderModel> insertSalesOrderApiCall({
  //   required int cusId,
  //   required String date,
  //   required String itemJson,
  //   required String remarks,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     int passUsrId = LoginUserDetail.erpUser.value.id;
  //     int passCompId = LoginUserDetail.erpUser.value.compId;
  //     body.addAll({
  //       'user_id': '$passUsrId',
  //       'comp_id': '$passCompId',
  //       'cus_id': '$cusId',
  //       'som_date': date,
  //       'item_detail_json': itemJson,
  //       'remarks': remarks,
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().post(
  //       'Insert_Sales_Order',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       AddIntoSalesOrderModel model = AddIntoSalesOrderModel.fromJson(
  //         response.data,
  //       );
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<InsertGRNModel> insertGoodsReceivedNotesApiImplementor({
  //   required String date,
  //   required String pomIDs,
  //   required int venID,
  //   required String itemJson,
  //   required String remarks,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'GRN_Date': date,
  //       'ven_id': "$venID",
  //       'pom_ids': pomIDs,
  //       'remarks': remarks,
  //       'item_detail_json': itemJson,
  //     });
  //     logBody(body);
  //     final response = await ErpDio.clientPost(
  //       'Insert_Goods_Received_Note',
  //       passInQuery: false,
  //       body: body,
  //     );
  //     InsertGRNModel model = InsertGRNModel.fromJson(
  //       jsonDecode(response ?? {}),
  //     );
  //     return model;
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // //=========================== for perform and leadger  module=======================================
  //
  // static Future<GetSalesInvoiceReportByIdModel> salesInvoiceSheetDwn({
  //   required int somId,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'som_id': somId.toString(),
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Preforma_Invoice_Print_On_Respectiove_Sales_order',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetSalesInvoiceReportByIdModel model =
  //           GetSalesInvoiceReportByIdModel.fromJson(response.data);
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  //
  // static Future<GetDistributorWiseSalesInvoiceListModel>
  // getDistributorWiseSalesInvoiceListDetailApi({
  //   required String fromDate,
  //   required String toDate,
  //   required int cusId,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'fdt': fromDate,
  //       'tdt': toDate,
  //       'cust_id': cusId.toString(),
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Data_Performa_Invoice',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetDistributorWiseSalesInvoiceListModel model =
  //           GetDistributorWiseSalesInvoiceListModel.fromJson(response.data);
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<GetSalesInvoiceByCusIdModel> getSalesInvoiceDetailByCusIdApi({
  //   required String fromDate,
  //   required String toDate,
  //   required int cusId,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'from_dt': fromDate,
  //       'to_dt': toDate,
  //       'cus_id': cusId.toString(),
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'get_sales_invoice_detail_by_cus_id',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetSalesInvoiceByCusIdModel model =
  //           GetSalesInvoiceByCusIdModel.fromJson(response.data);
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<GetSalesInvoiceReportByInvoiceIdModel>
  // getSalesInvoiceReportByIdApi({required int invId}) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     int usrID = LoginUserDetail.erpUser.value.id;
  //     int compID = LoginUserDetail.erpUser.value.compId;
  //     body.addAll({
  //       'user_id': '$usrID',
  //       'comp_id': '$compID',
  //       'inv_id': '$invId',
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_SalesInvoice_Report_By_Id',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetSalesInvoiceReportByInvoiceIdModel model =
  //           GetSalesInvoiceReportByInvoiceIdModel.fromJson(response.data);
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // // ======== Attendance Module ============
  //
  // static Future<ErpAttendanceModel> insertAttendanceDataApi({
  //   required String latitude,
  //   required String longitude,
  //   required String address,
  //   required String city,
  //   required String district,
  //   required String taluka,
  //   required String state,
  //   required String country,
  //   required String punchInOutFlag,
  //   required String gpsFlag,
  //   required File file,
  //   required String fileName,
  // }) async {
  //   int cmId = LoginUserDetail.erpUser.value.compId;
  //   int usrId = LoginUserDetail.erpUser.value.id;
  //   try {
  //     var formData = FormData.fromMap({
  //       ...ErpDio.commonBodyMap(),
  //       'user_id': usrId,
  //       'comp_id': cmId,
  //       'branch_id': "0",
  //       'emp_code': "",
  //       'latitude': latitude,
  //       'longitude': longitude,
  //       'location_address': address,
  //       'location_city': city,
  //       'location_district': district,
  //       'location_taluka': taluka,
  //       'location_state': state,
  //       'location_country': country,
  //       'punch_in_out_flag': punchInOutFlag,
  //       'gps_flag': gpsFlag,
  //       'file': await MultipartFile.fromFile(file.path, filename: fileName),
  //     });
  //
  //     // var data = {
  //     //   'app_version': '$version',
  //     //   'android_id': dvcId,
  //     //   'device_id': 0,
  //     //   'key': ApiUrls.apiKey,
  //     //   'user_id': usrId,
  //     //   'comp_id': cmId,
  //     //   'branch_id': "0",
  //     //   'emp_code': "",
  //     //   'latitude': latitude,
  //     //   'longitude': longitude,
  //     //   'location_address': address,
  //     //   'location_city': city,
  //     //   'location_district': district,
  //     //   'location_taluka': taluka,
  //     //   'location_state': state,
  //     //   'location_country': country,
  //     //   'punch_in_out_flag': punchInOutFlag,
  //     //   'gps_flag': gpsFlag,
  //     // };
  //
  //     final response = await ErpDio.getDioClient().post(
  //       'Add_Attendance',
  //       data: formData,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //
  //     if (kDebugMode) {
  //       print(response.realUri);
  //     }
  //     if (response.statusCode == 200) {
  //       ErpAttendanceModel model = ErpAttendanceModel.fromJson(
  //         response.data ?? {},
  //       );
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<GetTodayInOutTimeModel> getTodayInOutApiImplementor() async {
  //   try {
  //     var body = ErpDio.commonBodyMap();
  //     int usrID = LoginUserDetail.erpUser.value.id;
  //     int compID = LoginUserDetail.erpUser.value.compId;
  //     body.addAll({'user_id': '$usrID', 'comp_id': "$compID"});
  //     final response = await ErpDio.clientGet(
  //       'Get_Today_in_out_time',
  //       body: body,
  //     );
  //
  //     var temp = ListTodayInOutTimeModel.fromJson(response ?? {});
  //     // var punchInData = ErpDio.isListAndNotEmpty(response)
  //     //     .map((e) => GetTodayInOutTimeModel.fromJson(e))
  //     //     .toList();
  //
  //     return temp.punchHistory.isNotEmpty
  //         ? temp.punchHistory.first
  //         : GetTodayInOutTimeModel.fromJson({});
  //   } catch (error) {
  //     //print(error.toString());
  //     rethrow;
  //   }
  // }
  //
  // ///=======================================================================
  //
  // static Future<GetAllDistributorModel> getDistributorList() async {
  //   try {
  //     var body = ErpDio.commonBodyMap();
  //     int usrID = LoginUserDetail.erpUser.value.id;
  //     int compID = LoginUserDetail.erpUser.value.compId;
  //     body.addAll({'user_id': '$usrID', 'comp_id': '$compID'});
  //     final response = await ErpDio.getDioClient().get(
  //       'get_customer_list',
  //       queryParameters: body,
  //     );
  //
  //     logUrl(response.realUri);
  //
  //     if (response.statusCode == 200) {
  //       GetAllDistributorModel getAllDistributorModel =
  //           GetAllDistributorModel.fromJson(response.data);
  //       return getAllDistributorModel;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<VendorListModel> getVendorListApiImplementor() async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     int usrID = LoginUserDetail.erpUser.value.id;
  //     body.addAll({'user_id': '$usrID'});
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'get_vendor_list',
  //       queryParameters: body,
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       VendorListModel vendorListModel = VendorListModel.fromJson(
  //         response.data,
  //       );
  //       return vendorListModel;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  // // Todo : insert payment detail
  //
  // static Future<InsertPaymentDetailModel> insertPaymentDetailApiCall({
  //   required int cusId,
  //   required String date,
  //   required String amount,
  //   required String remarks,
  //   required String paymentMode,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //
  //     int usrID = LoginUserDetail.erpUser.value.id;
  //     int compID = LoginUserDetail.erpUser.value.compId;
  //     body.addAll({
  //       'user_id': '$usrID',
  //       'comp_id': '$compID',
  //       'cus_id': '$cusId',
  //       'payment_date': date,
  //       'amount': amount,
  //       'payment_mode': paymentMode,
  //       'remarks': remarks,
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().post(
  //       'Insert_Payment_Details',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       InsertPaymentDetailModel model = InsertPaymentDetailModel.fromJson(
  //         response.data,
  //       );
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // // Todo : purchase order in (item list)
  // static Future<GetAllItemModel> getItemListApiImplementor() async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       "Item_name": "%",
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Item_Name',
  //       queryParameters: body,
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetAllItemModel getAllItemModel = GetAllItemModel.fromJson(
  //         response.data,
  //       );
  //       return getAllItemModel;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // // Todo : purchase order in (item  Wise Umo)
  // static Future<GetItemWiseUmoModel> getItemWiseUmoApiImplementor({
  //   required int itemId,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       "item_id": "$itemId",
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Item_Name_Wise_UoM',
  //       queryParameters: body,
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetItemWiseUmoModel getItemWiseUmoModel = GetItemWiseUmoModel.fromJson(
  //         response.data,
  //       );
  //       return getItemWiseUmoModel;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // // Todo :  insert purchase order Api
  // static Future<InsertPaymentDetailModel> insertPurchaseOrderApiCall({
  //   required String date,
  //   required String itemJson,
  //   required String remarks,
  //   required String venId,
  // }) async {
  //   try {
  //     var formData = FormData.fromMap({
  //       ...ErpDio.commonBodyMap(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'PO_date': date,
  //       'item_detail_json': itemJson,
  //       'ven_id': venId,
  //       'remarks': remarks,
  //     });
  //     logBody(formData);
  //     final response = await ErpDio.getDioClient().post(
  //       data: formData,
  //       'Insert_Purchase_Order',
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       InsertPaymentDetailModel model = InsertPaymentDetailModel.fromJson(
  //         response.data,
  //       );
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // /// Feedback Form
  // static Future<InsertRoutWiseFeedBackModel> insertRoutWiseFeedBackApi({
  //   required String retailerName,
  //   required String shopNAme,
  //   required String mobNo,
  //   required String areaName,
  //   required String villageName,
  //   required String city,
  //   required String distNAme,
  //   required String feedBack,
  //   required File attachment,
  // }) async {
  //   try {
  //     var body = FormData.fromMap({
  //       ...ErpDio.commonBodyMap(),
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'retailer_name': retailerName,
  //       'shop_name': shopNAme,
  //       'mobile_no': mobNo,
  //       'area_name': areaName,
  //       'village_name': villageName,
  //       'city_name': city,
  //       'district_name': distNAme,
  //       'Feedback': feedBack,
  //       "file": await MultipartFile.fromFile(
  //         attachment.path,
  //         filename: attachment.path.split('/').last,
  //       ),
  //     });
  //     logBody(body.fields);
  //     logBody(body.files);
  //     final response = await ErpDio.getDioClient().post(
  //       'Insert_RoutWise_FeedBack',
  //       data: body,
  //     );
  //     if (response.statusCode == 200) {
  //       logResponse(response.data);
  //       var jsonData = jsonDecode(response.data) as List;
  //       var versionList =
  //           jsonData
  //               .map((e) => InsertRoutWiseFeedBackModel.fromJson(e))
  //               .toList();
  //       return versionList.first;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  //
  // static Future<CheckInOutModel> insertCheckInOutApi({
  //   required String cimName,
  //   required String purpose,
  //   required String personName,
  //   required String number,
  //   required String checkInDate,
  //   required String checkInTime,
  //   required String checkOutDate,
  //   required String checkOutTime,
  //   required String result,
  //   required String alternatePerson,
  //   required String checkInLatitude,
  //   required String checkInLongitude,
  //   required String checkOutLatitude,
  //   required String checkOutLongitude,
  //   required String checkInAddress,
  //   required String checkOutAddress,
  //   required String id,
  //   required int isManual,
  // }) async {
  //   try {
  //     Map<String, String> body = {
  //       "app_version": "${LoginUserDetail.appVersion.value}",
  //       "android_id": LoginUserDetail.deviceId.value,
  //       "device_id": "0",
  //       "key": ApiUrls.apiKey,
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'cim_name': cimName,
  //       'purpose': purpose,
  //       'person_name': personName,
  //       'contact_no': number,
  //       'check_in_date': checkInDate,
  //       'check_in_time': checkInTime,
  //       'check_out_date': checkOutDate,
  //       'check_out_time': checkOutTime,
  //       'result': result,
  //       'alternate_person': alternatePerson,
  //       'check_in_address': checkInAddress,
  //       'check_out_address': checkOutAddress,
  //       'check_in_latitude': checkInLatitude,
  //       'check_in_longitude': checkInLongitude,
  //       'check_out_latitude': checkOutLatitude,
  //       'check_out_longitude': checkOutLongitude,
  //       'id': id,
  //       'is_manual_cust': "$isManual",
  //     };
  //     // print("1930 body=> $body");
  //     final response = await ErpDio.getDioClient().post(
  //       'insert_check_in_out',
  //       data: FormData.fromMap(body),
  //     );
  //     return CheckInOutModel.fromJson(response.data);
  //   } catch (error) {
  //     return CheckInOutModel(
  //       mESSAGE: "Internal Server Error During Fetch Customer",
  //     );
  //   }
  // }
  //
  // static Future<CheckInOutByUser> getCheckInOutByUserIdListApi() async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //     });
  //     final response = await ErpDio.clientGet(
  //       'get_check_in_out_by_user_id',
  //       body: body,
  //     );
  //     return CheckInOutByUser.fromJson(response ?? {});
  //   } catch (error) {
  //     // print("EEE=> $error");
  //     return CheckInOutByUser(
  //       message: "Internal Server Error During Fetch Customer",
  //     );
  //   }
  // }
  //
  // static Future<DyamicPageBuildTabModel> getDashboardAllTabApiCall() async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_DashBoard_AllTab',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       DyamicPageBuildTabModel model = DyamicPageBuildTabModel.fromJson(
  //         response.data,
  //       );
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     // print(error);
  //     rethrow;
  //   }
  // }
  //
  // static Future<StaticDetailActiveIndexModel> getSalesStatisticsApiCall({
  //   required String activeTabIndex,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       'user_id': LoginUserDetail.erpUser.value.id.toString(),
  //       'comp_id': LoginUserDetail.erpUser.value.compId.toString(),
  //       'Active_TabIndex': activeTabIndex,
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Sales_Statistics',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       StaticDetailActiveIndexModel model =
  //           StaticDetailActiveIndexModel.fromJson(response.data);
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     // print(error);
  //     rethrow;
  //   }
  // }
  //
  // static Future<ReportDetailListModel> getStatisticsDetailApiCall({
  //   required String fromDate,
  //   required String toDate,
  //   required String moduleId,
  //   required String reportId,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       "user_id": "${LoginUserDetail.erpUser.value.id}",
  //       "comp_id": "${LoginUserDetail.erpUser.value.compId}",
  //       "fdt": fromDate,
  //       "tdt": toDate,
  //       "module_id": moduleId,
  //       "report_id": reportId,
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'get_statastic_detail',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       ReportDetailListModel model = ReportDetailListModel.fromJson(
  //         response.data,
  //       );
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<GetDataPaymentDetailModel> getPaymentDetailGridDataApiCall({
  //   required String fromDate,
  //   required String toDate,
  //   required int cusId,
  // }) async {
  //   try {
  //     Map<String, String> body = ErpDio.commonBodyMap();
  //     body.addAll({
  //       "user_id": "${LoginUserDetail.erpUser.value.id}",
  //       "comp_id": "${LoginUserDetail.erpUser.value.compId}",
  //       "fromdate": fromDate,
  //       "todate": toDate,
  //       "cust_id": cusId.toString(),
  //     });
  //     logBody(body);
  //     final response = await ErpDio.getDioClient().get(
  //       'Get_Data_Payment_Details',
  //       queryParameters: body,
  //       options: Options(headers: {'content-type': 'application/json'}),
  //     );
  //     logUrl(response.realUri);
  //     logResponse(response.data);
  //     if (response.statusCode == 200) {
  //       GetDataPaymentDetailModel model = GetDataPaymentDetailModel.fromJson(
  //         response.data,
  //       );
  //       return model;
  //     } else {
  //       throw HandleException(exceptionMsg: response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<InsertGpsTrackingDetailResponse>
  // insertGpsTrackingDetailApiImplementor({
  //   required String batteryStatus,
  //   required String gpsStatus,
  //   required String latitude,
  //   required String longitude,
  //   required String datetime,
  //   required String network,
  //   required String address,
  //   required String hREmployeeId,
  //   required String hRUserMId,
  //   required String ipAddress,
  // }) async {
  //   try {
  //     final response = await HrDio.getDioClient().get(
  //       'insert_employee_gps_tracking_detail',
  //       queryParameters: {
  //         "emp_id": hREmployeeId,
  //         "battery_status": batteryStatus,
  //         "gps_status": gpsStatus,
  //         "lat": latitude,
  //         "longs": longitude,
  //         "address": address,
  //         "datetime": datetime,
  //         "network": network,
  //         "created_by": hRUserMId,
  //         "created_ip": ipAddress,
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       var jsonData =
  //           HrDio.isListAndNotEmpty(
  //             response.data,
  //           ).map((e) => InsertGpsTrackingDetailResponse.fromJson(e)).toList();
  //       return jsonData.isNotEmpty
  //           ? jsonData.first
  //           : InsertGpsTrackingDetailResponse();
  //     } else {
  //       throw Exception(response.statusMessage.toString());
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<List<EmployeeTadaRequestModel>>
  // getEmployeeTadaRequestApiImplementor() async {
  //   try {
  //     final response = await HrDio.getDioClient().get(
  //       'Get_hrhr_Employee_TADA_Request_Mst_Select',
  //       queryParameters: {
  //         'comp_id': '${LoginUserDetail.erpUser.value.compId}',
  //         'user_id': '${LoginUserDetail.hrUser.value.usrId}',
  //       },
  //     );
  //
  //     // commonDebugLogger(response.realUri);
  //
  //     //commonDebugLogger(response.data);
  //     if (response.statusCode == 200) {
  //       var jsonData = response.data as List;
  //       var transportType = jsonData
  //           .map((e) => EmployeeTadaRequestModel.fromJson(e))
  //           .toList();
  //
  //       return transportType;
  //     } else {
  //       throw Exception(response.statusMessage.toString(),
  //       );
  //     }
  //   } catch (error) {
  //     //commonDebugLogger(error.toString());
  //     rethrow;
  //   }
  // }
  //
  // static Future<List<EmployeeTadaDetailModel>>
  // getEmployeeTadaDetailsApiImplementor({required int id}) async {
  //   try {
  //     final response = await HrDio.getDioClient().get(
  //       'Get_hrhr_Employee_TADA_Request_Mst_SelectById',
  //       queryParameters: {
  //         'comp_id': '${LoginUserDetail.erpUser.value.compId}',
  //         'id': '$id',
  //       },
  //     );
  //
  //     // commonDebugLogger(response.realUri);
  //
  //     //commonDebugLogger(response.data);
  //     if (response.statusCode == 200) {
  //       var jsonData = response.data as List;
  //       var transportType = jsonData
  //           .map((e) => EmployeeTadaDetailModel.fromJson(e))
  //           .toList();
  //
  //       return transportType;
  //     } else {
  //       throw Exception(response.statusMessage.toString(),
  //       );
  //     }
  //   } catch (error) {
  //     //commonDebugLogger(error.toString());
  //     rethrow;
  //   }
  // }
  //
  // static Future<List<DeleteTadaRequestModel>> deleteTadaRequestApiImplementor({
  //   required int id,
  // }) async {
  //   try {
  //     String appIP = await LoginUserDetail.ipAddress();
  //     final response = await HrDio.getDioClient().get(
  //       'Delete_Employee_TADA_Request_Mst',
  //       queryParameters: {
  //         'comp_id': '${LoginUserDetail.erpUser.value.compId}',
  //         'userid': '${LoginUserDetail.hrUser.value.usrId}',
  //         'id': '$id',
  //         'ip': appIP,
  //       },
  //     );
  //
  //     // commonDebugLogger(response.realUri);
  //
  //     //commonDebugLogger(response.data);
  //     if (response.statusCode == 200) {
  //       var jsonData = response.data as List;
  //       var transportType = jsonData
  //           .map((e) => DeleteTadaRequestModel.fromJson(e))
  //           .toList();
  //
  //       return transportType;
  //     } else {
  //       throw Exception(response.statusMessage.toString(),
  //       );
  //     }
  //   } catch (error) {
  //     //commonDebugLogger(error.toString());
  //     rethrow;
  //   }
  // }
  //
  // static Future<InsertTadaRequestModel> insertTadaRequestApiImplementor({
  //   required String etrmDate,
  //   required String departureCity,
  //   required String arrivalCity,
  //   required String departureTime,
  //   required String arrivalTime,
  //   required int modeOfTransport,
  //   required String etrmKm,
  //   required String rateOFKm,
  //   required String kmAmount,
  //   required String fareValue,
  //   required String hotelValue,
  //   required String breakfastValue,
  //   required String lunchValue,
  //   required String dinnerValue,
  //   required String laundryValue,
  //   required String waterBottleValue,
  //   required String paidForCompanyValue,
  //   required String expenseParticularValue,
  //   required String expenseCostValue,
  //   required String hotelDoc,
  //   required String breakfastDoc,
  //   required String lunchDoc,
  //   required String dinnerDoc,
  //   required String paidForCompanyDoc,
  //   required String mapKm,
  //   required String totalAmount,
  // }) async {
  //   try {
  //     String appIP = await LoginUserDetail.ipAddress();
  //     final response = await HrDio.getDioClient().get(
  //       'Employee_TADA_Request_Mst_Insert',
  //       queryParameters: {
  //         'comp_id': '${LoginUserDetail.erpUser.value.compId}',
  //         'emp_id': '${LoginUserDetail.hrUser.value.hrEmpId}',
  //         'etrm_date': etrmDate,
  //         'etrm_from': departureCity,
  //         'etrm_to': arrivalCity,
  //         'etrm_departure_time': departureTime,
  //         'etrm_arrival_time': arrivalTime,
  //         'etrm_mode_of_transport': modeOfTransport,
  //         'etrm_KM': etrmKm,
  //         'etrm_rate_for_km': rateOFKm,
  //         'etrm_km_amoun': kmAmount,
  //         'etrm_fare': fareValue,
  //         'etrm_hotel': hotelValue,
  //         'etrm_breakfast': breakfastValue,
  //         'etrm_lunch': lunchValue,
  //         'etrm_dinner': dinnerValue,
  //         'etrm_laundry': laundryValue,
  //         'etrm_water_bottle': waterBottleValue,
  //         'etrm_paid_for_company': paidForCompanyValue,
  //         'etrm_other_expense_perticular': expenseParticularValue,
  //         'etrm_other_expense_cost_remarks': expenseCostValue,
  //         'etrm_hotel_doc': hotelDoc,
  //         'etrm_breakfast_doc': breakfastDoc,
  //         'etrm_lunch_doc': lunchDoc,
  //         'etrm_dinner_doc': dinnerDoc,
  //         'etrm_paid_for_company_doc': paidForCompanyDoc,
  //         'etrm_map_KM': mapKm,
  //         'etrm_total_amount': totalAmount,
  //         'create_by': '${LoginUserDetail.hrUser.value.usrId}',
  //         'create_ip': appIP,
  //       },
  //     );
  //
  //     // commonDebugLogger(response.realUri);
  //
  //     //commonDebugLogger(response.data);
  //     if (response.statusCode == 200) {
  //       InsertTadaRequestModel model = InsertTadaRequestModel.fromJson(
  //         response.data,
  //       );
  //       return model;
  //     } else {
  //       throw Exception(response.statusMessage.toString(),
  //       );
  //     }
  //   } catch (error) {
  //     // commonDebugLogger(error.toString());
  //     rethrow;
  //   }
  // }
  //
  // static Future<InsertTadaRequestModel> updateTadaRequestApiImplementor({
  //   required String etrmDate,
  //   required String departureCity,
  //   required String arrivalCity,
  //   required String departureTime,
  //   required String arrivalTime,
  //   required int modeOfTransport,
  //   required String etrmKm,
  //   required String rateOFKm,
  //   required String kmAmount,
  //   required String fareValue,
  //   required String hotelValue,
  //   required String breakfastValue,
  //   required String lunchValue,
  //   required String dinnerValue,
  //   required String laundryValue,
  //   required String waterBottleValue,
  //   required String paidForCompanyValue,
  //   required String expenseParticularValue,
  //   required String expenseCostValue,
  //   required String hotelDoc,
  //   required String breakfastDoc,
  //   required String lunchDoc,
  //   required String dinnerDoc,
  //   required String paidForCompanyDoc,
  //   required String mapKm,
  //   required String totalAmount,
  //   required int id,
  // }) async {
  //   try {
  //     String appIP = await LoginUserDetail.ipAddress();
  //     final response = await HrDio.getDioClient().get(
  //       'Employee_TADA_Request_Mst_Update',
  //       queryParameters: {
  //         'id': id,
  //         'comp_id': '${LoginUserDetail.erpUser.value.compId}',
  //         'emp_id': '${LoginUserDetail.hrUser.value.hrEmpId}',
  //         'etrm_date': etrmDate,
  //         'etrm_from': departureCity,
  //         'etrm_to': arrivalCity,
  //         'etrm_departure_time': departureTime,
  //         'etrm_arrival_time': arrivalTime,
  //         'etrm_mode_of_transport': modeOfTransport,
  //         'etrm_KM': etrmKm,
  //         'etrm_rate_for_km': rateOFKm,
  //         'etrm_km_amoun': kmAmount,
  //         'etrm_fare': fareValue,
  //         'etrm_hotel': hotelValue,
  //         'etrm_breakfast': breakfastValue,
  //         'etrm_lunch': lunchValue,
  //         'etrm_dinner': dinnerValue,
  //         'etrm_laundry': lunchValue,
  //         'etrm_water_bottle': waterBottleValue,
  //         'etrm_paid_for_company': paidForCompanyValue,
  //         'etrm_other_expense_perticular': expenseParticularValue,
  //         'etrm_other_expense_cost_remarks': expenseCostValue,
  //         'etrm_hotel_doc': hotelDoc,
  //         'etrm_breakfast_doc': breakfastDoc,
  //         'etrm_lunch_doc': lunchDoc,
  //         'etrm_dinner_doc': dinnerDoc,
  //         'etrm_paid_for_company_doc': paidForCompanyDoc,
  //         'etrm_map_KM': mapKm,
  //         'etrm_total_amount': totalAmount,
  //         'modify_by': '${LoginUserDetail.hrUser.value.usrId}',
  //         'modify_ip': appIP,
  //       },
  //     );
  //
  //     // commonDebugLogger(response.realUri);
  //
  //     //commonDebugLogger(response.data);
  //     if (response.statusCode == 200) {
  //       InsertTadaRequestModel model = InsertTadaRequestModel.fromJson(
  //         response.data,
  //       );
  //       return model;
  //     } else {
  //       throw Exception(response.statusMessage.toString(),
  //       );
  //     }
  //   } catch (error) {
  //     // commonDebugLogger(error.toString());
  //     rethrow;
  //   }
  // }
  //
  // static Future<DocumentUploadTadaModel> commonDocumentUploadApiImplementer({
  //   required String folderName,
  //   required String documentPath,
  //   required int tadaId,
  // }) async {
  //   try {
  //     var data = FormData.fromMap({
  //       "file_byte_string": documentPath.isNotEmpty
  //           ? await MultipartFile.fromFile(documentPath)
  //           : "",
  //     });
  //     final response = await SwaggerDioClient.dioClient().post(
  //       queryParameters: {
  //         'comp_id': '${LoginUserDetail.erpUser.value.compId}',
  //         'tada_id': tadaId,
  //         'document_type': folderName,
  //       },
  //       'Employee_TADA_Request_Mst_Document_Detail',
  //       data: data,
  //     );
  //     if (response.statusCode == 200) {
  //       return DocumentUploadTadaModel.fromJson(jsonDecode(response.data));
  //     } else {
  //       throw DioException(
  //         requestOptions: response.requestOptions,
  //         response: response,
  //         type: DioExceptionType.badResponse,
  //       );
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  //
  // static Future<List<TransportTypeModel>>
  // getTransportTypeApiImplementor() async {
  //   try {
  //     final response = await HrDio.getDioClient().get(
  //       'Get_Mode_Of_Transport_By_TADA',
  //       queryParameters: {
  //         'comp_id': '${LoginUserDetail.erpUser.value.compId}',
  //         'user_id': '${LoginUserDetail.hrUser.value.usrId}',
  //       },
  //     );
  //
  //     // commonDebugLogger(response.realUri);
  //
  //     //commonDebugLogger(response.data);
  //     if (response.statusCode == 200) {
  //       var jsonData = response.data as List;
  //       var transportType = jsonData
  //           .map((e) => TransportTypeModel.fromJson(e))
  //           .toList();
  //
  //       return transportType;
  //     } else {
  //       throw Exception(response.statusMessage.toString(),
  //       );
  //     }
  //   } catch (error) {
  //     //commonDebugLogger(error.toString());
  //     rethrow;
  //   }
  // }
  //
  // static Future<List<TadaLimitDetailModel>> getTadaLimitDetailApiImplementor({
  //   required String date,
  // }) async {
  //   try {
  //     final response = await HrDio.getDioClient().get(
  //       'Get_hrhr_TADA_Limit_For_Employee_Detail_SelectById',
  //       queryParameters: {
  //         'comp_id': '${LoginUserDetail.erpUser.value.compId}',
  //         'id': '${LoginUserDetail.hrUser.value.usrId}',
  //         'emp_id': '${LoginUserDetail.hrUser.value.hrEmpId}',
  //         'date': date,
  //       },
  //     );
  //
  //     // commonDebugLogger(response.realUri);
  //
  //     //commonDebugLogger(response.data);
  //     if (response.statusCode == 200) {
  //       var jsonData = response.data as List;
  //       var transportType = jsonData
  //           .map((e) => TadaLimitDetailModel.fromJson(e))
  //           .toList();
  //
  //       return transportType;
  //     } else {
  //       throw Exception(
  //         response.statusMessage.toString(),
  //       );
  //     }
  //   } catch (error) {
  //     //commonDebugLogger(error.toString());
  //     rethrow;
  //   }
  // }
}
