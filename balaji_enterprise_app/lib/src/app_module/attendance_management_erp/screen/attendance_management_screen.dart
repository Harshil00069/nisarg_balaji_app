import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/background_service/flutter_background_service.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/controller/attendance_management_controller.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/app_module/attendance_management_erp/custom_widget/camera_capture_widget.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/app_fonts.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/check_connectivity_screen.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/database_helper.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class AddAttendanceScreen extends StatefulWidget {
  const AddAttendanceScreen({super.key});

  @override
  State<AddAttendanceScreen> createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends State<AddAttendanceScreen> {
  final AttendanceManagementController _attendanceManagementController =
      Get.put(AttendanceManagementController());

  String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();

    _attendanceManagementController.initializeApiData();
  }

  @override
  Widget build(BuildContext context) {
    return CheckNetworkUI(
      child: Scaffold(
        appBar: AppBar(
          title: Text('DAY in - Day out', style: AppFonts.appTitle()),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              height: Get.height * 0.32,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: GoogleMap(
                myLocationEnabled: true,
                initialCameraPosition:
                    _attendanceManagementController.kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _attendanceManagementController.googleMapController
                      .complete(controller);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                '* We Need to Capture Your Photo before Punch in or Punch Out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
              child: Obx(
                () => Text(
                  _attendanceManagementController.fullAddress.value,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Obx(
              () => _attendanceManagementController
                              .punchDetail.value.isTakeRangeAction ==
                          1 &&
                      !_attendanceManagementController.isOnWorkPlace.value
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.primary,
                              blurRadius: 4.0,
                              spreadRadius: 1.0,
                            )
                          ]),
                      child: Text(
                          "You Can Not Fill Attendance Due to Out Off Working Range",
                          textAlign: TextAlign.center,
                          style: AppFonts.text(
                              size: 16, color: Colors.red.shade800)),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        punchInButtonWidget(),
                        punchOutButtonWidget(),
                      ],
                    ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(
              color: AppColors.grey,
              indent: 14,
              endIndent: 14,
              thickness: 0.9,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                'Today Punch In - Out History ($todayDate)',
                style: AppFonts.bodyText1(color: Colors.green.shade800),
              ),
            ),
            // Text(
            //   LoginUserDetail.erpUser.value.punchInDnt,
            //   style: AppFonts.label1(color: AppColors.black),
            // ),
            // const SizedBox(
            //   height: 6,
            // ),
            // Text(
            //   LoginUserDetail.erpUser.value.punchOutDnt,
            //   style: AppFonts.label1(color: AppColors.black),
            // ),
          ],
        ),
      ),
    );
  }

  Widget punchInButtonWidget() {
    return Opacity(
      // opacity: LoginUserDetail.erpUser.value.punchInFlag != 0 ? 0.5 : 1,
      opacity: 1,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.hardEdge,
        elevation: 2,
        child: InkWell(
          onTap: () async {
            await startBackgroundService();
            // if (LoginUserDetail.erpUser.value.punchInDnt.trim().isNotEmpty) {
            //   appDoneDialog(
            //       onPressed: () {
            //         Get.back();
            //       },
            //       msg:
            //           "Your Today's Punch In Done at  ${LoginUserDetail.erpUser.value.punchInDnt} ");
            // } else if (LoginUserDetail.erpUser.value.punchInFlag == 0) {
            //   if (_attendanceManagementController.isLoadingGoogleMap.isFalse &&
            //       _attendanceManagementController.hasErrorGoogleMap.isFalse) {
            //     showDialogForPunchIn();
            //   } else {
            //     showToast(
            //       message: "Please Wait...\nLocation Fetching",
            //     );
            //   }
            // } else {
            //   appDoneDialog(
            //       onPressed: () {
            //         Get.back();
            //       },
            //       msg:
            //           "Your Today's Punch In Done at  ${_attendanceManagementController.punchDetail.value.inTime}  ${_attendanceManagementController.punchDetail.value.erpInAttendance.trim().isNotEmpty ? _attendanceManagementController.punchDetail.value.erpInAttendance.trim() : ""}");
            // }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 35,
                  child: Icon(
                    Icons.fingerprint,
                    size: 35,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Punch IN',
                  style: AppFonts.text(
                    size: 16,
                    color: AppColors.black,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Press to Punch In',
                  style: AppFonts.label3(color: AppColors.black),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> showDialogForPunchIn({bool isForPunchOut = false}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          isForPunchOut ? 'Punch Out' : 'Punch IN',
          textAlign: TextAlign.center,
          style: AppFonts.subTitle1(color: AppColors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photo *',
              style: AppFonts.label1(color: Colors.black),
            ),
            Container(
              width: double.infinity,
              height: Get.height * 0.16,
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              alignment: Alignment.center,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(
                () => _attendanceManagementController
                        .pickImage.value.path.isNotEmpty
                    ? Row(
                        children: [
                          Image.file(
                              _attendanceManagementController.pickImage.value,
                              fit: BoxFit.fill),
                          Expanded(
                            child: IconButton(
                              onPressed: () => _attendanceManagementController
                                  .pickImage.value = File(''),
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red.shade700,
                              ),
                            ),
                          )
                        ],
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CameraCapture(
                                onImageCaptured: (file) {
                                  Navigator.pop(context);
                                  _attendanceManagementController
                                      .pickImage.value = file;
                                },
                              ),
                            ),
                          );
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Capture Photo'),
                            SizedBox(
                              height: 6,
                            ),
                            Icon(Icons.camera_alt)
                          ],
                        ),
                      ),
              ),
            ),
            Text(
              'City *',
              style: AppFonts.label1(color: Colors.black),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(
                () => Text(
                  _attendanceManagementController.currentCity.value,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // _attendanceManagementController.savePunchInData(
                  //     punchInOrOutFlag: isForPunchOut ? "1" : "0");
                },
                child: Obx(
                  () => Text(
                      _attendanceManagementController.isPunchInLoading.value
                          ? "Please Wait.."
                          : 'Submit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget punchOutButtonWidget() {
    return Opacity(
      // opacity: LoginUserDetail.erpUser.value.punchOutDnt.isEmpty ? 1 : 0.5,
      opacity: 1,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.hardEdge,
        elevation: 2,
        child: InkWell(
          onTap: () async {
            stopBackgroundService();
            final databaseHelper = DatabaseHelper();
             await  databaseHelper.clearPendingRangeEvents();
            final user = await databaseHelper.fetchStoredUser();
            final employeeId = user.empId;
            print("employeeId=> ${employeeId}");
            await databaseHelper.clearActiveRangeExit(employeeId: employeeId, rangeId: 1);
            // if (LoginUserDetail.erpUser.value.punchOutDnt.isNotEmpty) {
            //   appDoneDialog(
            //     onPressed: () {
            //       Get.back();
            //     },
            //     msg:
            //         "Your Today's Punch Out Done at  ${LoginUserDetail.erpUser.value.punchOutDnt} ",
            //   );
            // } else if (LoginUserDetail.erpUser.value.punchOutDnt.isEmpty &&
            //     LoginUserDetail.erpUser.value.punchInFlag != 0) {
            //   if (_attendanceManagementController.isLoadingGoogleMap.isFalse &&
            //       _attendanceManagementController.hasErrorGoogleMap.isFalse) {
            //     showDialogForPunchIn(isForPunchOut: true);
            //   } else {
            //     showToast(message: "Please Wait...\nLocation Fetching");
            //   }
            // } else {
            //   appDoneDialog(
            //       onPressed: () {
            //         Get.back();
            //       },
            //       msg:
            //           "Your Today's Punch Out Done at  ${LoginUserDetail.erpUser.value.punchOutDnt}");
            // }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 35,
                  child: Icon(
                    Icons.fingerprint,
                    size: 35,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Punch Out',
                  style: AppFonts.text(
                    size: 16,
                    color: AppColors.black,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Press to Punch Out',
                  style: AppFonts.label3(color: AppColors.black),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
