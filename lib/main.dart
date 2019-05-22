import 'package:flutter/material.dart';

import 'app_screens/first_screen.dart';

void main() =>
  runApp(
    MyFlutterApp()
  );


class MyFlutterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: "Hello World Flutter App",
        home: Scaffold(
          appBar: AppBar(title: Text("My First App"),),
          body: FirstScreen(),
        )
    );
  }

}
