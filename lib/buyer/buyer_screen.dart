import 'package:flutter/material.dart';
import 'package:myapp/buyer/orders_screen.dart';
import 'package:myapp/buyer/product/product_screen.dart';
import 'package:myapp/buyer/wishlist_screen.dart';
import 'package:myapp/seller/profile/index_screen.dart';

class BuyerScreen extends StatefulWidget {
  const BuyerScreen({super.key});

  @override
  _BuyerScreenState createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  int _currentIndex = 0;

  // List tampilan yang dapat dipilih di bottom navigation
  final List<Widget> _screens = [
    ProductScreen(),
    const OrdersScreen(),
    IndexProfileScreen(), // Biodata Usaha
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black, // Color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        iconSize: 30, // Size of icons
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket_outlined),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}