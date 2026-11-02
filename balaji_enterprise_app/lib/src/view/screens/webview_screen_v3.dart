// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
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
//   InAppWebViewController? webViewController;
//   double progress = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     requestPermissions();
//   }
//
//   Future<void> requestPermissions() async {
//     if (Platform.isAndroid) {
//       // Request basic storage permission
//       await Permission.storage.request();
//
//       // For Android 11+ (API 30+), you need to handle scoped storage
//       if (await Permission.manageExternalStorage.isGranted == false) {
//         await Permission.manageExternalStorage.request();
//       }
//     }
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
//
//     if (!url.startsWith("http")) {
//       url = 'https://$url';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         centerTitle: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back_ios),
//             onPressed: () async {
//               if (await webViewController?.canGoBack() ?? false) {
//                 await webViewController?.goBack();
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.arrow_forward_ios),
//             onPressed: () async {
//               if (await webViewController?.canGoForward() ?? false) {
//                 await webViewController?.goForward();
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               webViewController?.reload();
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(
//               url: WebUri(url),
//               headers: {
//                 'Authorization': 'Bearer $token',
//               },
//             ),
//             initialSettings: InAppWebViewSettings(
//               allowFileAccess: true,
//               allowContentAccess: true,
//               javaScriptEnabled: true,
//               useOnDownloadStart: true,
//             ),
//             onWebViewCreated: (controller) {
//               webViewController = controller;
//             },
//             onProgressChanged: (controller, progressVal) {
//               setState(() {
//                 progress = progressVal / 100;
//               });
//             },
//             onDownloadStartRequest: (controller, request) async {
//               final fileName = request.url.pathSegments.last;
//               // _downloadAndOpenFile(request.url, request.suggestedFilename ?? fileName);
//               _downloadAndOpenFile(Uri.parse("http://13.127.180.155:8088/02987c31-950e-40a2-8b68-9e2e5fddc89a/${request.suggestedFilename}"), request.suggestedFilename ?? fileName);
//             },
//           ),
//           if (progress < 1.0) const LinearProgressIndicator(),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _downloadAndOpenFile(Uri url, String fileName) async {
//     try {
//       // Get the downloads directory
//       Directory? downloadDir;
//       if (Platform.isAndroid) {
//         downloadDir = Directory('/storage/emulated/0/Download');
//         // Create directory if it doesn't exist
//         if (!await downloadDir.exists()) {
//           await downloadDir.create(recursive: true);
//         }
//       } else {
//         downloadDir = await getApplicationDocumentsDirectory();
//       }
//
//       debugPrint('fileName: $fileName');
//       debugPrint('fileName2: $downloadDir.path');
//       debugPrint('url: $url');
//       final filePath = '${downloadDir.path}/$fileName';
//       final file = File(filePath);
//
//       // Download file
//       final response = await http.get(url);
//       await file.writeAsBytes(response.bodyBytes);
//
//       // Show success message
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('$fileName downloaded successfully'),
//             duration: const Duration(seconds: 10),
//             action: SnackBarAction(
//               label: 'Open File',
//               onPressed: () => _openDownloadedFile(filePath),
//             ),
//           ),
//         );
//       }
//
//       // Open file automatically
//       _openDownloadedFile(filePath);
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Download failed: $e')),
//         );
//       }
//     }
//   }
//
//   void _openDownloadedFile(String filePath) async {
//     try {
//       final result = await OpenFile.open(filePath);
//       if (result.type != ResultType.done) {
//         debugPrint('Error opening file: ${result.message}');
//       }
//     } catch (e) {
//       debugPrint('Exception opening file: $e');
//     }
//   }
// }
