import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';
import 'package:get/get.dart';

class CheckNetworkUI extends StatefulWidget {
  const CheckNetworkUI({super.key, required this.child});
  final Widget child;

  @override
  State<CheckNetworkUI> createState() => _CheckNetworkUIState();
}

class _CheckNetworkUIState extends State<CheckNetworkUI> {
  final connect = Connectivity();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        connect.checkConnectivity();
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: AppColors.primary,
        child: LayoutBuilder(builder: (context, cons) {
          return Scaffold(
            body: StreamBuilder<List<ConnectivityResult>>(
              stream: connect.onConnectivityChanged,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return SizedBox(
                      height: cons.maxHeight,
                      width: cons.maxWidth,
                      child: widget.child);
                }
                var snapshotData = snapshot.data ?? [];
                // print("Check networks:  $snapshotData");
                if (snapshotData.contains(ConnectivityResult.wifi) ||
                    snapshotData.contains(ConnectivityResult.ethernet) ||
                    snapshotData.contains(ConnectivityResult.mobile)) {
                  return SizedBox(
                      height: cons.maxHeight,
                      width: cons.maxWidth,
                      child: widget.child);
                } else {
                  return SizedBox(
                      height: cons.maxHeight,
                      width: cons.maxWidth,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          backDesignStack(cons),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_rounded,
                                size: Get.width * 0.65,
                                color: AppColors.primary,
                              ),
                              // SizeTransition(
                              //     axisAlignment: 1,
                              //     sizeFactor: _animation,
                              //     axis: Axis.vertical,
                              //     child: Container(
                              //         alignment: Alignment.center,
                              //         child: Icon(
                              //           Icons.wifi_rounded,
                              //           size: Get.width * 0.65,
                              //           color: AppColors.primaryColor,
                              //         ))),
                              Text.rich(
                                  TextSpan(
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                          text: "Oh no... !",
                                          // style: AppFonts.label2(
                                          //   color: AppColors.black,
                                          // )
                                      ),
                                      TextSpan(
                                          text:
                                              "\n\nSlow  Internet or\n Lost  Network Connection.",
                                          // style: AppFonts.label2(
                                          //   color: AppColors.secondaryColor,
                                          // )
                                      ),
                                      const TextSpan(
                                          text:
                                              "\nPlease Check your Internet Settings\n")
                                    ],
                                  ),
                                  textAlign: TextAlign.center)
                            ],
                          ),
                        ],
                      ));
                }
              },
            ),
          );
        }),
      ),
    );
  }

  SizedBox backDesignStack(BoxConstraints cons) {
    return SizedBox(
        height: cons.maxHeight,
        width: cons.maxWidth,
        child: Stack(fit: StackFit.expand, children: [
          Positioned(
              top: cons.maxHeight * 0.12,
              left: -50,
              child: const CircleAvatar(
                maxRadius: 50,
                backgroundColor: AppColors.primary,
              )),
          Positioned(
              bottom: -60,
              left: -10,
              child: CircleAvatar(
                maxRadius: 100,
                backgroundColor: AppColors.white,
              )),
          Positioned(
              top: cons.maxHeight * 0.6,
              right: 40,
              child: CircleAvatar(
                maxRadius: 10,
                backgroundColor: AppColors.primary,
              )),
          Positioned(
              top: cons.maxHeight * 0.10,
              left: cons.maxWidth * 0.75,
              child: CircleAvatar(
                maxRadius: 30,
                backgroundColor: AppColors.white,
              )),
          Positioned(
              top: cons.maxHeight * 0.6,
              left: 40,
              child: CircleAvatar(
                maxRadius: 15,
                backgroundColor: AppColors.white,
              )),
          Container(
              height: cons.maxHeight,
              width: cons.maxWidth,
              color: AppColors.white.withValues(alpha: 0.8)),
        ]));
  }
}

Container gradientDots(
    {double height = 160, double width = 160, List<Color>? colors}) {
  return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: colors ??
                  [
                    AppColors.primary,
                    AppColors.white,

                  ]),
          borderRadius: BorderRadius.circular(100)));
}

class NetworkBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late List<ConnectivityResult> connectivityResult;
  late StreamSubscription<List<ConnectivityResult>> _streamSubscription;
  RxBool isConnect = true.obs;
  @override
  void onInit() async {
    super.onInit();
    _initConnectivity();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    connectivityResult = await _connectivity.checkConnectivity();
    update();
  }

  void _updateConnectionStatus(
      List<ConnectivityResult> connectivityResultArgument) {
    connectivityResult = connectivityResultArgument;
    var currentNetStatus =
        connectivityResultArgument.contains(ConnectivityResult.wifi) ||
            connectivityResultArgument.contains(ConnectivityResult.ethernet) ||
            connectivityResultArgument.contains(ConnectivityResult.mobile);
    isConnect.value = currentNetStatus;
    if (currentNetStatus == false) {
      Get.rawSnackbar(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.only(
              left: 32.0, right: 32.0, top: 4.0, bottom: 4.0),
          messageText: Text(
            'No Internet Connection',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: Get.textTheme.bodyMedium!.fontSize,
            ),
          ),
          isDismissible: false,
          duration: const Duration(
            days: 1,
          ),
          backgroundColor: Colors.red,
          icon: const Icon(Icons.wifi_off, color: Colors.white, size: 18),
          snackStyle: SnackStyle.FLOATING);
    }
    update();
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
  }
}
