import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/check_connectivity_screen.dart';
import 'package:get/get.dart';

class HandleException {
  late String exceptionMsg;

  HandleException({
    this.exceptionMsg = 'Something went wrong',
  });

  String handleDioError({required DioException e}) {
    if (e.error is SocketException) {
      return "There is some issue with your internet connection, please try again later!";
    } else if (e.type == DioExceptionType.connectionTimeout) {
      var tmp = Get.find<NetworkController>();
      if (tmp.isConnect.isFalse) {
        exceptionMsg =
            'There is some issue with your internet connection. Please check your internet and try again.';
      }
      exceptionMsg = 'Server Connection Timeout';
      return exceptionMsg;
    } else if (e.type == DioExceptionType.sendTimeout) {
      var tmp = Get.find<NetworkController>();
      if (tmp.isConnect.isFalse) {
        exceptionMsg =
            'There is some issue with your internet connection. Please check your internet and try again.';
      }
      exceptionMsg = 'Connection Timeout,Try Again';
      return exceptionMsg;
    } else if (e.type == DioExceptionType.receiveTimeout) {
      var tmp = Get.find<NetworkController>();
      if (tmp.isConnect.isFalse) {
        exceptionMsg =
            'There is some issue with your internet connection. Please check your internet and try again.';
      }
      exceptionMsg = 'Receive Connection Timeout';
      return exceptionMsg;
    } else if (e.type == DioExceptionType.badResponse) {
      if (e.response != null) {
        exceptionMsg =
            '${e.response!.statusCode} :${e.response?.statusMessage}';
      } else {
        exceptionMsg = 'Internal Server Error Occured';
      }
      return exceptionMsg;
    } else if (e.type == DioExceptionType.cancel) {
      var tmp = Get.find<NetworkController>();
      if (tmp.isConnect.isFalse) {
        exceptionMsg =
            'There is some issue with your internet connection. Please check your internet and try again.';
      }
      exceptionMsg = 'Request Cancelled';
      return exceptionMsg;
    } else {
      if (e.response != null) {
        exceptionMsg =
            '${e.response!.statusCode} :${e.response?.statusMessage}';
      } else {
        exceptionMsg = 'Internal Server Error Occured';
      }
      return exceptionMsg;
    }
  }
}
