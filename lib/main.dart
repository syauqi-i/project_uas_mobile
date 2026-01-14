import 'package:flutter/material.dart';
import 'package:project_uas/pages/login_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: LoginPage(),
      theme: ThemeData(primarySwatch: Colors.blueGrey),
    );
  }
}
