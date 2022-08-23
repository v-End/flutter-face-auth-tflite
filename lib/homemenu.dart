import 'package:flutter/material.dart';

import 'database.dart';
import 'mainmenu.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello, ${LocalDB.getUserName()}.")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
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
          ],
        ),
      ),
    );
  }
}
