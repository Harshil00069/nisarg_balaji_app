import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';

class PrimaryTitleTextWidget extends StatelessWidget {
  const PrimaryTitleTextWidget(
      {super.key,
      required this.title,
      this.underLineRequired = false,
      this.textColor,
      this.textAlign,
      this.fontSize,
      this.fontWeight});
  final String title;
  final TextAlign? textAlign;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool underLineRequired;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        textAlign: textAlign,
        style: TextStyle(
            color: textColor ?? AppColors.darkText,
            fontSize: fontSize ?? 16,
            fontWeight: fontWeight ?? FontWeight.w500,
            decorationStyle: TextDecorationStyle.solid,
            decoration: underLineRequired
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationThickness: underLineRequired ? 4 : null));
  }
}
