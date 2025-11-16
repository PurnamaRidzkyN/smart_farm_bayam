import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseRefs {
  final FirebaseApp app;

  FirebaseRefs(this.app);

  // Realtime readings
  DatabaseReference get dataRef => FirebaseDatabase.instanceFor(
    app: app,
    databaseURL:
        "https://smartfarmbayam-default-rtdb.asia-southeast1.firebasedatabase.app",
  ).ref("devices/esp32_001/readings");

  // History per sensor
  DatabaseReference get historyRef => FirebaseDatabase.instanceFor(
    app: app,
    databaseURL:
        "https://smartfarmbayam-default-rtdb.asia-southeast1.firebasedatabase.app",
  ).ref("devices/esp32_001/history");

  // Threshold config (history)
  DatabaseReference get historyThresholdRef => FirebaseDatabase.instanceFor(
    app: app,
    databaseURL:
        "https://smartfarmbayam-default-rtdb.asia-southeast1.firebasedatabase.app",
  ).ref("app/config/history_thresholds");

  // Threshold config (config)
  DatabaseReference get configThresholdRef => FirebaseDatabase.instanceFor(
    app: app,
    databaseURL:
        "https://smartfarmbayam-default-rtdb.asia-southeast1.firebasedatabase.app",
  ).ref("app/config/thresholds");
  DatabaseReference get deviceRef => FirebaseDatabase.instanceFor(
    app: app,
    databaseURL:
        "https://smartfarmbayam-default-rtdb.asia-southeast1.firebasedatabase.app",
  ).ref("devices/tool");
}
