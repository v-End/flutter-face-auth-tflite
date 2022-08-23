// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';

import 'package:flutter/material.dart';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import 'package:image_picker/image_picker.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  InputImageRotation? _inputImageRotation;
  InputImageRotation? get inputImageRotation => _inputImageRotation;

  String? _imagePath;
  String? get imagePath => _imagePath;

  ImagePicker? _imagePicker;
  ImagePicker? get imagePicker => _imagePicker;

  File? _imageFile;
  File? get imageFile => _imageFile;

  Future<void> initialize(
      {CameraLensDirection camDir = CameraLensDirection.front}) async {
    if (_cameraController != null) return;
    CameraDescription description = await _getCameraDescription(camDir: camDir);
    await _setupCameraController(description: description);
    _inputImageRotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );
  }

  Future<CameraDescription> _getCameraDescription(
      {CameraLensDirection camDir = CameraLensDirection.front}) async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == camDir);
  }

  Future _setupCameraController({
    required CameraDescription description,
  }) async {
    _cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController?.initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<XFile?> takePicture() async {
    await _cameraController?.stopImageStream();
    XFile? file = await _cameraController?.takePicture();
    _imagePath = file?.path;
    return file;
  }

  Size getImageSize() {
    return Size(
      _cameraController!.value.previewSize!.height,
      _cameraController!.value.previewSize!.width,
    );
  }

  Future dispose() async {
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
  }
}
