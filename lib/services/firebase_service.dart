import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static DatabaseReference getSensorDataRef() {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://smartfarmbayam-default-rtdb.asia-southeast1.firebasedatabase.app",
    ).ref("sensor_data");
  }

  static DatabaseReference getSettingRef() {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://smartfarmbayam-default-rtdb.asia-southeast1.firebasedatabase.app",
    ).ref("settings");
  }
}
