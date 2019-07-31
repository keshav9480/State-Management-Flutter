import 'package:flutter/material.dart';
import 'package:cropin_flutter/bottom_navigation.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'State Management',
      theme: ThemeData(
      primarySwatch: Colors.green,
      ),
      home: BottomNavigation(),
    );
  }
}