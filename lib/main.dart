import 'package:facial_recog1/database.dart';

import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'mainmenu.dart';
import 'servicelocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServices();

  await Hive.initFlutter();

  await HiveBoxes.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.system,
      home: MainMenu(),
    );
  }
}
