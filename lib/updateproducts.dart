import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:raindrops_vendor/addcategory.dart';
import 'package:raindrops_vendor/api.dart';
import 'package:raindrops_vendor/viewproducts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class Update_Product extends StatefulWidget {
  final String id;
  const Update_Product({super.key, required this.id});

  @override
  State<Update_Product> createState() => _Update_ProductState();
}

class _Update_ProductState extends State<Update_Product> {
  // Controllers for TextFields
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController attributeValueController = TextEditingController();

  List<dynamic> categories = [];
  List<String> typeOptions = ["single", "variant"];
  List<String> attributes = ["weight", "liter", "piece"];

  final String baseUrl = "https://plays-amplifier-das-ooo.trycloudflare.com";
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
    String? _imageUrl; // Variable to hold the image URL


  String? selectedType;
  String? selectedCategoryId;
  String? selectedAttribute;
  String? selectedCategoryName;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    print("QQQQQQQQQQQQ=====================${widget.id}");
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }Future<void> fetchProductDetails() async {
  try {
    final token = await getTokenFromPrefs();
    final response = await http.get(
      Uri.parse('$baseUrl/api/product/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('$baseUrl/api/product/${widget.id}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> productList = responseData['data'];

      // Find the product with the matching ID
      final productData = productList.firstWhere(
        (product) => product['_id'] == widget.id,
        orElse: () => null,
      );

      if (productData != null) {
        setState(() {
          nameController.text = productData['name'] ?? '';
          priceController.text = productData['price'].toString();
          salePriceController.text = productData['sale_price'].toString();
          descriptionController.text = productData['description'] ?? '';
          stockController.text = productData['stock']?.toString() ?? '';
          selectedCategoryId = productData['category'];
          selectedType = productData['type'];
          selectedAttribute = productData['selectedAttribute']?['type'];
          selectedCategoryName = productData['categoryname'];

          // Construct the full image URL
          if (productData['image'] != null) {
            _imageUrl = productData['image'] != null
                  ? "$baseUrl/${productData['image']}".replaceAll("public/", "")
                  : null; 
          }

          print( "00000000============$baseUrl/${productData['image']}");
        });

        // Fetch categories if needed
        getcategory();
      } else {
        print('No product found with the matching ID');
      }
    } else {
      throw Exception('Failed to load product details');
    }
  } catch (error) {
    print('Error fetching product details: $error');
  }
}

  Future<void> getcategory() async {
    try {
      final String url = "$baseUrl/api/category";
      print("Requesting URL: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] is List) {
          setState(() {
            categories = responseData['data'];
          });
          print("Categories fetched successfully: $categories");

          findCategoryName();
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

  void findCategoryName() {
    final category = categories.firstWhere(
      (category) => category['_id'] == selectedCategoryId,
      orElse: () => null,
    );

    if (category != null) {
      setState(() {
        selectedCategoryName = category['name'];
      });
    }
  }

  
  Future<void> updateproduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty || salePriceController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please update all fields')),
      );
      return;
    }

    try {
            final token = await getTokenFromPrefs();

      var slug = nameController.text.toUpperCase().replaceAll(' ', '-');

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse("$url/api/vendor/update-product/${widget.id}"),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = nameController.text;
      request.fields['slug'] = slug;
      request.fields['price'] = priceController.text;
      request.fields['sale_price'] = salePriceController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['stock'] = stockController.text;
      request.fields['type'] = selectedType!;
      request.fields['category'] = selectedCategoryId!;


      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _selectedImage!.path,
          ),
        );
      }

      var response = await request.send();

      // Get the response body
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: Text('Product updated successfully')),
        );

        print("Update response: $responseBody");

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => View_Products()));
      } else {
        print("Update failed with status: ${response.statusCode}");
        print("Response: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product')),
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
        title: Text('Update Product'),
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
                            : _imageUrl != null
                                ? Image.network(
                                    _imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.broken_image,
                                          color: Colors.grey);
                                    },
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
                      onPressed: updateproduct,
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
