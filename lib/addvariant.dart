import 'package:flutter/material.dart';
import 'package:raindrops_vendor/addcategory.dart';
import 'package:raindrops_vendor/api.dart';
import 'package:raindrops_vendor/viewproducts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Add_Variant extends StatefulWidget {
  final String id;
  const Add_Variant({super.key, required this.id});

  @override
  State<Add_Variant> createState() => _Add_VariantState();
}

class _Add_VariantState extends State<Add_Variant> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController stockController = TextEditingController();

  TextEditingController attributeValueController = TextEditingController();

  List<dynamic> categories = [];
  List<String> attributes = ["weight", "liter", "piece"];

  String? selectedCategoryId;
  String? selectedAttribute;

  final String baseUrl = "https://plays-amplifier-das-ooo.trycloudflare.com";

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    print("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT${widget.id}");
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
Future<void> AddVariantProduct() async {
  if (nameController.text.isEmpty ||

      salePriceController.text.isEmpty ||
      descriptionController.text.isEmpty ||
      _selectedImage == null ||
      selectedAttribute == null ||
      attributeValueController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all fields and select an image')),
    );
    return;
  }

  try {
    final token = await getTokenFromPrefs();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$url/api/add-product"),
    );

    request.headers['Authorization'] = 'Bearer $token';


    Map<String, dynamic> variants = {
      'name': nameController.text,
      'sale_price': salePriceController.text,
      'description': descriptionController.text,
      'selectedAttribute': {
        'type': selectedAttribute,
        'value': attributeValueController.text,
      },
    };

    request.fields['variants'] = json.encode(variants);

    print("VAAAAAARRRRRRRRRRRRRRRRRRR$variants");

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,

      ),
    );

    var response = await request.send();

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.green,
            content: Text('Product added successfully')),
      );

      setState(() {
        nameController.clear();
        salePriceController.clear();
        descriptionController.clear();
        stockController.clear();
        selectedAttribute = null;
        attributeValueController.clear();
        _selectedImage = null;
      });

      print("Add Product Response: $responseBody");
    } else {
      print("Failed to add Variant product. Status: ${response.statusCode}");
      print("Response: $responseBody");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add variant product')),
      );
    }
  } catch (error) {
    print("Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $error')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
      
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: const Text('Add Category'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Add_Category()));
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: const Text('Add Category'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => View_Products()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_page),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'Enter product name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        hintText: 'Enter price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: salePriceController,
                      decoration: InputDecoration(
                        labelText: 'Sale Price',
                        hintText: 'Enter sale price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                   
                    // TextField(
                    //   controller: stockController,
                    //   decoration: InputDecoration(
                    //     labelText: 'Stock',
                    //     hintText: 'Enter stock quantity',
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    //   keyboardType: TextInputType.number,
                    // ),
                    // SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedAttribute,
                      items: attributes.map((attribute) {
                        return DropdownMenuItem<String>(
                          value: attribute,
                          child: Text(attribute),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAttribute = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Attribute',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: attributeValueController,
                      decoration: InputDecoration(
                        labelText: 'Attribute Value',
                        hintText: 'Enter value for selected attribute',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  'Tap to add an image',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: AddVariantProduct,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      child: Text("Submit"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
