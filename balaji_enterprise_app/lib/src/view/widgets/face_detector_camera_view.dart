import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class FaceDetectorCameraView extends StatefulWidget {
  const FaceDetectorCameraView(
      {super.key,
      required this.customPaint,
      required this.onImage,
      this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.back});

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<FaceDetectorCameraView> createState() => _FaceDetectorCameraViewState();
}

class _FaceDetectorCameraViewState extends State<FaceDetectorCameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
              child: _changingCameraLens
                  ? const Center(child: Text('Changing camera lens'))
                  : CameraPreview(_controller!, child: widget.customPaint)),
          _backButton(),
          _switchLiveCameraToggle(),
          _detectionViewModeToggle(),
          _zoomControl(),
          _exposureControl(),
        ],
      ),
    );
  }

  Widget _backButton() => Positioned(
      top: 40,
      left: 8,
      child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
              heroTag: Object(),
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: Colors.black54,
              child: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white, size: 20))));

  Widget _detectionViewModeToggle() => Positioned(
      bottom: 8,
      left: 8,
      child: SizedBox(
          height: 50,
          width: 50,
          child: FloatingActionButton(
              heroTag: Object(),
              onPressed: widget.onDetectorViewModeChanged,
              backgroundColor: Colors.black54,
              child: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 25))));

  Widget _switchLiveCameraToggle() => Positioned(
      bottom: 8,
      right: 8,
      child: SizedBox(
          height: 50,
          width: 50,
          child: FloatingActionButton(
              heroTag: Object(),
              onPressed: _switchLiveCamera,
              backgroundColor: Colors.black54,
              child: Icon(
                  Platform.isIOS
                      ? Icons.flip_camera_ios_outlined
                      : Icons.flip_camera_android_outlined,
                  color: Colors.white,
                  size: 25))));

  Widget _zoomControl() => Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 240,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: _currentZoomLevel,
                    min: _minAvailableZoom,
                    max: _maxAvailableZoom,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentZoomLevel = value;
                      });
                      await _controller?.setZoomLevel(value);
                    },
                  ),
                ),
                Container(
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Center(
                            child: Text(
                                '${_currentZoomLevel.toStringAsFixed(1)}x',
                                style: const TextStyle(color: Colors.white))))),
              ],
            ),
          ),
        ),
      );

  Widget _exposureControl() => Positioned(
        top: 40,
        right: 8,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250),
          child: Column(children: [
            Container(
                width: 55,
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                        child: Text(
                            '${_currentExposureOffset.toStringAsFixed(1)}x',
                            style: const TextStyle(color: Colors.white))))),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  height: 30,
                  child: Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentExposureOffset = value;
                      });
                      await _controller?.setExposureOffset(value);
                    },
                  ),
                ),
              ),
            )
          ]),
        ),
      );

  Future _startLiveFeed() async {
    debugPrint('_startLiveFeed called');
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
        camera,
        // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888);
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      debugPrint('_startLiveFeed called 2');
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    debugPrint('_processCameraImage called: $image');
    final inputImage = _inputImageFromCameraImage(image);
    debugPrint('_processCameraImage called 2: $inputImage');
    if (inputImage == null) return;
    debugPrint('_processCameraImage called 3');
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  // InputImage? _inputImageFromCameraImage(CameraImage image) {
  //   if (_controller == null) return null;
  //
  //   // get image rotation
  //   // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
  //   // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
  //   // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
  //   final camera = _cameras[_cameraIndex];
  //   final sensorOrientation = camera.sensorOrientation;
  //   // print(
  //   //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
  //   InputImageRotation? rotation;
  //   if (Platform.isIOS) {
  //     rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  //   } else if (Platform.isAndroid) {
  //     var rotationCompensation =
  //         _orientations[_controller!.value.deviceOrientation];
  //     if (rotationCompensation == null) return null;
  //     if (camera.lensDirection == CameraLensDirection.front) {
  //       // front-facing
  //       rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
  //     } else {
  //       // back-facing
  //       rotationCompensation =
  //           (sensorOrientation - rotationCompensation + 360) % 360;
  //     }
  //     rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
  //     // print('rotationCompensation: $rotationCompensation');
  //   }
  //   if (rotation == null) return null;
  //   // print('final rotation: $rotation');
  //
  //   // get image format
  //   final format = InputImageFormatValue.fromRawValue(image.format.raw);
  //   // validate format depending on platform
  //   // only supported formats:
  //   // * nv21 for Android
  //   // * bgra8888 for iOS
  //   if (format == null ||
  //       // (Platform.isAndroid && format != InputImageFormat.nv21) ||
  //       (Platform.isAndroid) ||
  //       // (Platform.isIOS && format != InputImageFormat.bgra8888)
  //       (Platform.isIOS)) return null;
  //
  //   // since format is constraint to nv21 or bgra8888, both only have one plane
  //   if (image.planes.length != 1) return null;
  //   final plane = image.planes.first;
  //
  //   // compose InputImage using bytes
  //   return InputImage.fromBytes(
  //     bytes: plane.bytes,
  //     metadata: InputImageMetadata(
  //       size: Size(image.width.toDouble(), image.height.toDouble()),
  //       rotation: rotation, // used only in Android
  //       format: format, // used only in iOS
  //       bytesPerRow: plane.bytesPerRow, // used only in iOS
  //     ),
  //   );
  // }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // Get camera and sensor orientation
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    // Log device and camera information for debugging
    debugPrint('Device orientation: ${_controller?.value.deviceOrientation}, Camera lens direction: ${camera.lensDirection}');

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
      _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) {
        debugPrint('Failed to get rotation compensation for device orientation');
        return null;
      }
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      debugPrint('Calculated rotation compensation: $rotationCompensation');
    }
    if (rotation == null) {
      debugPrint('Failed to calculate rotation');
      return null;
    }

    // Check and validate image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      debugPrint('Unsupported image format: ${image.format.raw}');
      return null;
    }

    // Validate plane count (should be 1)
    if (image.planes.length != 1) {
      debugPrint('Unexpected number of image planes: ${image.planes.length}');
      // return null;
    }
    final plane = image.planes.first;

    debugPrint('format: $format');
    debugPrint('format2: ${format.index}');
    debugPrint('format3: ${format.index.toString()} : ${format.name.toString()}');
    // if ((Platform.isAndroid && format == InputImageFormat.yuv_420_888)) {
    //   debugPrint('format4: ${format.index.toString()} : ${format.name.toString()}');
    //
    //   return InputImage.fromBytes(
    //       bytes: image.getNv21Uint8List(),
    //       metadata: InputImageMetadata(
    //         size: Size(image.width.toDouble(), image.height.toDouble()),
    //         rotation: rotation, // used only in Android
    //         format: format, // used only in iOS
    //         bytesPerRow: image.planes.first.bytesPerRow, // used only in iOS
    //       ));
    // }

    debugPrint('format5: ${format.index.toString()} : ${format.name.toString()}');

    // Compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}

extension Nv21Converter on CameraImage {
  Uint8List getNv21Uint8List() {
    final width = this.width;
    final height = this.height;

    final yPlane = planes[0];
    final uPlane = planes[1];
    final vPlane = planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final numPixels = (width * height * 1.5).toInt();
    final nv21 = List<int>.filled(numPixels, 0);

    // Full size Y channel and quarter size U+V channels.
    int idY = 0;
    int idUV = width * height;
    final uvWidth = width ~/ 2;
    final uvHeight = height ~/ 2;
    // Copy Y & UV channel.
    // NV21 format is expected to have YYYYVU packaging.
    // The U/V planes are guaranteed to have the same row stride and pixel stride.
    // getRowStride analogue??
    final uvRowStride = uPlane.bytesPerRow;
    // getPixelStride analogue
    final uvPixelStride = uPlane.bytesPerPixel ?? 0;
    final yRowStride = yPlane.bytesPerRow;
    final yPixelStride = yPlane.bytesPerPixel ?? 0;

    for (int y = 0; y < height; ++y) {
      final uvOffset = y * uvRowStride;
      final yOffset = y * yRowStride;

      for (int x = 0; x < width; ++x) {
        nv21[idY++] = yBuffer[yOffset + x * yPixelStride];

        if (y < uvHeight && x < uvWidth) {
          final bufferIndex = uvOffset + (x * uvPixelStride);
          //V channel
          nv21[idUV++] = vBuffer[bufferIndex];
          //V channel
          nv21[idUV++] = uBuffer[bufferIndex];
        }
      }
    }
    return Uint8List.fromList(nv21);
  }
}
