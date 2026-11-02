import 'package:dio/dio.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/common_utils.dart' show CommonUtils;


class ApiLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final curl = CommonUtils.generateCurl(options);

    CommonUtils.logMessage("-------------- REQUEST -----------");
    CommonUtils.logMessage("URL     : ${options.uri}");
    CommonUtils.logMessage("METHOD  : ${options.method}");
    CommonUtils.logMessage("HEADERS : ${options.headers}");
    CommonUtils.logMessage("QUERY   : ${options.queryParameters}");
    CommonUtils.logMessage("DATA    : ${options.data}");
    CommonUtils.logMessage(
      "------------ cURL (copy & use in Postman) ------------",
    );
    CommonUtils.logMessage(curl);
    CommonUtils.logMessage("-------------- END REQUEST --------------");

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    CommonUtils.logMessage("-------------- RESPONSE --------------");
    CommonUtils.logMessage("URL     : ${response.realUri}");
    CommonUtils.logMessage("STATUS  : ${response.statusCode}");
    CommonUtils.logMessage("DATA    : ${response.data}");
    CommonUtils.logMessage("-------------- END RESPONSE --------------");

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final curl = CommonUtils.generateCurl(err.requestOptions);

    CommonUtils.logErrorMessage("-------------- ERROR --------------");
    CommonUtils.logErrorMessage("URL      : ${err.requestOptions.uri}");
    CommonUtils.logErrorMessage("METHOD   : ${err.requestOptions.method}");
    CommonUtils.logErrorMessage("TYPE     : ${err.type}");
    CommonUtils.logErrorMessage("MESSAGE  : ${err.message}");
    CommonUtils.logErrorMessage("STACKTRACE:");
    CommonUtils.logErrorMessage(err.stackTrace);
    CommonUtils.logErrorMessage(
      "------------ cURL (Error Request) -----------",
    );
    CommonUtils.logErrorMessage(curl);
    CommonUtils.logErrorMessage("-------------- END ERROR --------------");

    return handler.next(err);
  }
}
