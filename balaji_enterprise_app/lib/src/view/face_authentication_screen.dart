// import 'dart:convert';
// import 'dart:math' as math;
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_face_api/flutter_face_api.dart' as regula;
// import 'package:flutter_face_api/flutter_face_api.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/camera_view.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/extract_face_features.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/face_features.dart';
// import 'package:flutter_face_detection_balaji_enterprise/utils/app_constants.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class FaceAuthenticateScreen extends StatefulWidget {
//   const FaceAuthenticateScreen({super.key});
//
//   @override
//   State<FaceAuthenticateScreen> createState() => _FaceAuthenticateScreenState();
// }
//
// class _FaceAuthenticateScreenState extends State<FaceAuthenticateScreen> {
//   final FaceDetector _faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//           enableLandmarks: true, performanceMode: FaceDetectorMode.accurate));
//   regula.MatchFacesImage? mfImage1;
//   regula.MatchFacesImage? mfImage2;
//   String status = 'nil';
//   String similarityStatus = 'nil';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           centerTitle: true,
//           title: const Text('User Authentication'),
//           elevation: 0),
//       body: CameraView(
//         onImage: (image) {
//           debugPrint('onImage: $image');
//         },
//         onInputImage: (InputImage inputImage, Uint8List imageBytes) async {
//           debugPrint('onInputImage: $inputImage, Uint8List: $imageBytes');
//
//           FaceFeatures? faceFeaturesScanned =
//               await extractFaceFeatures(inputImage, _faceDetector);
//           FaceFeatures? faceFeaturesSaved = await fetchFaceFeatures();
//           Uint8List? imageBytesSaved = await getUint8List();
//
//           double similarity =
//               compareFaces(faceFeaturesScanned!, faceFeaturesSaved!);
//           if (similarity >= 0.8 && similarity <= 1.5) {
//             debugPrint('similarity inside: $similarity');
//             mfImage1 =
//                 regula.MatchFacesImage(imageBytes, regula.ImageType.PRINTED);
//             mfImage2 = regula.MatchFacesImage(
//                 imageBytesSaved!, regula.ImageType.PRINTED);
//
//             matchFaces();
//           } else {
//             debugPrint('similarity outside: $similarity');
//           }
//         },
//       ),
//     );
//   }
//
//   Future<FaceFeatures?> fetchFaceFeatures() async {
//     final prefs = await SharedPreferences.getInstance();
//     final faceFeaturesJson = prefs.getString(AppConstants.prefsFaceFeatures);
//
//     if (faceFeaturesJson != null) {
//       final faceFeaturesMap = jsonDecode(faceFeaturesJson);
//       return FaceFeatures.fromJson(faceFeaturesMap);
//     } else {
//       return null;
//     }
//   }
//
//   /// Fetch Uint8List from Shared Preferences
//   static Future<Uint8List?> getUint8List() async {
//     final prefs = await SharedPreferences.getInstance();
//     // Get base64 String from SharedPreferences
//     String? base64Data = prefs.getString(AppConstants.prefsImage);
//     if (base64Data == null) return null;
//     // Convert base64 String back to Uint8List
//     return base64Decode(base64Data);
//   }
//
//   double compareFaces(FaceFeatures face1, FaceFeatures face2) {
//     double distEar1 = euclideanDistance(face1.rightEar!, face1.leftEar!);
//     double distEar2 = euclideanDistance(face2.rightEar!, face2.leftEar!);
//     double ratioEar = distEar1 / distEar2;
//
//     double distEye1 = euclideanDistance(face1.rightEye!, face1.leftEye!);
//     double distEye2 = euclideanDistance(face2.rightEye!, face2.leftEye!);
//     double ratioEye = distEye1 / distEye2;
//
//     double distCheek1 = euclideanDistance(face1.rightCheek!, face1.leftCheek!);
//     double distCheek2 = euclideanDistance(face2.rightCheek!, face2.leftCheek!);
//     double ratioCheek = distCheek1 / distCheek2;
//
//     double distMouth1 = euclideanDistance(face1.rightMouth!, face1.leftMouth!);
//     double distMouth2 = euclideanDistance(face2.rightMouth!, face2.leftMouth!);
//     double ratioMouth = distMouth1 / distMouth2;
//
//     double distNoseToMouth1 =
//         euclideanDistance(face1.noseBase!, face1.bottomMouth!);
//     double distNoseToMouth2 =
//         euclideanDistance(face2.noseBase!, face2.bottomMouth!);
//     double ratioNoseToMouth = distNoseToMouth1 / distNoseToMouth2;
//
//     double ratio =
//         (ratioEye + ratioEar + ratioCheek + ratioMouth + ratioNoseToMouth) / 5;
//     debugPrint('compareFaces: ${ratio.toString()}');
//
//     return ratio;
//   }
//
//   // A function to calculate the Euclidean distance between two points
//   double euclideanDistance(Points p1, Points p2) {
//     final sqr =
//         math.sqrt(math.pow((p1.x! - p2.x!), 2) + math.pow((p1.y! - p2.y!), 2));
//     return sqr;
//   }
//
//   void matchFaces() async {
//     if (mfImage1 == null || mfImage2 == null) {
//       status = 'Both images required!';
//       return;
//     }
//     status = 'Processing...';
//     MatchFacesRequest request = MatchFacesRequest([mfImage1!, mfImage2!]);
//     MatchFacesResponse response = await FaceSDK.instance.matchFaces(request);
//     ComparedFacesSplit split =
//         await FaceSDK.instance.splitComparedFaces(response.results, 0.75);
//     List<ComparedFacesPair> match = split.matchedFaces;
//     similarityStatus = 'Failed';
//     if (match.isNotEmpty) {
//       similarityStatus = '${(match[0].similarity * 100).toStringAsFixed(2)}%';
//     }
//     status = 'Ready';
//
//     debugPrint('matchFaces: $status : $similarityStatus');
//   }
//
//   @override
//   void dispose() {
//     _faceDetector.close();
//     super.dispose();
//   }
// }
