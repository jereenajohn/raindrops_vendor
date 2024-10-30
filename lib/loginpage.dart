import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:raindrops_vendor/api.dart';
import 'package:raindrops_vendor/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool _validateFields() {
    if (email.text.isEmpty || password.text.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> storeUserData(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> VendorLogin() async {
    try {
      var response = await http.post(
        Uri.parse('$url/api/login'),
        body: {"email": email.text, "password": password.text},
      );

      print("RRRRRRRREEEEEEEEEEEEEWWWWWWWWWWWWWWWWWWWWWWW${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        print("AAAAAAAAAAAAAAAAAA========$responseData");

        var status = responseData['message'];

        print("---------$status");

        if (status == 'Login successful') {
          var token = responseData['token'];

          print(token);

          await storeUserData(token);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Login successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          // Show snackbar for failed login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Check your email or password'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (response.statusCode == 401) {
        // Show a generic error message for unauthorized access (401)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Check your email or password'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Show a generic error message for other HTTP errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Something went wrong. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show snackbar for exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Welcome Back',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),

              SizedBox(height: 20),

              // Email Input
              Container(
                height: 45,
                child: TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: 'Enter Email',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              Container(
                height: 45,
                child: TextField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: 'Enter Paasword',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                ),
              ),

              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_validateFields()) {
                      VendorLogin();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please fill all the fields"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
