// ignore: unused_import
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:camera/camera.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'cameraservice.dart';
import 'database.dart';
import 'servicelocator.dart';

RRect _faceRect(
    {required Rect rect,
    required Size imageSize,
    required Size widgetSize,
    double scaleX = 1,
    double scaleY = 1}) {
  return RRect.fromLTRBR(
      (widgetSize.width - rect.left.toDouble() * scaleX),
      rect.top.toDouble() * scaleY,
      (widgetSize.width - rect.right.toDouble() * scaleX),
      rect.bottom.toDouble() * scaleY,
      const Radius.circular(5));
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter({
    required this.face,
    required this.absoluteImageSize,
    this.userDist,
  });

  Face? face;
  Size absoluteImageSize;
  double? userDist;
  double? scaleX, scaleY;
  double textSize = 16;
  List<String?> boxText = [];
  List<TextPainter?> tPainters = [];

  @override
  void paint(Canvas canvas, Size size) {
    if (face == null) return;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.red;

    scaleX = size.width / absoluteImageSize.width;
    scaleY = size.height / absoluteImageSize.height;

    canvas.drawRRect(
        _faceRect(
            rect: face!.boundingBox,
            imageSize: absoluteImageSize,
            widgetSize: size,
            scaleX: scaleX ?? 1,
            scaleY: scaleY ?? 1),
        paint);

    boxText.clear();
    boxText.add(
        "Right : ${face?.rightEyeOpenProbability?.toStringAsFixed(3).toString()}");
    boxText.add(
        "Left  : ${face?.leftEyeOpenProbability?.toStringAsFixed(3).toString()}");
    if (userDist != null) {
      boxText
          .add("Confidence: ${(1 - userDist!).toStringAsFixed(3).toString()}");
      if (userDist! < 0.5) {
        boxText.add(LocalDB.getUserName().toString());
      } else {
        boxText.add("Unknown Person");
      }
    } else {
      boxText.add("Person");
    }

    _textPainters({
      int length = 1,
      required List<String?> msgList,
      double fontSize = 16.0,
    }) {
      List<TextPainter?> tPtList = [];
      for (int i = 0; i < length; i++) {
        tPtList.add(
          TextPainter(
            text: TextSpan(
              text: msgList[i] ?? "",
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            ),
            textDirection: TextDirection.rtl,
          ),
        );
        tPtList[i]!.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
      }
      return tPtList;
    }

    tPainters = _textPainters(length: boxText.length, msgList: boxText);
    //dev.log("${tPainters.length}");

    for (var i = 0; i < tPainters.length; i++) {
      tPainters[i]!.paint(
        canvas,
        Offset(
            (size.width - face!.boundingBox.right.toDouble() * scaleX!),
            (face!.boundingBox.top.toDouble() - (textSize + textSize * i) * 2) *
                scaleY!),
      );
    }

    void paintContour(FaceContourType type) {
      final faceContour = face!.contours[type];
      if (faceContour?.points != null) {
        for (final math.Point point in faceContour!.points) {
          canvas.drawCircle(
              Offset(
                (size.width - point.x.toDouble() * scaleX!),
                (point.y.toDouble() * scaleY!),
              ),
              1,
              paint);
        }
      }
    }

    //paintContour(FaceContourType.leftEye);
    //paintContour(FaceContourType.rightEye);
    //paintContour(FaceContourType.upperLipTop);
    //paintContour(FaceContourType.upperLipBottom);
    //paintContour(FaceContourType.lowerLipTop);
    //paintContour(FaceContourType.lowerLipBottom);
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.face != face;
  }
}

class FaceDetectorService {
  final CameraService _cameraService = serviceLocator<CameraService>();

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableContours: true,
      enableClassification: true,
    ),
  );
  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];
  List<Face> get faces => _faces;

  InputImage? _inputImage;
  InputImage? get inputImage => _inputImage;

  Future<void> processCameraImage(CameraImage cameraImage) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

    final imageRotation = InputImageRotationValue.fromRawValue(
        _cameraService.inputImageRotation!.rawValue);

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(cameraImage.format.raw);

    final planeData = cameraImage.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation!,
      inputImageFormat: inputImageFormat!,
      planeData: planeData,
    );

    InputImage inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    _faces = await _faceDetector.processImage(inputImage);
  }

  Future<void> processInputImage(InputImage inputImage) async {
    _faces = await _faceDetector.processImage(inputImage);
  }

  /*
  Future<void> detectFaces(CameraImage cameraImage) async {
    _inputImage = await _processCameraImage(cameraImage);
  }
  */

  dispose() {
    _faceDetector.close();
  }
}
