import 'package:flutter_face_detection_balaji_enterprise/src/app_module/area_mesurement/screen/area_measure_map_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/screens/face_detector_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/screens/face_registration_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/screens/home_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/screens/login_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/screens/webview_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_routes.dart';
import 'package:get/get.dart';


class AppPages {
  static final screenList = [
    GetPage(
      name: AppRoutes.routeLoginScreen,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.routeHomeScreen,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.routeFaceRegistrationScreen,
      page: () => const FaceRegistrationScreen(),
    ),
    GetPage(
      name: AppRoutes.routeFaceDetectorScreen,
      page: () => const FaceDetectorScreen(),
    ),
    GetPage(
      name: AppRoutes.routeWebViewScreen,
      page: () => const WebViewScreen(),
    ),
    GetPage(
      name: AppRoutes.measureMapScreen,
      page: () =>  MeasureMapScreen(onAreaMeasureDone: (points) {},),
    ),
  ];
}
