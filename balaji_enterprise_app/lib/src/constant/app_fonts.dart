import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppFonts {
  AppFonts._();

  static TextStyle title2({Color color = Colors.white, double? letterSpace}) =>
      TextStyle(
        fontSize: Get.width * 0.06,
        color: color,
        fontWeight: FontWeight.w600,
        letterSpacing: letterSpace ?? 0.3,
      );

  static TextStyle subTitle1({
    Color color = Colors.white,
    double? letterSpace,
  }) => TextStyle(
    fontSize:
        Get.width <= 550
            ? Get.width * 0.045
            : Get.width <= 770
            ? Get.width * 0.03
            : Get.width * 0.025,
    color: color,
    fontWeight: FontWeight.w600,
    letterSpacing: letterSpace ?? 0.4,
  );

  static TextStyle subTitle2({
    Color color = Colors.white,
    double? letterSpace,
  }) => TextStyle(
    fontSize:
        Get.width <= 550
            ? Get.width * 0.05
            : Get.width <= 770
            ? Get.width * 0.03
            : Get.width * 0.025,
    color: color,
    letterSpacing: letterSpace ?? 0.3,
  );

  static TextStyle bodyText1({
    Color color = Colors.white,
    double? letterSpace,
  }) => TextStyle(
    fontSize:
        Get.width <= 550
            ? Get.width * 0.04
            : Get.width <= 450
            ? Get.width * 0.025
            : Get.width * 0.022,
    color: color,
    fontWeight: FontWeight.w600,
    letterSpacing: letterSpace ?? 0.3,
  );

  static TextStyle bodyText2({
    Color color = Colors.white,
    double? letterSpace,
  }) => TextStyle(
    fontSize:
        Get.width <= 550
            ? Get.width * 0.04
            : Get.width <= 450
            ? Get.width * 0.025
            : Get.width * 0.022,
    color: color,
    letterSpacing: letterSpace ?? 0.3,
  );

  static TextStyle bodyText3({
    Color color = Colors.white,
    FontWeight? weight,
    double? height,
    double? letterSpace,
  }) => TextStyle(
    fontSize:
        Get.width <= 550
            ? Get.width * 0.033
            : Get.width <= 450
            ? Get.width * 0.028
            : Get.width * 0.022,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpace ?? 0.4,
  );
  static TextStyle bodyText4({
    Color color = Colors.white,
    FontWeight? weight,
  }) => TextStyle(
    fontSize: Get.width <= 550 ? Get.width * 0.04 : Get.width * 0.025,
    color: color,
    fontWeight: weight,
  );

  static TextStyle label1({Color color = Colors.white, double? letterSpace}) =>
      TextStyle(
        fontSize:
            Get.width <= 550
                ? Get.width * 0.033
                : Get.width <= 450
                ? Get.width * 0.028
                : Get.width * 0.022,
        color: color,
        fontWeight: FontWeight.bold,
        letterSpacing: letterSpace ?? 0.3,
      );

  static TextStyle label2({Color color = Colors.white, double? letterSpace}) =>
      TextStyle(
        fontSize: Get.width <= 550 ? Get.width * 0.033 : Get.width * 0.022,
        color: color,
        letterSpacing: letterSpace ?? 0.2,
      );

  static TextStyle label3({Color color = Colors.white, double? letterSpace}) =>
      TextStyle(
        fontSize: Get.width <= 550 ? Get.width * 0.025 : Get.width * 0.018,
        color: color,
        fontWeight: FontWeight.bold,
        letterSpacing: letterSpace ?? 0.3,
      );

  static TextStyle text({
    Color? color,
    double? size,
    FontWeight? weight,
    double? space,
  }) => TextStyle(
    fontSize:
        size ?? (Get.width <= 550 ? Get.width * 0.035 : Get.width * 0.015),
    color: color ?? Colors.white,
    fontWeight: weight,
    letterSpacing: space,
  );

  static TextStyle systemTxtStyle({
    Color color = Colors.white,
    double stroke = 1.6,
    double? size,
    double? space,
    FontWeight? weight,
  }) => TextStyle(
    fontSize: size ?? Get.width * 0.09,
    fontWeight: weight ?? FontWeight.w600,
    letterSpacing: space ?? 2.5,
    foreground:
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = color,
  );

  static TextStyle appTitle({Color color = Colors.white}) => TextStyle(
    fontSize: Get.width <= 550 ? Get.width * 0.04 : Get.width * 0.022,
    color: color,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}
