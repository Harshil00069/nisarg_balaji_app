import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/helper/api_service.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/base_response.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/camera_view.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/extract_face_features.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/face_features.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({super.key});

  @override
  State<FaceRegistrationScreen> createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  final FaceDetector _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
          enableLandmarks: true, performanceMode: FaceDetectorMode.accurate));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Face Register',
              style: TextStyle(fontWeight: FontWeight.w500)),
          backgroundColor: AppColors.appBar,
          elevation: 4,
          centerTitle: true),
      body: Center(
        child: CameraView(
          onImage: (image) {
            debugPrint('onImage: ${image.toString()}');
          },
          onInputImage: (InputImage inputImage, Uint8List imageBytes) async {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()));
            await extractFaceFeatures(inputImage, _faceDetector)
                .then((FaceFeatures? faceFeatures) async {
              debugPrint('faceFeatures: ${faceFeatures?.toJson().toString()}');
              debugPrint(
                  'faceFeatures2: ${jsonEncode(faceFeatures?.toJson())}');

              if (faceFeatures != null) {
                // make method for api call
                debugPrint('success called');

                final Map<String, dynamic>? arguments = ModalRoute.of(context)
                    ?.settings
                    .arguments as Map<String, dynamic>?;
                final String? employeeId = arguments?['employeeCode'];
                final int? companyId = arguments?['companyId'];
                BaseResponse? result = await ApiService()
                    .getFaceRegisterApi(companyId, employeeId, faceFeatures);

                Fluttertoast.showToast(
                    msg: result?.message ?? '',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1);

                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } else {
                Fluttertoast.showToast(
                    msg: "No face detected",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: AppColors.error);

                // Fail API call
                Navigator.of(context).pop();
              }
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}
