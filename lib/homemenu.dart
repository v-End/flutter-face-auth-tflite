import 'package:flutter/material.dart';

import 'cameraview.dart';
import 'database.dart';
import 'galleryview.dart';
import 'mainmenu.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, ${LocalDB.getUserName()}."),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.05),
                SizedBox(
                  width: screenWidth * 0.8,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.green),
                    child: TextButton(
                      style: TextButton.styleFrom(primary: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainMenu(),
                          ),
                        );
                      },
                      child: const Text("Log Out"),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                SizedBox(
                  width: screenWidth * 0.8,
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
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: screenWidth * 0.8,
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
          ),
        ],
      ),
    );
  }
}
