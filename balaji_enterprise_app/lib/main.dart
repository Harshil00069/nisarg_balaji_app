import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/background_service/flutter_background_service.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/app_pages.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_routes.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isLogin = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.white,
      statusBarBrightness: Brightness.dark));
  FlutterError.onError = (details) {
    debugPrint(
        'flutter error : ${details.exceptionAsString()} : ${details.stack} : ${details.toString()}');
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  isLogin = prefs.getBool('isLogin') ?? false;

  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          // Preserve original viewInsets (keyboard), padding (system bars)
          data: mediaQuery,
          child: Padding(
            // Only push up bottom widgets (FAB, buttons) when nav bar exists
            padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
            child: child ?? const SizedBox(),
          ),
        );
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true),
      initialRoute: isLogin
          ? AppRoutes.routeHomeScreen
          : AppRoutes.routeLoginScreen,
      getPages: AppPages.screenList,
    );
  }
}
