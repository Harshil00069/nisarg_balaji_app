// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/camera_view.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/extract_face_features.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/face_features.dart';
// import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';
// import 'package:flutter_face_detection_balaji_enterprise/utils/app_constants.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class FaceRegistrationScreen extends StatefulWidget {
//   const FaceRegistrationScreen({super.key});
//
//   @override
//   State<FaceRegistrationScreen> createState() => _FaceRegistrationScreenState();
// }
//
// class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
//   final FaceDetector _faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//           enableLandmarks: true, performanceMode: FaceDetectorMode.accurate));
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Text('Face Register',
//               style: TextStyle(fontWeight: FontWeight.w500)),
//           backgroundColor: AppColors.appBar,
//           elevation: 4,
//           centerTitle: true),
//       body: Center(
//         child: CameraView(
//           onImage: (image) {
//             debugPrint('onImage: ${image.toString()}');
//           },
//           onInputImage: (InputImage inputImage, Uint8List imageBytes) async {
//             showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (context) =>
//                     const Center(child: CircularProgressIndicator()));
//             await extractFaceFeatures(inputImage, _faceDetector)
//                 .then((FaceFeatures? faceFeatures) async {
//               debugPrint('faceFeatures: ${faceFeatures?.toJson().toString()}');
//               debugPrint('faceFeatures2: ${jsonEncode(faceFeatures?.toJson())}');
//
//               if (faceFeatures != null) {
//                 await storeFaceFeatures(faceFeatures);
//                 await saveUint8List(imageBytes);
//               }
//
//               Navigator.of(context).pop();
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   Future<void> storeFaceFeatures(FaceFeatures faceFeatures) async {
//     final prefs = await SharedPreferences.getInstance();
//     final faceFeaturesJson = jsonEncode(faceFeatures.toJson());
//     await prefs.setString(AppConstants.prefsFaceFeatures, faceFeaturesJson);
//   }
//
//   /// Save Uint8List to Shared Preferences
//   static Future<void> saveUint8List(Uint8List image) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Convert Uint8List to base64 String
//     String base64Data = base64Encode(image);
//     await prefs.setString(AppConstants.prefsImage, base64Data);
//   }
//
//   @override
//   void dispose() {
//     _faceDetector.close();
//     super.dispose();
//   }
// }
