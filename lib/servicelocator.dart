import 'package:get_it/get_it.dart';

import 'cameraservice.dart';
import 'facedetector.dart';
import 'mlservice.dart';

final serviceLocator = GetIt.instance;

void setupServices() {
  serviceLocator.registerLazySingleton<CameraService>(() => CameraService());
  serviceLocator
      .registerLazySingleton<FaceDetectorService>(() => FaceDetectorService());
  serviceLocator.registerLazySingleton<MLService>(() => MLService());
}
