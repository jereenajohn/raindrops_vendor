import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:raindrops_vendor/addcategory.dart';
import 'package:raindrops_vendor/addproduct.dart';
import 'package:raindrops_vendor/addvariant.dart';
import 'package:raindrops_vendor/api.dart';
import 'package:http/http.dart' as http;
import 'package:raindrops_vendor/homepage.dart';
import 'package:raindrops_vendor/updateproducts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class View_Products extends StatefulWidget {
  const View_Products({super.key});

  @override
  State<View_Products> createState() => _View_ProductsState();
}

class _View_ProductsState extends State<View_Products> {
  List<Map<String, dynamic>> viewproducts = [];
  List<bool> toggleStates = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchProducts() async {
    try {
      final token = await getTokenFromPrefs();

      final response = await http.get(
        Uri.parse('$url/api/vendor-product'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsData = jsonDecode(response.body)['data'];

        List<Map<String, dynamic>> productsList = [];

        for (var productData in productsData) {
          String imageUrl =
              "https://solution-doors-annual-modes.trycloudflare.com/${productData['image']}";

          productsList.add({
            '_id': productData['_id'],
            'name': productData['name'],
            'price': productData['price'],
            'sale_price': productData['sale_price'],
            'image': imageUrl,
            'isActive': productData['isActive'],
            'type': productData['type']
          });
        }

        setState(() {
          viewproducts = productsList;
          print("viewwwwwwwwwwwwwww$viewproducts");
          toggleStates = List<bool>.filled(productsList.length, true);
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  void toggleSwitch(int index, var id) async {
    // Update the isActive status immediately
    bool newStatus = !viewproducts[index]['isActive'];
    setState(() {
      viewproducts[index]['isActive'] = newStatus;
    });

    // Update the isActive status in the backend
    await updateProductStatus(index, newStatus, id);
  }

  Future<void> updateProductStatus(int index, bool isActive, var id) async {
    try {
      final token = await getTokenFromPrefs();
      final productId =
          viewproducts[index]['id']; // Assuming you have an 'id' field
      print("AAAAAAAAAAAAAAAAAAAAAAA$isActive");
      print('$url/vendor/update-product/$id');
      var response = await http.put(
        Uri.parse('$url/vendor/update-product/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'isActive': isActive,
        }),
      );
      print("resssssss${response.body}");

      if (response.statusCode == 200) {
        // Refresh the product list after updating the status
        await fetchProducts();
      } else {
        throw Exception('Failed to update product status');
      }
    } catch (error) {
      print('Error updating product status: $error');
    }
  }

  Future<void> deleteproduct(String id) async {
    try {
      final token = await getTokenFromPrefs();

      final response = await http.delete(
        Uri.parse("$url/api/vendor/product-delete/$id"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("QQQQQQQQQQQQQQQQQQQQWWWWW$url/api/vendor/product-delete/$id");

      print("---------------====--------------${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: Text('Product deleted successfully')),
        );
        fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product')),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Product'),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
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
              title: const Text('Add Product'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Add_Product()));
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
      body: viewproducts.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: viewproducts.length,
              itemBuilder: (context, index) {
                final product = viewproducts[index];
                bool isActive = product['isActive'] ?? true;
                print("iiiiiiiiiiii${product['_id']}");

                return Container(
                  height: 150,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.network(
                            product['image'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Price: \$${product['price']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Sale Price: \$${product['sale_price']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (value) {
                              print("iddddddddddddddddddd${product['_id']}");
                              toggleSwitch(index, product['_id']);
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (product['type'] == "variant")
                              ElevatedButton(
                                onPressed: () {

                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Add_Variant(id:product['_id'])));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .black, 
                                  foregroundColor: Colors
                                      .white, 
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12),
                                  ),
                                ),
                                child: Text("Add Variant"),
                              ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Update_Product(id: product['_id']),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteproduct(product['_id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
