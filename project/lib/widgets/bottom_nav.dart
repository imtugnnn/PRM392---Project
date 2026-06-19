import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/products/product_list_screen.dart';
import '../screens/orders/order_list_screen.dart';
import '../screens/picking/picking_summary_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    ProductListScreen(),
    OrderListScreen(),
    PickingSummaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: [
        const HomeScreen(),
        ProductListScreen(
          key: ValueKey(
            'product_$currentIndex',
          ),
        ),
        OrderListScreen(
          key: ValueKey(
            'order_$currentIndex',
          ),
        ),
        PickingSummaryScreen(
          key: ValueKey(
            'picking_$currentIndex',
          ),
        ),
      ][currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Picking',
          ),
        ],
      ),
    );
  }
}