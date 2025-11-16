import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_farm_bayam/pages/dashboard_page.dart';
import 'package:smart_farm_bayam/pages/config_page.dart';
import 'package:smart_farm_bayam/pages/login_page.dart';
import 'package:smart_farm_bayam/pages/sign_up_page.dart';
import 'package:smart_farm_bayam/pages/history_page.dart';
import 'package:smart_farm_bayam/app_globals.dart';
import 'package:smart_farm_bayam/pages/device_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppGlobals.init(app);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Farm App',
      theme: ThemeData(primarySwatch: Colors.green),

      initialRoute: "/dashboard",

      routes: {
        "/login": (context) => const LoginPage(),
        "/dashboard": (context) => const DashboardPage(),
        "/config": (context) => const ConfigPage(),
        // nanti tinggal tambah:
        "/history": (context) => const HistoryPage(),
        "/device": (context) => const DevicePage(),
        // "/notif": (context)  => const NotificationPage(),
      },
    );
  }
}
