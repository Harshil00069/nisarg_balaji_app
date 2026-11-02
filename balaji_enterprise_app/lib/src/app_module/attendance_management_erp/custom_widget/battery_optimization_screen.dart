import 'package:disable_battery_optimizations_latest/disable_battery_optimizations_latest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_balaji_enterprise/src/constant/app_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../constant/app_dialogs.dart' as AppDialogs show showToast, Toast;

class BatteryOptimizationScreen extends StatefulWidget {
  final Function() onSuccessfullyGrantPermission;

  const BatteryOptimizationScreen({
    super.key,
    required this.onSuccessfullyGrantPermission,
  });

  @override
  State<BatteryOptimizationScreen> createState() =>
      _BatteryOptimizationScreenState();
}

class _BatteryOptimizationScreenState extends State<BatteryOptimizationScreen>
    with WidgetsBindingObserver {
  int selectedOption = 1;
  bool allowBackground = true;

  @override
  void initState() {
    super.initState();
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Listen to lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _checkAndProceed();
    }
  }

  Future<void> _openBatterySettings() async {
    await openAppSettings();
  }

  Future<void> _checkAndProceed() async {
    final isIgnored =
        await DisableBatteryOptimizationLatest.isBatteryOptimizationDisabled ??
        false;

    if (isIgnored) {
      widget.onSuccessfullyGrantPermission.call();
      Navigator.pop(context, true);
    } else {
      AppDialogs.showToast(
        message: "Please enable Battery Optimization Settings",
        type: AppDialogs.Toast.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            "Improve System Performance",
            style: AppFonts.subTitle1(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                "Follow these steps to ensure the app runs smoothly in the background:",
                style: AppFonts.bodyText2(color: Colors.black),
              ),
              const SizedBox(height: 20),

              // Step 1
              _stepTile(
                number: "1",
                text: "Open Settings and navigate to App Info.",
              ),

              _stepTile(number: "2", text: "Tap 'Battery Usage'."),

              _stepTile(
                number: "3",
                text: "Select 'Unrestricted' or enable Background Activity.",
              ),

              const SizedBox(height: 20),

              // Unrestricted option
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    RadioGroup(
                      groupValue: selectedOption,
                      onChanged: (val) {
                        setState(() => selectedOption = val ?? 0);
                      },
                      child: Radio<int>(value: 1),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Unrestricted",
                      style: AppFonts.bodyText1(color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // OR Divider
              Center(
                child: Text(
                  "OR",
                  style: AppFonts.bodyText2(color: Colors.black),
                ),
              ),
              const SizedBox(height: 12),

              // Background Activity
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    CupertinoSwitch(
                      value: allowBackground,
                      onChanged: (value) {
                        setState(() => allowBackground = value);
                      },
                      activeTrackColor: CupertinoColors.destructiveRed,
                      thumbColor: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Allow Background Activity",
                        style: AppFonts.bodyText1(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Continue Button
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _openBatterySettings,
                child: Text(
                  "Open Settings",
                  style: AppFonts.bodyText1(color:Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _checkAndProceed,
                child: Text("Done", style: AppFonts.bodyText1()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepTile({required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue.shade50,
            child: Text(number, style: AppFonts.label1(color: Colors.blue)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppFonts.bodyText2(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
