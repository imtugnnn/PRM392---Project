import 'package:flutter/material.dart';
import 'widgets/bottom_nav.dart';

void main() {
  runApp(const WarehouseApp());
}

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warehouse Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BottomNav(),
    );
  }
}