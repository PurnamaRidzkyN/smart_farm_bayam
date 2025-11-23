import 'package:flutter/material.dart';
import 'nav_items.dart';

class BottomNavWrapper extends StatefulWidget {
  final int initialIndex;

  const BottomNavWrapper({super.key, this.initialIndex = 0});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navItems[_currentIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // penting
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green, // warna label aktif
        unselectedItemColor: Colors.grey, // warna label non-aktif
        selectedLabelStyle: TextStyle(
          // opsional
          color: Colors.green,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        onTap: (idx) {
          setState(() => _currentIndex = idx);
        },
        items: navItems
            .map(
              (e) =>
                  BottomNavigationBarItem(icon: Icon(e.icon), label: e.label),
            )
            .toList(),
      ),
    );
  }
}
