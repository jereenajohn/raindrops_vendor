import 'package:flutter/material.dart';
import 'package:raindrops_vendor/homepage.dart';
import 'package:raindrops_vendor/registeration_page2.dart';

class Registeration extends StatefulWidget {
  const Registeration({super.key});

  @override
  State<Registeration> createState() => _RegisterationState();
}

class _RegisterationState extends State<Registeration> {
  TextEditingController companyname = TextEditingController();
  TextEditingController fssailicense = TextEditingController();
  TextEditingController gstno = TextEditingController();
  TextEditingController contactnumber = TextEditingController();
  TextEditingController email = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool _validateFields() {
    if (companyname.text.isEmpty ||
        fssailicense.text.isEmpty ||
        gstno.text.isEmpty ||
        contactnumber.text.isEmpty ||
        email.text.isEmpty) {
      return false;
    }
    return true;
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
                  controller: companyname,
                  decoration: InputDecoration(
                    labelText: 'Enter Company Name',
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
                  controller: fssailicense,
                  decoration: InputDecoration(
                    labelText: 'Enter fassai license',
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
                  controller: gstno,
                  decoration: InputDecoration(
                    labelText: 'Enter gstno',
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
                  controller: contactnumber,
                  decoration: InputDecoration(
                    labelText: 'Enter Contact Number',
                    prefixIcon: Icon(Icons.contact_emergency),
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
                  controller: email,
                  decoration: InputDecoration(
                    labelText: 'Enter Email',
                    prefixIcon: Icon(Icons.email),
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
                      // Navigate to the next page if all fields are filled
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Register_Page_two(
                              c_name: companyname.text,
                              f_license: fssailicense.text,
                              gst: gstno.text,
                              phone: contactnumber.text,
                              email: email.text),
                        ),
                      );
                    } else {
                      // Show an error message if any field is empty
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
