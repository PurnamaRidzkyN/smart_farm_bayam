import 'package:smart_farm_bayam/helper/manager.dart';
import 'package:firebase_core/firebase_core.dart';

class AppGlobals {
  static late final FirebaseRefs refs;

  // Inisialisasi di main.dart
  static Future<void> init(FirebaseApp app) async {
    refs = FirebaseRefs(app);
  }
}
