import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/config_page.dart';
import '../pages/history_page.dart';
import '../pages/device_page.dart';
import '../pages/alert_page.dart';
import '../pages/user_page.dart';
import '../pages/information_page.dart';

class NavItem {
  final IconData icon;
  final String label;
  final Widget page;

  NavItem({required this.icon, required this.label, required this.page});
}

final List<NavItem> navItems = [
  NavItem(icon: Icons.home, label: "Home", page: DashboardPage()),
  NavItem(icon: Icons.tune, label: "Control", page: DevicePage()),

  // INDEX 2 = OTHERS → TIDAK PUNYA PAGE, HANYA BUKA POPUP
  NavItem(icon: Icons.dashboard_customize, label: "Others", page: SizedBox()),

  NavItem(icon: Icons.history, label: "History", page: HistoryPage()),
  NavItem(icon: Icons.settings, label: "Config", page: ConfigPage()),
];

/// PAGE LAIN UNTUK POPUP "OTHERS"
class OthersPages {
  static final info = InformationPage();
  static final alert = AlertPage();
  static final user = UserPage();
}