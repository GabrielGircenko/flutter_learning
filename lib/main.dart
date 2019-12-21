import 'package:flutter/material.dart';
import 'package:flutter_learning/screens/sub_priorities.dart';

double _padding = 16;
double _halfPadding = 8;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NoteKeeper",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple
      ),
      home: SubPriorities(),
    );
  }
}