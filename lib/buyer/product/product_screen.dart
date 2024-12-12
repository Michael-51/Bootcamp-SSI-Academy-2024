import 'package:flutter/material.dart';
import 'package:myapp/api/product_api.dart';
import 'package:myapp/api/user_api.dart';
import 'package:myapp/buyer/cart/cart_screen.dart';
import 'package:myapp/model/auth.dart';
import 'package:myapp/model/config.dart';

import 'package:myapp/model/product_model.dart';
import 'package:myapp/model/user_model.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late UserApi userApi;
  late ProductApi productApi;
  late Future<User?> futureUser;
  late Future<List<Product>> futureProduct;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    productApi = ProductApi();
    futureProduct = productApi.getProduct();
    futureUser = UserApi().getUser();
  }

  void _performSearch() {
    setState(() {
      futureProduct = productApi.getProduct(query: _searchQuery);
    });
  }

  Future<void> _logout() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirm) {
      await Auth.logout(context: context);
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shopping_basket),
            SizedBox(width: 8),
            Text('Produk',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          FutureBuilder<User?>(
            future: futureUser,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return IconButton(
                  icon: const Icon(Icons.error, color: Colors.red),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Error fetching user data.")),
                    );
                  },
                );
              } else if (!snapshot.hasData) {
                return IconButton(
                  icon: const Icon(Icons.person, color: Colors.grey),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not logged in.")),
                    );
                  },
                );
              }

              final user = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      user.name ?? 'User',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CartScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Cari produk...',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                _searchQuery = value;
                                _performSearch();
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              _searchQuery = _searchController.text;
                              _performSearch();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          final products = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      '${products.length} produk',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Jumlah kolom
                      mainAxisSpacing: 16, // Jarak vertikal antar item
                      crossAxisSpacing: 16, // Jarak horizontal antar item
                      childAspectRatio: 2 / 2.5, // Rasio ukuran item
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(products[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[300],
                child: Center(
                  child: Image.asset(
                    product.image ??
                        'images/produk-digital.jpeg', // Gunakan asset untuk gambar produk
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Config().formatCurrency(product.price ?? 0),
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              product.name ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              product.description ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.shopping_cart, color: Colors.blueAccent),
                  onPressed: () {
                    _addProduct(product);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addProduct(product) async {
    setState(() => _isLoading = true);

    try {
      // Resolve the current user
      final User? user = await futureUser;

      // Check if user is logged in
      if (user == null || user.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('User is not logged in. Please log in to add products.'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Get user_id and other product details
      int userId = user.id!;
      int productId = product.id!;
      int quantity = 1;
      int price = product.price ?? 0;
      int shippingCost = product.shipping_cost ?? 0;

      // Example: Add product to cart using an API
      // await orderItemApi.createOrderItem(buyerId: userId, productId: productId, quantity: quantity, price: price, shippingCost: shippingCost);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} berhasil ditambahkan ke keranjang!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error adding product to cart: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
