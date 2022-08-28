// ignore: unused_import
import 'dart:developer' as dev;

import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:image/image.dart' as imglib;

import 'package:tflite_flutter/tflite_flutter.dart';

import 'database.dart';

imglib.Image? convertToImage(CameraImage image) {
  if (image.format.group == ImageFormatGroup.yuv420) {
    return _convertYUV420(image);
  } else if (image.format.group == ImageFormatGroup.bgra8888) {
    return _convertBGRA8888(image);
  } else {
    return null;
  }
}

imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    image.width,
    image.height,
    image.planes[0].bytes,
    format: imglib.Format.bgra,
  );
}

imglib.Image _convertYUV420(CameraImage image) {
  int width = image.width;
  int height = image.height;
  var img = imglib.Image(width, height);
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      img.data[index] = hexFF | (b << 16) | (g << 8) | r;
    }
  }

  return img;
}

class PredictedUserData {
  User? predictedUser;
  double? userDistance;

  PredictedUserData({required this.predictedUser, required this.userDistance});
}

class MLService {
  late Interpreter interpreter;
  double threshold = 0.5;

  List _predictedArray = [];
  List get predictedArray => _predictedArray;

  List predictFace(CameraImage image, Face? face) {
    if (face == null) throw Exception("No face detected");
    List input = _preProcess(image, face);
    input = input.reshape([1, 112, 112, 3]);

    List output = List.generate(1, (index) => List.filled(192, 0));

    interpreter.run(input, output);
    output = output.reshape([192]);

    _predictedArray = List.from(output);
    return _predictedArray;
  }

  List predictFaceFile(String image, Face? face) {
    if (face == null) throw Exception("No face detected");
    List input = _preProcessFile(image, face);
    input = input.reshape([1, 112, 112, 3]);

    List output = List.generate(1, (index) => List.filled(192, 0));

    interpreter.run(input, output);
    output = output.reshape([192]);

    _predictedArray = List.from(output);
    return _predictedArray;
  }

  PredictedUserData findUsersFace(List predictedData) {
    User? user = LocalDB.getUser();
    double curDist = 0.0;
    User? predictedResult;

    curDist = euclideanDistance(user.key!, predictedData);
    dev.log("curDist: $curDist");
    if (curDist <= threshold) {
      predictedResult = user;
      return PredictedUserData(
          predictedUser: predictedResult, userDistance: curDist);
    } else {
      return PredictedUserData(predictedUser: null, userDistance: curDist);
    }
  }

  euclideanDistance(List l1, List l2) {
    double sum = 0;
    for (int i = 0; i < l1.length; i++) {
      sum += pow((l1[i] - l2[i]), 2);
    }
    return sqrt(sum);
  }

  Future initialize() async {
    late Delegate delegate;
    if (io.Platform.isAndroid) {
      delegate = GpuDelegateV2(
        options: GpuDelegateOptionsV2(
          isPrecisionLossAllowed: false,
          inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
          inferencePriority1: TfLiteGpuInferencePriority.maxPrecision,
          inferencePriority2: TfLiteGpuInferencePriority.minLatency,
          inferencePriority3: TfLiteGpuInferencePriority.auto,
        ),
      );
    } else if (io.Platform.isIOS) {
      delegate = GpuDelegate(
        options: GpuDelegateOptions(
            allowPrecisionLoss: true, waitType: TFLGpuDelegateWaitType.active),
      );
    }
    var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

    interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
        options: interpreterOptions);
  }

  List _preProcess(CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  List _preProcessFile(String image, Face faceDetected) {
    imglib.Image croppedImage = _cropFaceFile(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  imglib.Image _cropFaceFile(String image, Face faceDetected) {
    imglib.Image convertedImage = _convertPathImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img!, -90);
    return img1;
  }

  imglib.Image _convertPathImage(String image) {
    var img = imglib.decodeImage(io.File(image).readAsBytesSync());
    return img!;
  }

  Float32List _imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(i, j);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }
}
