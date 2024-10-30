import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:raindrops_vendor/api.dart';
import 'package:raindrops_vendor/homepage.dart';

class Register_Page_two extends StatefulWidget {
  final c_name;
  final f_license;
  final gst;
  final phone;
  final email;
  const Register_Page_two(
      {super.key,
      required this.c_name,
      required this.f_license,
      required this.gst,
      required this.phone,
      required this.email});

  @override
  State<Register_Page_two> createState() => _Register_Page_twoState();
}

class _Register_Page_twoState extends State<Register_Page_two> {
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();

  TextEditingController district = TextEditingController();
  TextEditingController state = TextEditingController();

  TextEditingController password = TextEditingController();

    List<String> payment = ["weekly",'monthly'];
      String? selectedpayment;



  @override
  void initState() {
    print("=================${widget.c_name}");
    print("=================${widget.f_license}");
    print("=================${widget.gst}");
    print("=================${widget.phone}");
    print("=================${widget.email}");
        print("=================$selectedpayment");


    super.initState();
  }

  bool _validateFields() {
    if (address.text.isEmpty ||
        pincode.text.isEmpty ||
        state.text.isEmpty ||
        district.text.isEmpty ||
        password.text.isEmpty) {
      return false;
    }
    return true;
  }

  void RegisterUserData(
    String address,
    String pincode,
    String state,
    String district,
    String password,
    BuildContext scaffoldContext,
  ) async {
    try {
      print("$url/api/vendor-registration");
      var response = await http.post(Uri.parse("$url/api/vendor-registration"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "company_name": widget.c_name,
            "fssai_license": widget.f_license,
            "gst_number": widget.gst,
            "address": address,
            "pincode": pincode,
            "state": state,
            "district": district,
            "paymentOption":selectedpayment,
            "contact_number": widget.phone,
            "email": widget.email,
            "password": password
          }));

      print("EEEEEEEEERRRRRRRRRRRRRRRRRRR${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text('Registered Successfully.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));

      } else {
        var responseData = jsonDecode(response.body);
        String errorMessage =
            responseData['message'] ?? 'Registration failed. Please try again.';

        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content:
              Text('An error occurred. Please check your internet connection.'),
          backgroundColor: Colors.red,
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
                'Create Your Account',
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
                  controller: address,
                  decoration: InputDecoration(
                    labelText: 'Enter Address',
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
                  controller: pincode,
                  decoration: InputDecoration(
                    labelText: 'Enter pincode',
                    prefixIcon: Icon(Icons.email),
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
                  controller: state,
                  decoration: InputDecoration(
                    labelText: 'Enter State',
                    prefixIcon: Icon(Icons.numbers),
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
                  controller: district,
                  decoration: InputDecoration(
                    labelText: 'Enter district',
                    prefixIcon: Icon(Icons.contact_emergency),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

               DropdownButtonFormField<String>(
                      value: selectedpayment,
                      items: payment.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedpayment = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),



              Container(
                height: 45,
                child: TextField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: 'Enter password',
                    prefixIcon: Icon(Icons.contact_emergency),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
                      RegisterUserData(address.text, pincode.text, state.text,
                          district.text, password.text, context);
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
