// import 'dart:convert';
// import 'dart:math' as math;
//
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/detector_view.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/face_detector_painter.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/face_features.dart';
// import 'package:flutter_face_detection_balaji_enterprise/utils/app_constants.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class FaceDetectorScreen extends StatefulWidget {
//   const FaceDetectorScreen({super.key});
//
//   @override
//   State<FaceDetectorScreen> createState() => _FaceDetectorScreenState();
// }
//
// class _FaceDetectorScreenState extends State<FaceDetectorScreen> {
//   final FaceDetector _faceDetector = FaceDetector(options: FaceDetectorOptions(enableContours: true, enableLandmarks: true));
//   CameraLensDirection _cameraLensDirection = CameraLensDirection.front;
//   bool _canProcess = true;
//   bool _isBusy = false;
//   CustomPaint? _customPaint;
//   String? _text;
//
//   @override
//   void dispose() {
//     _canProcess = false;
//     _faceDetector.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DetectorView(
//         title: 'Face Detector',
//         customPaint: _customPaint,
//         text: _text,
//         onImage: _processImage,
//         initialCameraLensDirection: _cameraLensDirection,
//         onCameraLensDirectionChanged: (value) => _cameraLensDirection = value);
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
//   Future<void> _processImage(InputImage inputImage) async {
//     debugPrint('_processImage called111: $inputImage');
//     if (!_canProcess) return;
//     if (_isBusy) return;
//     _isBusy = true;
//     debugPrint('_processImage called 2');
//     setState(() {
//       _text = '';
//     });
//     debugPrint('_processImage called 3 : ${inputImage.metadata?.format}');
//
//
//     final faces = await _faceDetector.processImage(inputImage);
//     if (faces.isNotEmpty) {
//       debugPrint('_processImage called 4');
//
//       final detectedFace = faces.first;
//       final detectedFaceFeatures = extractFaceFeatures(detectedFace);
//
//       // Fetch the saved face features from SharedPreferences
//       FaceFeatures? savedFaceFeatures = await fetchFaceFeatures();
//
//       // Compare the detected and saved face features
//       double similarity = compareFaces(detectedFaceFeatures, savedFaceFeatures!);
//
//       // Set a threshold for similarity
//       const double similarityThreshold = 0.8;
//
//       if (similarity >= similarityThreshold) {
//         _text = "Face matched!";
//       } else {
//         _text = "Face mismatch!";
//       }
//       debugPrint('processImage result $_text');
//       debugPrint('processImage result success: $_text : $similarity : $similarityThreshold');
//
//       // Draw the bounding box and other visual cues
//       final painter = FaceDetectorPainter(faces, inputImage.metadata!.size,
//           inputImage.metadata!.rotation, _cameraLensDirection);
//       _customPaint = CustomPaint(painter: painter);
//     } else {
//       _text = "No face detected.";
//       _customPaint = null;
//
//       debugPrint('processImage result failed: $_text');
//     }
//
//     _isBusy = false;
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   FaceFeatures extractFaceFeatures(Face face) {
//     return FaceFeatures(
//       leftEye: _getLandmarkPoint(face.landmarks, FaceLandmarkType.leftEye),
//       rightEye: _getLandmarkPoint(face.landmarks, FaceLandmarkType.rightEye),
//       noseBase: _getLandmarkPoint(face.landmarks, FaceLandmarkType.noseBase),
//       leftCheek: _getLandmarkPoint(face.landmarks, FaceLandmarkType.leftCheek),
//       rightCheek: _getLandmarkPoint(face.landmarks, FaceLandmarkType.rightCheek),
//       leftEar: _getLandmarkPoint(face.landmarks, FaceLandmarkType.leftEar),
//       rightEar: _getLandmarkPoint(face.landmarks, FaceLandmarkType.rightEar),
//       leftMouth: _getLandmarkPoint(face.landmarks, FaceLandmarkType.leftMouth),
//       rightMouth: _getLandmarkPoint(face.landmarks, FaceLandmarkType.rightMouth),
//       bottomMouth: _getLandmarkPoint(face.landmarks, FaceLandmarkType.bottomMouth));
//   }
//
//   Points _getLandmarkPoint(Map<FaceLandmarkType, FaceLandmark?> landmarks, FaceLandmarkType type) {
//     if (landmarks == null || landmarks[type] == null) {
//       return Points(x: 0, y: 0);
//     }
//     final landmark = landmarks[type]!;
//     return Points(x: landmark.position.x.toInt(), y: landmark.position.y.toInt());
//   }
//
//   double compareFaces(FaceFeatures face1, FaceFeatures face2) {
//     // Calculate face width and height for both faces
//     double faceWidth1 = euclideanDistance(face1.leftEar, face1.rightEar);
//     double faceHeight1 = euclideanDistance(face1.noseBase, face1.bottomMouth);
//
//     double faceWidth2 = euclideanDistance(face2.leftEar, face2.rightEar);
//     double faceHeight2 = euclideanDistance(face2.noseBase, face2.bottomMouth);
//
//     // Calculate relative distances between key features for both faces
//     double relativeEyeDistance1 = calculateRelativeDistance(face1.leftEye, face1.rightEye, faceWidth1);
//     double relativeEyeDistance2 = calculateRelativeDistance(face2.leftEye, face2.rightEye, faceWidth2);
//
//     double relativeNoseToMouthDistance1 = calculateRelativeDistance(face1.noseBase, face1.bottomMouth, faceHeight1);
//     double relativeNoseToMouthDistance2 = calculateRelativeDistance(face2.noseBase, face2.bottomMouth, faceHeight2);
//
//     double relativeInterocularDistance1 = calculateRelativeDistance(face1.leftEye, face1.rightEye, faceWidth1);
//     double relativeInterocularDistance2 = calculateRelativeDistance(face2.leftEye, face2.rightEye, faceWidth2);
//
//     // Add more relative distances:
//     double relativeMouthWidth1 = calculateRelativeDistance(face1.leftMouth, face1.rightMouth, faceWidth1);
//     double relativeMouthWidth2 = calculateRelativeDistance(face2.leftMouth, face2.rightMouth, faceWidth2);
//
//     double relativeEyeToMouthDistance1 = calculateRelativeDistance(face1.leftEye, face1.bottomMouth, faceHeight1);
//     double relativeEyeToMouthDistance2 = calculateRelativeDistance(face2.leftEye, face2.bottomMouth, faceHeight2);
//
//     double relativeCheekDistance1 = calculateRelativeDistance(face1.leftCheek, face1.rightCheek, faceWidth1);
//     double relativeCheekDistance2 = calculateRelativeDistance(face2.leftCheek, face2.rightCheek, faceWidth2);
//
//     // Calculate the difference between the relative distances
//     double distanceDifference =
//         (relativeEyeDistance1 - relativeEyeDistance2).abs() +
//             (relativeNoseToMouthDistance1 - relativeNoseToMouthDistance2).abs() +
//             (relativeInterocularDistance1 - relativeInterocularDistance2).abs() +
//             (relativeMouthWidth1 - relativeMouthWidth2).abs() +
//             (relativeEyeToMouthDistance1 - relativeEyeToMouthDistance2).abs() +
//             (relativeCheekDistance1 - relativeCheekDistance2).abs();
//
//     // Normalize the distance difference (optional)
//     // You can normalize the distance difference based on a predefined range or standard deviation.
//     double normalizedDistanceDifference = distanceDifference / 10; // Adjust normalizationFactor
//
//     // Calculate similarity score (higher value indicates better match)
//     double similarity = 1.0 - normalizedDistanceDifference;
//
//     return similarity;
//   }
//
//   double calculateRelativeDistance(Points? p1, Points? p2, double? faceDimension) {
//     if (p1 == null || p2 == null || faceDimension == null) {
//       return 0.0; // Or handle null values as needed
//     }
//
//     double distance = euclideanDistance(p1, p2);
//     double normalizedDistance = distance / faceDimension;
//     return normalizedDistance;
//   }
//
//   // A function to calculate the Euclidean distance between two points
//   double euclideanDistance(Points? p1, Points? p2) {
//     if (p1 == null || p2 == null) {
//       return 0.0; // Or handle null values as needed
//     }
//     return math.sqrt(math.pow((p1.x ?? 0) - (p2.x ?? 0), 2) + math.pow((p1.y ?? 0) - (p2.y ?? 0), 2));
//   }
// }