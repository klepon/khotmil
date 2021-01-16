import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khotmil/constant/text.dart';
import 'package:khotmil/widget/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: AppTitle,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Color(int.parse('0xff092128')),
      ),
      home: Auth(),
    );
  }
}
