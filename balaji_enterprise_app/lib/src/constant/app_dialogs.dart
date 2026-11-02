import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/progress_dialog_widget.dart';
import 'package:get/get.dart';

enum Toast { info, alert, error, success }

class AppDialogs {
  static Future<void> showProgressDialog({
    String? msg,
    bool isDismissible = false,
  }) {
    return showDialog(
      context: Get.context!,
      barrierDismissible: isDismissible,
      builder: (ctx) => progressWidget(
        msg: msg,
      ),
    );
  }

  static Stack progressWidgets({String? msg}) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        UnconstrainedBox(
          child: Container(
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 5),
                  blurRadius: 6.0,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 18.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator.adaptive(),
                const SizedBox(width: 16),
                Material(
                  color: Colors.white,
                  child: FittedBox(
                    child: Text(
                      msg ?? 'Please Wait',
                      style: TextStyle(
                        fontSize: Get.textTheme.titleMedium!.fontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showToast(
    {int delay = 2, required String message, Toast type = Toast.alert}) async {
  int typeId = 0;
  switch (type) {
    case Toast.alert:
      typeId = 0;
    case Toast.error:
      typeId = 2;
      break;
    case Toast.success:
      typeId = 1;
      break;
    case Toast.info:
      typeId = 3;
      break;
  }

  List<Color> colors = [
    Colors.amber.shade800,
    Colors.green.shade800,
    Colors.red.shade800,
    Colors.blue.shade800,
  ];
  List<Color> bgColors = [
    Colors.amber.shade100,
    Colors.green.shade100,
    Colors.red.shade100,
    Colors.blue.shade100,
  ];
  var iconData = [
    Icons.warning_rounded,
    Icons.check_circle_rounded,
    Icons.error,
    Icons.info_rounded
  ];
  await Get.snackbar(
    "",
    "",
    titleText: Container(
      clipBehavior: Clip.hardEdge,
      width: Get.width,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: bgColors[typeId],
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              topLeft: Radius.circular(8.0))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData[typeId], color: colors[typeId], size: 32.0),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              message,
              overflow: TextOverflow.visible,
              maxLines: 8,
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
        ],
      ),
    ),
    duration: Duration(seconds: delay),
    snackPosition: SnackPosition.BOTTOM,
    barBlur: 0.0,
    overlayBlur: 0.0,
    backgroundColor: Colors.transparent,
  ).future;
}

appHandleExeptionDialog({String error = "", required Function()? onTap}) async {
  await Get.defaultDialog(
      title: "Server Error Occured",
      titleStyle: const TextStyle(color: Color(0xFFE09430)),
      barrierDismissible: false,
      content: SizedBox(
        width: Get.width,
        child: Text(error, style: const TextStyle(fontSize: 16)),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () => Get.back(), child: const Text("Back")),
            ElevatedButton(onPressed: onTap, child: const Text("ReLoad")),
          ],
        )
      ]);
}

Future appDoneDialog(
    {String msg = "", required void Function()? onPressed}) async {
  await Get.defaultDialog(
      title: "Attendance Info",
      barrierDismissible: true,
      content: SizedBox(
        width: Get.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const CircularProgressIndicator(),
            Text(msg, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      actions: [
        ElevatedButton(onPressed: onPressed, child: const Text("Back"))
      ]);

}

