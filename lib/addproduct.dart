import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:raindrops_vendor/addcategory.dart';
import 'package:raindrops_vendor/viewproducts.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Add_Product extends StatefulWidget {
  const Add_Product({super.key});

  @override
  State<Add_Product> createState() => _Add_ProductState();
}

class _Add_ProductState extends State<Add_Product> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController stockController = TextEditingController();

  TextEditingController attributeValueController = TextEditingController();

  TextEditingController variantnameController = TextEditingController();
  TextEditingController variantpriceController = TextEditingController();
  TextEditingController variantsalePriceController = TextEditingController();
  TextEditingController variantdescriptionController = TextEditingController();
  TextEditingController variantattributeValueController = TextEditingController();

  TextEditingController variantstockController = TextEditingController();

  List<dynamic> categories = [];
  List<String> typeOptions = ["single", "variant"];
  List<String> attributes = ["weight", "liter", "piece"];

  String? selectedType;
  String? selectedCategoryId;
  String? selectedAttribute;

  final String baseUrl = "https://sphere-o-earthquake-illinois.trycloudflare.com";

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage1;

  @override
  void initState() {
    super.initState();
    getcategory();
    getCompanyIdFromToken();
  }
  

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImage1() async {  
    final pickedFile1 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile1 != null) {
      setState(() {
        _selectedImage1 = File(pickedFile1.path);
      });
    }
  }


  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs);

    return prefs.getString('token');
  }

  Future<void> getcategory() async {
    try {
      final token = await gettokenFromPrefs();
      print(token);
      final String url = "$baseUrl/api/category";
      print("Requesting URL: $url");

      final response = await http.get(Uri.parse(url), headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] is List) {
          setState(() {
            categories = responseData['data'];
          });
          print("Categories fetched successfully: $categories");
        } else {
          print("Failed to parse categories: ${responseData['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to parse category data')),
          );
        } 
      } else {
        print(
            "Failed to fetch categories. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch categories')),
        );
      }
    } catch (error) {
      print("An error occurred while fetching categories: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

Future<String?> getCompanyIdFromToken() async {
  // Get the token from SharedPreferences or any other source
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    print('Token is missing');
    return null;
  }

  try {
    // Decode the JWT
    final jwt = JWT.decode(token);

    print("=========>>>>>>>>>..$jwt");

    // Extract the payload
    final payload = jwt.payload;

    print("ppppppppppppyyyyyyyyyyyyyyyy$payload");

    String? companyId = payload['userId'];

    print(companyId);

    if (companyId != null) {
      print('Company ID: $companyId');
    } else {
      print('Company ID not found in token');
    }

    return companyId;
  } catch (e) {
    print('Error decoding token: $e');
    return null;
  }
}

  Future<void> addProduct() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        salePriceController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedType == null ||
        selectedCategoryId == null ||
        _selectedImage == null ||
        selectedAttribute == null ||
        attributeValueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    try {
      var slug = nameController.text.toUpperCase().replaceAll(' ', '-');
      final token = await getTokenFromPrefs();
        String? companyId = await getCompanyIdFromToken();

    if (companyId == null || companyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company ID is required')),
      );
      return;
    }
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/api/add-product"),
      );

      request.headers['Authorization'] = '$token';
      request.fields['name'] = nameController.text;
      request.fields['slug'] = slug;
      request.fields['price'] = priceController.text;
      request.fields['sale_price'] = salePriceController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['type'] = selectedType!;
      request.fields['category'] = selectedCategoryId!;
      request.fields['stock'] = stockController.text;
       request.fields['companyId'] = companyId; 

   Map<String, String> attributeMap = {
  'type': selectedAttribute!, 
  'value': attributeValueController.text,
};
request.fields['productAttribute'] = json.encode(attributeMap);


      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        ),
      );

      if (selectedType == "variant") {
        if (variantnameController.text.isEmpty ||
            variantsalePriceController.text.isEmpty ||
            variantdescriptionController.text.isEmpty ||
            variantattributeValueController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill all variant fields')),
          );
          return;
        }
      var slug = variantnameController.text.toUpperCase().replaceAll(' ', '-');

        List<Map<String, dynamic>> variantList = [
          {
            'slug':slug,
            'name': variantnameController.text,
            'sale_price': variantsalePriceController.text,
            'description': variantdescriptionController.text,
            'stock':variantstockController.text,
            'productAttribute': {
              'type': selectedAttribute,
              'value': variantattributeValueController.text,
            }
          }
        ];

        print("yoooooooo================$variantList");
         request.fields['variants[]'] = json.encode(variantList);  

        print("Request Body: ${json.encode(variantList)}");


        // if (_selectedImage1 != null) {
        //   request.files.add(
        //     await http.MultipartFile.fromPath(
        //       'image',
        //       _selectedImage1!.path,
        //     ),
        //   );
        // }
        // print("Selected Variant Image: ${_selectedImage1?.path}");

      }

      var response = await request.send();

      print("-------------------$response");

      final responseBody = await response.stream.bytesToString();

      print("=======================$responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: Text('Product added successfully')),
        );

        setState(() {
          nameController.clear();
          priceController.clear();
          salePriceController.clear();
          descriptionController.clear();
          stockController.clear();
          selectedType = null;
          selectedCategoryId = null;
          selectedAttribute = null;
          attributeValueController.clear();
          _selectedImage = null;
          variantnameController.clear();
          variantsalePriceController.clear();
          variantdescriptionController.clear();
          variantattributeValueController.clear();
          variantstockController.clear();
          _selectedImage1 = null;
        });

        print("Add Product Response: $responseBody");
      } else {
        print("Failed to add product. Status: ${response.statusCode}");
        print("Response: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product')),
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
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['_id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: stockController,
                      decoration: InputDecoration(
                        labelText: 'Stock',
                        hintText: 'Enter stock quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
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
                        height: 50,
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
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      items: typeOptions.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value;
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
                    if (selectedType == "variant")
                      Column(
                        children: [
                          Text(
                            "Enter Variant Product Details",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: variantnameController,
                            decoration: InputDecoration(
                              labelText: 'Variant Name',
                              hintText: 'Enter variant name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: variantsalePriceController,
                            decoration: InputDecoration(
                              labelText: 'Variant Sale Price',
                              hintText: 'Enter sale price',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16),
                           TextField(
                            controller: variantstockController,
                            decoration: InputDecoration(
                              labelText: 'Variant Stock',
                              hintText: 'Enter Variant Stock',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: variantdescriptionController,
                            decoration: InputDecoration(
                              labelText: 'Variant Description',
                              hintText: 'Enter variant Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   height: 16,
                          // ),
                          // GestureDetector(
                          //   onTap: _pickImage1,
                          //   child: Container(
                          //     width: double.infinity,
                          //     height: 50,
                          //     decoration: BoxDecoration(
                          //       border: Border.all(color: Colors.grey),
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //     child: _selectedImage1 != null
                          //         ? Image.file(
                          //             _selectedImage1!,
                          //             fit: BoxFit.cover,
                          //           )
                          //         : Center(
                          //             child: Text(
                          //               'Tap to add an image',
                          //               style: TextStyle(color: Colors.grey),
                          //             ),
                          //           ),
                          //   ),
                          // ),
                          SizedBox(height: 16),
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
                            controller: variantattributeValueController,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  addProduct();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white, 
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text("Add Variant"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ElevatedButton(
                      onPressed: addProduct,
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
