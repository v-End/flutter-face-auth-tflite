// ignore: unused_import
import 'dart:developer';
import 'dart:io';

import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'facedetector.dart';
import 'servicelocator.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({Key? key}) : super(key: key);

  @override
  State<GalleryView> createState() => GalleryViewState();
}

class GalleryViewState extends State<GalleryView> {
  File? _image;
  InputImage? _inputImage;
  var _imageData;
  String? _path;
  ImagePicker? _imagePicker;
  String? text;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery"),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          _image != null
              ? SizedBox(
                  height: 400,
                  width: 400,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.file(_image!),
                    ],
                  ),
                )
              : const Icon(
                  Icons.image,
                  size: 200,
                ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              child: const Text('From Gallery'),
              onPressed: () => _getImage(ImageSource.gallery),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              child: const Text('Take a picture'),
              onPressed: () => _getImage(ImageSource.camera),
            ),
          ),
          _image != null
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: ElevatedButton(
                    child: const Text('Perform Face Detection'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryImageView(
                          path: _path,
                          image: _image,
                          inputImage: _inputImage!,
                          imageData: _imageData,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    }
    setState(() {});
  }

  Future _processPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      _image = File(path);
    });
    _path = path;
    _inputImage = InputImage.fromFilePath(path);
    _imageData = await decodeImageFromList(_image!.readAsBytesSync());
  }
}

class GalleryImageView extends StatefulWidget {
  const GalleryImageView(
      {Key? key,
      required this.path,
      required this.image,
      required this.inputImage,
      required this.imageData})
      : super(key: key);

  final String? path;
  final File? image;
  final InputImage inputImage;
  final imageData;

  @override
  State<GalleryImageView> createState() => GalleryImageViewState();
}

class GalleryImageViewState extends State<GalleryImageView> {
  Face? _faceDetected;
  Size? _imageSize;
  String? text;
  bool _detectingFaces = false;
  final RegExp _regExp = RegExp(r'[^\\\/]+(?=\.[\w]+$)|[^\\\/]+$');

  final FaceDetectorService _faceDetectorService =
      serviceLocator<FaceDetectorService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_regExp.firstMatch(widget.path!)![0]}"),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Image.file(widget.image!),
          ),
          _faceBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 48),
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  child: const Text('Detect'),
                  onPressed: () {
                    _getFaces(widget.inputImage);
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _faceBox() {
    return CustomPaint(
        painter: _faceDetected != null
            ? FaceDetectorPainter(
                face: _faceDetected,
                absoluteImageSize: _imageSize!,
              )
            : null);
  }

  Future _getFaces(InputImage? inputImage) async {
    if (inputImage != null) {
      _imageSize = Size(widget.imageData.width.toDouble(),
          widget.imageData.height.toDouble());

      if (_detectingFaces) return;

      _detectingFaces = true;

      try {
        await _faceDetectorService.processInputImage(inputImage);

        if (_faceDetectorService.faces.isNotEmpty) {
          setState(() {
            _faceDetected = _faceDetectorService.faces.first;
            _snackBarWarning(message: "Face detected.");
          });
        } else {
          setState(() {
            _faceDetected = null;
          });
          _snackBarWarning(message: "Face detected.");
        }

        _detectingFaces = false;
      } catch (e) {
        print(e);
        _detectingFaces = false;
      }
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
