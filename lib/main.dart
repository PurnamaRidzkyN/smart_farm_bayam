import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_farm_bayam/pages/login_page.dart';
import 'package:smart_farm_bayam/app_globals.dart';
import 'firebase_options.dart';
import 'navigation/bottom_nav.dart';

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
        "/dashboard": (context) => const BottomNavWrapper(initialIndex: 0),
        "/alert": (context) => const BottomNavWrapper(initialIndex: 1),
        "/config": (context) => const BottomNavWrapper(initialIndex: 2),
        "/history": (context) => const BottomNavWrapper(initialIndex: 3),
        "/device": (context) => const BottomNavWrapper(initialIndex: 4),
        "/user": (context) => const BottomNavWrapper(initialIndex: 5),
        "/information": (context) => const BottomNavWrapper(initialIndex: 6),
      },
    );
  }
}
