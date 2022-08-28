// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';

import 'cameraservice.dart';
import 'cameraview.dart';
import 'database.dart';
import 'homemenu.dart';
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
  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();

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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    late Widget body;

    if (!initializing) {
      body = Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.05),
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
            SizedBox(height: screenHeight * 0.05),
            SizedBox(
              width: screenWidth * 0.8,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.green),
                child: TextButton(
                  style: TextButton.styleFrom(primary: Colors.white),
                  onPressed: () {
                    if (nameController.value.text.isEmpty ||
                        passController.value.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Error: Please fill in the username and password"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    if (nameController.value.text
                            .contains(RegExp(r'[^a-zA-Z0-9]')) ||
                        passController.value.text
                            .contains(RegExp(r'[^a-zA-Z0-9]'))) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Error: Use letters and numbers only"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    if (nameController.value.text == LocalDB.getUserName() &&
                        passController.value.text == LocalDB.getUserPass()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeMenu(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Error: Wrong username or password"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text("Log In"),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              width: screenWidth * 0.8,
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
            SizedBox(height: screenHeight * 0.05),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterMenu(),
                  ),
                );
              },
              child:
                  const Text("Don't have an account? Click here to register."),
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
        appBar: AppBar(
          title: const Text('Facial Authentication'),
          actions: <Widget>[
            //
          ],
        ),
        body: ListView(
          children: [
            body,
          ],
        ));
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.05),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                SizedBox(height: screenHeight * 0.05),
                SizedBox(
                  width: screenWidth * 0.8,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.green),
                    child: TextButton(
                      style: TextButton.styleFrom(primary: Colors.white),
                      onPressed: () {
                        if (nameController.value.text.isEmpty ||
                            passController.value.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Error: Please fill in the username and password"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        if (nameController.value.text
                                .contains(RegExp(r'[^a-zA-Z0-9]')) ||
                            passController.value.text
                                .contains(RegExp(r'[^a-zA-Z0-9]'))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Error: Use letters and numbers only"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
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
                                  content: Text(
                                      "Please enter a Username and Password."),
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
          ),
        ],
      ),
    );
  }
}
