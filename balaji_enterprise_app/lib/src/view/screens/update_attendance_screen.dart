import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/helper/api_service.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/base_response.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/models/get_employee_by_facedata_response.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/camera_view.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/extract_face_features.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/face_features.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_constants.dart';
import 'package:flutter_face_detection_balaji_enterprise/widgets/primary_text_input_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateAttendanceScreen extends StatefulWidget {
  const UpdateAttendanceScreen({super.key});

  @override
  State<UpdateAttendanceScreen> createState() => _UpdateAttendanceScreenState();
}

class _UpdateAttendanceScreenState extends State<UpdateAttendanceScreen> {
  final FaceDetector _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
          enableLandmarks: true, performanceMode: FaceDetectorMode.accurate));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Update Attendance',
                style: TextStyle(fontWeight: FontWeight.w500)),
            backgroundColor: AppColors.appBar,
            elevation: 4,
            centerTitle: true),
        body: Center(
            child: CameraView(onImage: (image) {
          debugPrint('onImage: ${image.toString()}');
        }, onInputImage: (InputImage inputImage, Uint8List imageBytes) async {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()));
          await extractFaceFeatures(inputImage, _faceDetector)
              .then((FaceFeatures? faceFeatures) async {
            debugPrint('faceFeatures: ${faceFeatures?.toJson().toString()}');
            debugPrint('faceFeatures2: ${jsonEncode(faceFeatures?.toJson())}');

            if (faceFeatures != null) {
              // make method for api call
              debugPrint("success called");
              Navigator.of(context).pop();
              final Map<String, dynamic>? arguments = ModalRoute.of(context)
                  ?.settings
                  .arguments as Map<String, dynamic>?;
              final int? companyId = arguments?['companyId'];
              debugPrint('companyId: $companyId');
              // Only for testing purpose
              // faceFeatures = FaceFeatures(
              //     rightMouth: Points(x: 184, y: 197),
              //     leftMouth: Points(x: 142, y: 194),
              //     leftCheek: Points(x: 128, y: 177),
              //     rightCheek: Points(x: 205, y: 180),
              //     leftEye: Points(x: 139, y: 141),
              //     rightEar: Points(x: 220, y: 179),
              //     leftEar: Points(x: 104, y: 175),
              //     rightEye: Points(x: 195, y: 143),1
              //     noseBase: Points(x: 169, y: 161),
              //     bottomMouth: Points(x: 165, y: 204));
              // faceFeatures = FaceFeatures(
              //     rightMouth: Points(x: 138, y: 237),
              //     leftMouth: Points(x: 79, y: 238),
              //     leftCheek: Points(x: 57, y: 211),
              //     rightCheek: Points(x: 155, y: 205),
              //     leftEye: Points(x: 68, y: 161),
              //     rightEar: Points(x: 175, y: 173),
              //     leftEar: Points(x: 30, y: 193),
              //     rightEye: Points(x: 138, y: 157),
              //     noseBase: Points(x: 106, y: 200),
              //     bottomMouth: Points(x: 110, y: 251));
              GetEmployeeByFacedataResponse? employeeByFacedataResponse =
                  await ApiService()
                      .getEmployeeByFaceDataApi(companyId, faceFeatures);

              if (employeeByFacedataResponse?.status == 0) {
                showCustomDialog(
                    context, employeeByFacedataResponse, companyId);
              } else {
                Fluttertoast.showToast(
                    msg: employeeByFacedataResponse?.message ?? '',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1);
              }
            } else {
              Fluttertoast.showToast(
                  msg: "No face detected",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: AppColors.error);
            }
          });
        })));
  }

  Future<void> storeFaceFeatures(FaceFeatures faceFeatures) async {
    final prefs = await SharedPreferences.getInstance();
    final faceFeaturesJson = jsonEncode(faceFeatures.toJson());
    await prefs.setString(AppConstants.prefsFaceFeatures, faceFeaturesJson);
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}

void showCustomDialog(BuildContext context,
    GetEmployeeByFacedataResponse? employeeDataResponse, int? companyId) {
  TextEditingController employeeIdController = TextEditingController(
      text: employeeDataResponse?.data?.employeeName ?? '');
  TextEditingController employeeHourController = TextEditingController();
  TextEditingController employeeDateController = TextEditingController();
  DateTime? selectedDate;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime(3000));
    if (pickedDate != null) {
      selectedDate = pickedDate;
      employeeDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Success'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: PrimaryTextInputWidget(
                      textController: employeeIdController,
                      fillColor: AppColors.grey.withValues(alpha: 0.4),
                      enabled: false)),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                      onTap: () {
                        selectDate(context);
                      },
                      child: AbsorbPointer(
                          child: PrimaryTextInputWidget(
                              suffixIcon: const Icon(Icons.calendar_month),
                              textController: employeeDateController,
                              textInputAction: TextInputAction.done,
                              textInputType: TextInputType.datetime,
                              hintText: 'Employee Date Time',
                              fillColor: AppColors.textInputFill)))),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: PrimaryTextInputWidget(
                      textController: employeeHourController,
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.number,
                      hintText: 'Employee Hours',
                      fillColor: AppColors.textInputFill)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                if (employeeDateController.text.trim().isEmpty &&
                    selectedDate != null) {
                  Fluttertoast.showToast(
                      msg: 'Please select attendance date.',
                      backgroundColor: AppColors.error);
                } else if (employeeHourController.text.trim().isEmpty) {
                  Fluttertoast.showToast(
                      msg: 'Please add working hours.',
                      backgroundColor: AppColors.error);
                } else {
                  // Api call
                  BaseResponse? result = await ApiService().updateAttendanceApi(
                      companyId,
                      employeeDataResponse?.data?.employeeId,
                      employeeHourController.text.trim(),
                      selectedDate);

                  Fluttertoast.showToast(msg: result?.message ?? '');

                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK')),
        ],
      );
    },
  );
}
