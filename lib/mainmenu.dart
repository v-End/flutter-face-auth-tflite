// ignore: unused_import
import 'dart:developer';

import 'package:facial_recog1/homemenu.dart';
import 'package:flutter/material.dart';

import 'cameraservice.dart';
import 'cameraview.dart';
import 'database.dart';
import 'galleryview.dart';
import 'mlservice.dart';
import 'servicelocator.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  final CameraService _cameraService = serviceLocator<CameraService>();
  final MLService _mlService = serviceLocator<MLService>();

  bool initializing = false;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  void loadServices() async {
    if (mounted) {
      setState(() => initializing = true);
      await _cameraService.initialize();
      await _mlService.initialize();
      setState(() => initializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    late Widget body;

    if (!initializing) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.blueGrey),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogInMenu(),
                      ),
                    );
                  },
                  child: const Text('Log In'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.blue),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterMenu(),
                      ),
                    );
                  },
                  child: const Text('Register'),
                ),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.grey),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraViewing(
                          title: "Camera Test",
                          testing: true,
                        ),
                      ),
                    );
                  },
                  child: const Text('Camera Test'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.grey),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GalleryView(),
                      ),
                    );
                  },
                  child: const Text('Gallery'),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
        appBar: AppBar(title: const Text('Facial Recognition Test')),
        body: Stack(
          children: [
            body,
          ],
        ));
  }
}

class LogInMenu extends StatefulWidget {
  const LogInMenu({Key? key}) : super(key: key);

  @override
  LogInMenuState createState() => LogInMenuState();
}

class LogInMenuState extends State<LogInMenu> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log In")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                labelText: "Username",
              ),
              autovalidateMode: AutovalidateMode.always,
              validator: (String? idValue) {
                return (idValue != null &&
                        idValue.contains(RegExp(r'[^a-zA-Z0-9]'))
                    ? "Use letters and numbers only."
                    : null);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TextFormField(
              controller: passController,
              decoration: const InputDecoration(
                icon: Icon(Icons.lock),
                labelText: "Password",
              ),
              obscureText: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.green),
              child: TextButton(
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  if (nameController.value.text == LocalDB.getUserName() &&
                      passController.value.text == LocalDB.getUserPass()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeMenu(),
                      ),
                    );
                  }
                },
                child: const Text("Log In"),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.blue),
              child: TextButton(
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraViewing(
                        title: "Log In",
                        testing: false,
                      ),
                    ),
                  );
                },
                child: const Text("Log In with Face"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterMenu extends StatefulWidget {
  const RegisterMenu({Key? key}) : super(key: key);

  @override
  RegisterMenuState createState() => RegisterMenuState();
}

class RegisterMenuState extends State<RegisterMenu> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                labelText: "Username",
              ),
              autovalidateMode: AutovalidateMode.always,
              validator: (String? idValue) {
                return (idValue != null &&
                        idValue.contains(RegExp(r'[^a-zA-Z0-9]'))
                    ? "Use letters and numbers only."
                    : null);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TextFormField(
              controller: passController,
              decoration: const InputDecoration(
                icon: Icon(Icons.lock),
                labelText: "Password",
              ),
              obscureText: true,
              autovalidateMode: AutovalidateMode.always,
              validator: (String? passValue) {
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.green),
              child: TextButton(
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  (nameController.value.text.isNotEmpty &&
                          passController.value.text.isNotEmpty)
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraViewing(
                              title: "Registration",
                              username: nameController.value.text,
                              password: passController.value.text,
                              testing: true,
                            ),
                          ),
                        )
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Please enter a Username and Password."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                },
                child: const Text("Register"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
