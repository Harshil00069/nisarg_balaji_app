// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/camera_view.dart';
// import 'package:flutter_face_detection_balaji_enterprise/src/view/widgets/face_features.dart';
// import 'package:flutter_face_api/flutter_face_api.dart' as regula;
//
// class FaceDetectionScreen extends StatefulWidget {
//   const FaceDetectionScreen({super.key});
//
//   @override
//   State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
// }
//
// class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
//   var image1 = regula.MatchFacesImage();
//   var image2 = regula.MatchFacesImage();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           centerTitle: true,
//           title: const Text('User Authenticate'),
//           elevation: 0),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             CameraView(
//               onImage: (image) {
//                 _setImage(image);
//               },
//               onInputImage: (inputImage) async {
//                 setState(() => isMatching = true);
//                 _faceFeatures =
//                     await extractFaceFeatures(inputImage, _faceDetector);
//                 setState(() => isMatching = false);
//               },
//             ),
//             // TODO Clear comment
//             /*if (isMatching)
//               const Align(
//                 alignment: Alignment.center,
//                 child: Padding(
//                   padding: EdgeInsets.only(top: 64),
//                   child: AnimatedView(),
//                 ),
//               ),*/
//
//             if (_canAuthenticate)
//               isMatching
//                   ? const Center(
//                       child: CircularProgressIndicator(),
//                     )
//                   : ElevatedButton(
//                       child: const Text("Authenticate"),
//                       onPressed: () {
//                         setState(() => isMatching = true);
//                         _fetchUsersAndMatchFace();
//                       },
//                     ),
//             const SizedBox(height: 38),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // A function to calculate the Euclidean distance between two points
//   double euclideanDistance(Points p1, Points p2) {
//     final sqr = math.sqrt(math.pow((p1.x! - p2.x!), 2) + math.pow((p1.y! - p2.y!), 2));
//     return sqr;
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
//     double distNoseToMouth1 = euclideanDistance(face1.noseBase!, face1.bottomMouth!);
//     double distNoseToMouth2 = euclideanDistance(face2.noseBase!, face2.bottomMouth!);
//     double ratioNoseToMouth = distNoseToMouth1 / distNoseToMouth2;
//     double ratio = (ratioEye + ratioEar + ratioCheek + ratioMouth + ratioNoseToMouth) / 5;
//     debugPrint('compareFaces: ${ratio.toString()}');
//
//     return ratio;
//   }
//
//   _matchFaces() async {
//     bool faceMatched = false;
//     for (List user in users) {
//       image1.bitmap = (user.first as UserModel).image;
//       image1.imageType = regula.ImageType.PRINTED;
//
//       //Face comparing logic.
//       var request = regula.MatchFacesRequest();
//       request.images = [image1, image2];
//       dynamic value = await regula.FaceSDK.matchFaces(jsonEncode(request));
//
//       var response = regula.MatchFacesResponse.fromJson(json.decode(value));
//       dynamic str = await regula.FaceSDK.matchFacesSimilarityThresholdSplit(
//           jsonEncode(response!.results), 0.75);
//
//       var split =
//       regula.MatchFacesSimilarityThresholdSplit.fromJson(json.decode(str));
//       setState(() {
//         _similarity = split!.matchedFaces.isNotEmpty
//             ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
//             : "error";
//         log("similarity: $_similarity");
//
//         if (_similarity != "error" && double.parse(_similarity) > 90.00) {
//           faceMatched = true;
//           loggingUser = user.first;
//         } else {
//           faceMatched = false;
//         }
//       });
//       if (faceMatched) {
//         setState(() {
//           trialNumber = 1;
//           isMatching = false;
//         });
//
//         if (mounted) {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => AuthenticatedUserScreen(user: loggingUser!),
//             ),
//           );
//         }
//         break;
//       }
//     }
//     if (!faceMatched) {
//       if (trialNumber == 4) {
//         setState(() => trialNumber = 1);
//         _showFailureDialog(
//           title: "Redeem Failed",
//           description: "Face doesn't match. Please try again.",
//         );
//       } else if (trialNumber == 3) {
//         //After 2 trials if the face doesn't match automatically, the registered name prompt
//         //will be shown. After entering the name the face registered with the entered name will
//         //be fetched and will try to match it with the to be authenticated face.
//         //If the faces match, Viola!. Else it means the user is not registered yet.
//         setState(() {
//           isMatching = false;
//           trialNumber++;
//         });
//         if (!context.mounted) return;
//         showDialog(
//             context: context,
//             builder: (context) {
//               return AlertDialog(
//                 title: const Text("Enter Name"),
//                 content: TextFormField(
//                   controller: _nameController,
//                   cursorColor: Colors.redAccent,
//                   decoration: InputDecoration(
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(
//                         width: 2,
//                         color: Colors.redAccent,
//                       ),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(
//                         width: 2,
//                         color: Colors.redAccent,
//                       ),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       if (_nameController.text.trim().isEmpty) {
//                         debugPrint("Enter a name to proceed");
//                       } else {
//                         Navigator.of(context).pop();
//                         setState(() => isMatching = true);
//                         _fetchUserByName(_nameController.text.trim());
//                       }
//                     },
//                     child: const Text(
//                       "Done",
//                       style: TextStyle(
//                         color: Colors.redAccent,
//                       ),
//                     ),
//                   )
//                 ],
//               );
//             });
//       } else {
//         setState(() => trialNumber++);
//         _showFailureDialog(
//           title: "Redeem Failed",
//           description: "Face doesn't match. Please try again.",
//         );
//       }
//     }
//   }
// }
