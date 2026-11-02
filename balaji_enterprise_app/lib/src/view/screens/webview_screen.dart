import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewModel {
  final String title;
  final String url;
  final String token;

  WebViewModel({required this.title, required this.url, required this.token});
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  String title = '';
  String url = '';
  String token = '';
  InAppWebViewController? webViewController;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      if (await Permission.manageExternalStorage.isGranted == false) {
        await Permission.manageExternalStorage.request();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final webModel = ModalRoute.of(context)?.settings.arguments as WebViewModel;
    title = webModel.title;
    url = webModel.url;
    token = webModel.token;

    if (!url.startsWith("http")) {
      url = 'https://$url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              if (await webViewController?.canGoBack() ?? false) {
                await webViewController?.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () async {
              if (await webViewController?.canGoForward() ?? false) {
                await webViewController?.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(url),
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
            initialSettings: InAppWebViewSettings(
              allowFileAccess: true,
              allowContentAccess: true,
              javaScriptEnabled: true,
              useOnDownloadStart: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;

              // Inject JavaScript function to download blobs
              controller.evaluateJavascript(source: '''
                window.downloadBlobFile = function(blobUrl, fileName) {
                  fetch(blobUrl)
                    .then(res => res.blob())
                    .then(blob => {
                      const reader = new FileReader();
                      reader.onloadend = function() {
                        const base64Data = reader.result;
                        window.flutter_inappwebview.callHandler('blobDownload', base64Data, fileName);
                      };
                      reader.readAsDataURL(blob);
                    });
                };
              ''');

              // Register blobDownload handler
              controller.addJavaScriptHandler(
                handlerName: 'blobDownload',
                callback: (args) async {
                  final base64Str = args[0];
                  final fileName = args[1];
                  final base64Content = base64Str.split(',').last;
                  final bytes = base64Decode(base64Content);

                  Directory downloadDir =
                      Directory('/storage/emulated/0/Download');
                  if (!await downloadDir.exists())
                    await downloadDir.create(recursive: true);
                  final file = File('${downloadDir.path}/$fileName');
                  await file.writeAsBytes(bytes);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$fileName downloaded successfully'),
                        action: SnackBarAction(
                          label: 'Open File',
                          onPressed: () => _openDownloadedFile(file.path),
                        ),
                      ),
                    );
                  }

                  _openDownloadedFile(file.path);
                },
              );
            },
            onProgressChanged: (controller, progressVal) {
              setState(() {
                progress = progressVal / 100;
              });
            },
            onDownloadStartRequest: (controller, request) async {
              final isBlob = request.url.toString().startsWith('blob:');
              final fileName =
                  request.suggestedFilename ?? request.url.pathSegments.last;

              if (isBlob) {
                final js = '''
    (function() {
      if (typeof window.downloadBlobFile !== 'function') {
        window.downloadBlobFile = function(blobUrl, fileName) {
          fetch(blobUrl)
            .then(res => res.blob())
            .then(blob => {
              const reader = new FileReader();
              reader.onloadend = function() {
                const base64Data = reader.result;
                window.flutter_inappwebview.callHandler('blobDownload', base64Data, fileName);
              };
              reader.readAsDataURL(blob);
            });
        };
      }
      window.downloadBlobFile("${request.url}", "$fileName");
    })();
  ''';
                webViewController?.evaluateJavascript(source: js);
              } else {
                _downloadAndOpenFile(
                    Uri.parse(request.url.toString()), fileName);
              }
            },
          ),
          if (progress < 1.0) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Future<void> _downloadAndOpenFile(Uri url, String fileName) async {
    try {
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      debugPrint('fileName: $fileName');
      debugPrint('filePath: ${downloadDir.path}');
      debugPrint('url: $url');
      // final filePath = '${downloadDir.path}/$fileName';

      // Clean filename by removing query params or content-disposition extras
      final cleanFileName = fileName.split(';').first.trim().replaceAll(RegExp(r'[^\w\s.\-_]'), '_');
      final filePath = '${downloadDir.path}/$cleanFileName';
      final file = File(filePath);

      final response = await http.get(url);
      await file.writeAsBytes(response.bodyBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName downloaded successfully'),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Open File',
              onPressed: () => _openDownloadedFile(filePath),
            ),
          ),
        );
      }

      _openDownloadedFile(filePath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  void _openDownloadedFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        debugPrint('Error opening file: ${result.message}');
      }
    } catch (e) {
      debugPrint('Exception opening file: $e');
    }
  }
}
