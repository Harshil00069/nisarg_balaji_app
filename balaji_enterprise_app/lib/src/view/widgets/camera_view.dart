import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class CameraView extends StatefulWidget {
  const CameraView(
      {super.key, required this.onImage, required this.onInputImage});

  final Function(Uint8List image) onImage;
  final Function(InputImage inputImage, Uint8List image) onInputImage;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final ImagePicker imagePicker = ImagePicker();
  bool isLoading = false;
  File? image;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
                width: double.infinity,
                height: 350,
                decoration:
                    BoxDecoration(color: AppColors.black.withValues(alpha: 0.3)),
                child: image != null
                    ? Image.file(image!, fit: BoxFit.cover)
                    : Center(
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.camera_alt,
                                size: 32, color: Color(0xff2E2E2E))))),
        const SizedBox(height: 16),
        Column(
          children: [
            GestureDetector(
                onTap: () {
                  _getImage();
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.grey.withValues(alpha: 0.3),
                              blurRadius: 5,
                              spreadRadius: 1)
                        ],
                        color: AppColors.white),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt,
                            size: 32, color: Color(0xff2E2E2E)),
                        SizedBox(width: 8),
                        Text('Click here to Capture',
                            style: TextStyle(fontSize: 14)),
                      ],
                    ))),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future _getImage() async {
    setState(() {
      image = null;
      isLoading = true;
    });
    final pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 400, maxHeight: 400);
    if (pickedFile != null) {
      _setPickedFile(pickedFile);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future _setPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      image = File(path);
    });

    Uint8List imageBytes = image!.readAsBytesSync();
    widget.onImage(imageBytes);

    InputImage inputImage = InputImage.fromFilePath(path);
    widget.onInputImage(inputImage, imageBytes);
  }
}
