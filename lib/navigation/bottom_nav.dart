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

  void _showOthersMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OthersPages.info),
                  );
                },
                child: _menuItem(Icons.info_outline, "Information"),
              ),
              SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OthersPages.alert),
                  );
                },
                child: _menuItem(Icons.warning_amber_outlined, "Alert"),
              ),
              SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OthersPages.user),
                  );
                },
                child: _menuItem(Icons.person_outline, "User"),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _menuItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 26),
        SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navItems[_currentIndex].page,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.teal.shade900,
        ),
        padding: EdgeInsets.only(top: 6),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          onTap: (idx) {
            if (idx == 2) {
              _showOthersMenu();
              return;
            }
            setState(() => _currentIndex = idx);
          },
          items: navItems
              .map((e) => BottomNavigationBarItem(
                    icon: Icon(e.icon),
                    label: e.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
