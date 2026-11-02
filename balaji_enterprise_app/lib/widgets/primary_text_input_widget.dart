import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';

class PrimaryTextInputWidget extends StatefulWidget {
  final TextEditingController textController;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final String? hintText;
  final Color? fillColor;

  const PrimaryTextInputWidget(
      {super.key,
      required this.textController,
      this.inputFormatters,
      this.validator,
      this.suffixIcon,
      this.hintText,
      this.fillColor,
      this.textInputType = TextInputType.text,
      this.textInputAction = TextInputAction.next,
      this.enabled = true,
      this.obscureText = false,
      this.readOnly = false});

  @override
  State<PrimaryTextInputWidget> createState() => _PrimaryTextInputWidgetState();
}

class _PrimaryTextInputWidgetState extends State<PrimaryTextInputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        controller: widget.textController,
        keyboardType: widget.textInputType,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        cursorColor: AppColors.text,
        style: const TextStyle(color: AppColors.text),
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
            fillColor: widget.fillColor ?? AppColors.textInputFill,
            filled: true,
            hintText: widget.hintText,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            suffixIcon: widget.suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.textInputBorder),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.textInputErrorBorder),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.textInputErrorBorder),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.textInputBorder),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.textInputBorder),
                borderRadius: BorderRadius.all(Radius.circular(8)))));
  }
}
