import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/config_page.dart';
import '../pages/history_page.dart';
import '../pages/device_page.dart';

class NavItem {
  final IconData icon;
  final String label;
  final Widget page;

  NavItem({required this.icon, required this.label, required this.page});
}

final List<NavItem> navItems = [
  NavItem(icon: Icons.dashboard, label: "Dashboard", page: DashboardPage()),
  NavItem(icon: Icons.settings, label: "Config", page: ConfigPage()),
  NavItem(icon: Icons.history, label: "History", page: HistoryPage()),
  NavItem(icon: Icons.devices, label: "Device", page: DevicePage()),
];
