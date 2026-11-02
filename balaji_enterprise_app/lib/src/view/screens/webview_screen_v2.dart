// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_face_detection_balaji_enterprise/utils/app_colors.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
//
// class WebViewModel {
//   final String title;
//   final String url;
//   final String token;
//
//   WebViewModel({required this.title, required this.url, required this.token});
// }
//
// class WebViewScreen extends StatefulWidget {
//   const WebViewScreen({super.key});
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   String title = '';
//   String url = '';
//   String token = '';
//   WebViewController? controller;
//   int loadingPercentage = 0;
//
//   @override
//   void dispose() {
//     controller?.clearCache();
//     super.dispose();
//   }
//
//   Future<void> clearWebViewCookies() async {
//     final cookieManager = WebViewCookieManager();
//     await cookieManager.clearCookies();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//     final webModel = ModalRoute.of(context)?.settings.arguments as WebViewModel;
//     title = webModel.title;
//     url = webModel.url;
//     token = webModel.token;
//     if (!url.startsWith("http")) {
//       url = 'https://$url';
//     }
//     debugPrint('webview url: $url');
//
//     clearWebViewCookies().then((_) {
//       controller = WebViewController()
//         ..setNavigationDelegate(NavigationDelegate(
//           onPageStarted: (url) {
//             setState(() {
//               loadingPercentage = 0;
//             });
//           },
//           onProgress: (progress) {
//             setState(() {
//               loadingPercentage = progress;
//             });
//           },
//           onPageFinished: (url) {
//             setState(() {
//               loadingPercentage = 100;
//             });
//           },
//           onWebResourceError: (error) {
//             debugPrint('WebView Error: ${error.description}');
//             setState(() {
//               loadingPercentage = 100; // Stop loading indicator
//             });
//           },
//         ))
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..setBackgroundColor(AppColors.transparent)
//         ..loadRequest(Uri.parse(url), headers: {
//           'Authorization': 'Bearer $token',
//         });
//
//       if (controller?.platform is AndroidWebViewController) {
//         AndroidWebViewController.enableDebugging(true);
//         (controller?.platform as AndroidWebViewController)
//             .setMediaPlaybackRequiresUserGesture(false);
//
//         addFileSelectionListener();
//       }
//     });
//   }
//
//   void addFileSelectionListener() async {
//     if (Platform.isAndroid && controller != null) {
//       final androidController = controller!.platform as AndroidWebViewController;
//       await androidController.setOnShowFileSelector(_androidFilePicker);
//     }
//   }
//
//   Future<List<String>> _androidFilePicker(final FileSelectorParams params) async {
//     final result = await FilePicker.platform.pickFiles();
//
//     if (result != null && result.files.single.path != null) {
//       final file = File(result.files.single.path!);
//       return [file.uri.toString()];
//     }
//     return [];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         centerTitle: false,
//         backgroundColor: AppColors.white,
//         surfaceTintColor: AppColors.white,
//         actions: [
//           GestureDetector(
//               onTap: () async {
//                 if (await controller?.canGoBack() ?? false) {
//                   await controller?.goBack();
//                 }
//               },
//               child: const Icon(Icons.arrow_back_ios)),
//           const SizedBox(width: 16),
//           GestureDetector(
//               onTap: () async {
//                 if (await controller?.canGoForward() ?? false) {
//                   await controller?.goForward();
//                 }
//               },
//               child: const Icon(Icons.arrow_forward_ios)),
//           const SizedBox(width: 16),
//           GestureDetector(
//               onTap: () {
//                 controller?.reload();
//               },
//               child: const Icon(Icons.replay)),
//           const SizedBox(width: 16)
//         ],
//       ),
//       body: Stack(
//         children: [
//           /// Show WebView only when loading is complete
//           Opacity(
//               opacity: loadingPercentage == 100 ? 1.0 : 0.0,
//               child: controller == null
//                   ? const SizedBox()
//                   : WebViewWidget(controller: controller!)),
//
//           /// Show loader while loading
//           if (loadingPercentage < 100)
//             const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }
