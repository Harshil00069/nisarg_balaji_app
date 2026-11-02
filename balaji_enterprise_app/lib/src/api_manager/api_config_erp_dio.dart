
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_logger_interceptor.dart';
import 'api_url.dart';
import 'api_user_read_error_handler.dart';

class ErpDio {
  // static Dio getDioClient({int delay = 20000}) {
  //   return Dio(
  //     BaseOptions(
  //       baseUrl: ApiUrls.erpBaseUrl,
  //       connectTimeout: Duration(milliseconds: delay),
  //       receiveTimeout: Duration(milliseconds: delay),
  //     ),
  //   );
  // }

  static Dio getDioClient({int delay = 20000}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiUrls.erpBaseUrl,
        connectTimeout: Duration(milliseconds: delay),
        receiveTimeout: Duration(milliseconds: delay),
      ),
    );

    dio.interceptors.add(ApiLoggerInterceptor());

    return dio;
  }

  // static Map<String, String> commonBodyMap() {
  //   Map<String, String> body = {
  //     "app_version": "${LoginUserDetail.appVersion.value}",
  //     "android_id": LoginUserDetail.deviceId.value,
  //     "device_id": "0",
  //     "key": ApiUrls.apiKey,
  //   };
  //   return body;
  // }

  static Future<dynamic> clientPost(
    String apiName, {
    required Map<String, String> body,
    int delayTime = 20000,
    bool passInQuery = true,
  }) async {
    if (kDebugMode) {
      print("IM From Post Method : $apiName Pass Body $body");
    }

    try {
      final response = await getDioClient(delay: delayTime)
          .post(
            apiName,
            data: passInQuery ? null : body,
            queryParameters: passInQuery ? body : null,
            options: Options(
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            ),
          )
          .catchError((e) {
            if (kDebugMode) {
              print("$e");
            }
            if (e is DioException) {
              throw HandleException().handleDioError(e: e);
            } else {
              throw HandleException(exceptionMsg: "Something Went Wrong");
            }
          });
      if (kDebugMode) {
        print(response.realUri);
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Response  ${response.data}");
        }
        return response.data;
      } else {
        if (kDebugMode) {
          print(response.statusMessage.toString());
        }
        throw HandleException(exceptionMsg: response.statusMessage ?? "");
      }
    } catch (error) {
      if (kDebugMode) {
        print("$error");
      }
      rethrow;
    }
  }

  static Future clientGet(
    String apiName, {
    required Map<String, String> body,
    int delayTime = 20000,
    bool passInQuery = true,
    bool isFormData = false,
  }) async {
    if (kDebugMode) {
      print("IM From GET Method : $apiName Pass Body $body");
    }

    try {
      final response = await getDioClient(delay: delayTime)
          .get(
            apiName,
            data: passInQuery ? null : body,
            queryParameters: passInQuery ? body : null,
            options: Options(headers: {'content-type': 'text/plain'}),
          )
          .catchError((e) {
            if (kDebugMode) {
              print("$e");
            }
            if (e is DioException) {
              throw HandleException().handleDioError(e: e);
            } else {
              throw HandleException(exceptionMsg: "Something Went Wrong");
            }
          });
      if (kDebugMode) {
        print(response.realUri);
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.data);
        }
        return response.data;
      } else {
        if (kDebugMode) {
          print(response.statusMessage.toString());
        }
        throw HandleException(exceptionMsg: response.statusMessage ?? "");
      }
    } catch (error) {
      if (kDebugMode) {
        print("$error");
      }
      rethrow;
    }
  }

  static List isListAndNotEmpty(dynamic data) {
    return data != null
        ? data is List
            ? data.isNotEmpty
                ? data
                : []
            : []
        : [];
  }
}
