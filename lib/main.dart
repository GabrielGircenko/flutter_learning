import 'package:flutter/material.dart';
import 'package:priority_keeper/screens/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PriorityKeeper",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light, primaryColor: Colors.blue
          // orange: #F79420
          // blue: #00223D
          ),
      darkTheme: ThemeData.dark(),
      home: Home(),
    );
  }
}
