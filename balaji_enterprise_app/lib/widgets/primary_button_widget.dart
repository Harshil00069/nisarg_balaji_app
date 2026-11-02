import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';

class PrimaryButtonWidget extends StatelessWidget {
  const PrimaryButtonWidget(
      {super.key, required this.title, required this.onTap, this.buttonColor});

  final String title;
  final VoidCallback onTap;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            elevation: 8,
            backgroundColor: buttonColor ?? AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        child: Text(title, style: const TextStyle(color: AppColors.white)));
  }
}
