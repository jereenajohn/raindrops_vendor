import 'package:flutter/material.dart';
import 'package:raindrops_vendor/homepage.dart';
import 'package:raindrops_vendor/loginpage.dart';
import 'package:raindrops_vendor/registeration_page.dart';

void main()
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

