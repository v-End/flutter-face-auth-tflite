// ignore: unused_import
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:facial_recog1/homemenu.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:flutter/material.dart';

import 'cameraservice.dart';
import 'database.dart';
import 'facedetector.dart';
import 'servicelocator.dart';
import 'mlservice.dart';

class CameraViewing extends StatefulWidget {
  const CameraViewing(
      {Key? key,
      this.title = "Title",
      this.username = "",
      this.password = "",
      this.testing = true})
      : super(key: key);

  final bool testing;
  final String title;
  final String username;
  final String password;

  @override
  State<CameraViewing> createState() => CameraViewingState();
}

class CameraViewingState extends State<CameraViewing> {
  Face? _faceDetected;
  Size? _imageSize;

  bool frontCamera = true;
  bool changingCamera = false;
  bool _initializing = false;
  bool _detectingFaces = false;
  bool _livenessChecking = false;
  bool _livenessSuccess = false;
  bool _alertShown = false;

  List<double> classValues = [];
  List<List<double>> faceClass = [];
  int classIndex = 0;

  List faceResultList = [];
  PredictedUserData? predUserData;

  double testThreshold = 0.05;
  int testFrames = 15;

  final FaceDetectorService _faceDetectorService =
      serviceLocator<FaceDetectorService>();
  final CameraService _cameraService = serviceLocator<CameraService>();
  final MLService _mlService = serviceLocator<MLService>();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    if (mounted) {
      _cameraService.dispose();
      super.dispose();
    }
  }

  _initCamera({CameraLensDirection camDir = CameraLensDirection.back}) async {
    if (mounted) {
      setState(() => _initializing = true);
      await _cameraService.initialize(camDir: camDir);
      setState(() => _initializing = false);
    }

    _performDetection();
  }

  _performDetection() {
    if (mounted) {
      _imageSize = _cameraService.getImageSize();

      _cameraService.cameraController?.startImageStream(
        (image) async {
          if (_cameraService.cameraController != null) {
            if (_detectingFaces) return;

            _detectingFaces = true;

            try {
              await _faceDetectorService.processCameraImage(image);

              if (_faceDetectorService.faces.isNotEmpty) {
                setState(() {
                  _faceDetected = _faceDetectorService.faces.first;
                });
                _livenessTest(image);
              } else {
                setState(() {
                  _faceDetected = null;
                });
              }

              _detectingFaces = false;
            } catch (e) {
              print(e);
              _detectingFaces = false;
            }
          }
        },
      );
    }
  }

  _livenessTest(CameraImage image) async {
    if (_livenessChecking) {
      if (classIndex < testFrames) {
        dev.log("Index: $classIndex");
        classValues.add(_faceDetected!.rightEyeOpenProbability!);
        classIndex++;
        if (!widget.testing) {
          if (_stdDeviation(classValues) > testThreshold) {
            _livenessSuccess = true;
          } else {
            _livenessSuccess = false;
          }
        } else {
          _livenessSuccess = true;
        }
        if (classIndex == testFrames) {
          if (_livenessSuccess) {
            faceResultList = _mlService.predictFace(image, _faceDetected);
            if (widget.username.isEmpty || widget.password.isEmpty) {
              predUserData = _mlService.findUsersFace(faceResultList);
              dev.log("List: $predUserData");
            }
            _snackBarWarning(message: "Liveness test successful.");
          } else {
            _snackBarWarning(message: "Liveness test failed, try blinking.");
          }
          dev.log("List: $faceResultList");
          _livenessChecking = false;
          dev.log("Value: $classValues");
        }
      }
    }
  }

  _stdDeviation(List<double> inputData) {
    double mean = inputData.reduce((v, e) => v + e) / inputData.length;
    double sum = 0;
    for (var e in inputData) {
      sum += math.pow(e - mean, 2);
    }

    dev.log("SD: ${math.sqrt(sum / inputData.length)}");
    return math.sqrt(sum / inputData.length);
  }

  @override
  Widget build(BuildContext context) {
    late Widget body;

    if (!_initializing) {
      body = Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CameraPreview(_cameraService.cameraController!),
              CustomPaint(
                painter: FaceDetectorPainter(
                  face: _faceDetected,
                  absoluteImageSize: _imageSize!,
                  userDist: predUserData?.userDistance,
                ),
              ),
              (classIndex < testFrames)
                  ? Center(
                      child: CircularProgressIndicator(
                        value: classIndex / testFrames,
                      ),
                    )
                  : Container(),
              _predictButton(),
            ],
          ),
        ),
      );
    } else {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          body,
          flipCamera(),
        ],
      ),
    );
  }

  Widget _predictButton() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 48),
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: (_livenessSuccess && !_livenessChecking)
                    ? (widget.username.isNotEmpty && widget.password.isNotEmpty)
                        ? () {
                            LocalDB.setUserDetails(
                              User(
                                name: widget.username,
                                pass: widget.password,
                                key: faceResultList,
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeMenu(),
                              ),
                            );
                          }
                        : () {
                            if (!widget.testing) {
                              if (predUserData?.predictedUser != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeMenu(),
                                  ),
                                );
                              } else {
                                _snackBarWarning(
                                    message: "Unable to recognize face.");
                              }
                            } else {
                              dev.log("User: ${predUserData?.predictedUser}");
                            }
                          }
                    : null,
                child: const Text('Predict'),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 48),
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: _livenessChecking
                    ? null
                    : _alertShown
                        ? () => {
                              _livenessChecking = true,
                              classValues.clear(),
                              classIndex = 0,
                            }
                        : () => showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Liveness Test"),
                                  content: const Text(
                                      "Try blinking once or twice for the duration of the test."),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => {
                                        _alertShown = true,
                                        Navigator.of(context).pop(),
                                        _livenessChecking = true,
                                        classValues.clear(),
                                        classIndex = 0,
                                      },
                                      child: const Text("Understood"),
                                    )
                                  ],
                                );
                              },
                            ),
                child: const Text('Test'),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget flipCamera() {
    return Container(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 128, 16, 16),
        child: FloatingActionButton(
          onPressed: () => changingCamera ? null : _switchCameraMode(),
          child: const Icon(Icons.flip_camera_android),
        ),
      ),
    );
  }

  Future _switchCameraMode() async {
    if (mounted && !_initializing) {
      _initializing = true;
      if (_cameraService.cameraController?.description.lensDirection ==
          CameraLensDirection.front) {
        frontCamera = true;
      } else {
        frontCamera = false;
      }
      await _cameraService.dispose();
      if (frontCamera) {
        await _initCamera(camDir: CameraLensDirection.back);
      } else {
        await _initCamera(camDir: CameraLensDirection.front);
      }
      _initializing = false;
    }
  }

  _snackBarWarning({String message = "Message", duration = 2}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }
}
