import 'package:firebase_database/firebase_database.dart';
import '../models/history_threshold_model.dart';
import '../helper/manager.dart';

class DashboardController {
  // Threshold dari Firebase
  late HistoryThreshold thresholds;
final FirebaseRefs refs;

  DashboardController(this.refs);

  // Stream data terakhir
  Stream<Map<String, dynamic>> getLastSensorData() {
  return refs.dataRef.onValue.map((event) {
    if (event.snapshot.value == null) return {}; 
    final readings = Map<String, dynamic>.from(event.snapshot.value as Map);
    if (readings.isEmpty) return {};
    final lastKey = readings.keys.last;
    final lastData = Map<String, dynamic>.from(readings[lastKey]);
    return lastData;
  });
}

  // Ambil thresholds dari Firebase
  Future<void> loadThresholds() async {
    final snapshot = await refs.historyThresholdRef.get();
    if (!snapshot.exists) {
      thresholds = HistoryThreshold(ph: 1.0, tdsPpm: 50.0, ecMsCm: 0.5, tempC: 5.0);
    } else {
      thresholds = HistoryThreshold.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
    }
  }

  // Helper ambil nilai terakhir dari snapshot history
  double? getLastValue(DataSnapshot snapshot) {
    if (!snapshot.exists) return null;
    final val = snapshot.value;
    if (val is Map) {
      final values = val.values.toList();
      if (values.isEmpty) return null;
      final last = values.last;
      if (last is num) return last.toDouble();
      if (last is String) return double.tryParse(last);
      return null;
    } else if (val is num) {
      return val.toDouble();
    } else if (val is String) {
      return double.tryParse(val);
    }
    return null;
  }

  // Helper ambil threshold dari model
  double getThreshold(String key) {
    switch (key) {
      case 'ph':
        return thresholds.ph;
      case 'tds_ppm':
        return thresholds.tdsPpm;
      case 'ec_ms_cm':
        return thresholds.ecMsCm;
      case 'temp_c':
        return thresholds.tempC;
      default:
        return 0;
    }
  }

  // Pindahkan data lama ke history dan hapus dari readings
  Future<void> moveOldDataToHistory(DateTime loginTime) async {
    final snapshot = await refs.dataRef.get();
    if (!snapshot.exists) return;

    final readings = Map<String, dynamic>.from(snapshot.value as Map);
    final futures = <Future>[];

    for (var entry in readings.entries) {
      final timestampMs = int.tryParse(entry.key);
      if (timestampMs == null) continue;

      final entryTime = DateTime.fromMillisecondsSinceEpoch(timestampMs);
      if (entryTime.isBefore(loginTime)) {
        final value = entry.value;
        Map<String, dynamic> data;

        if (value is Map) {
          data = Map<String, dynamic>.from(value);
        } else {
          continue; // skip kalau bukan Map
        }

        // Simpan ke history per sensor sesuai threshold
        for (var key in ['ph', 'tds_ppm', 'ec_ms_cm', 'temp_c']) {
          final sensorValue = data[key];
          if (sensorValue == null) continue;

          final lastSnapshot = await refs.historyRef.child(key).limitToLast(1).get();
          final lastValue = getLastValue(lastSnapshot);

          if (lastValue == null || (sensorValue - lastValue).abs() >= getThreshold(key)) {
            futures.add(refs.historyRef.child(key).child(entry.key).set(sensorValue));
          }
        }

        // Hapus dari readings
        futures.add(refs.dataRef.child(entry.key).remove());
      }
    }

    await Future.wait(futures);
  }

  // Simpan data baru jika melewati threshold
  Future<void> saveIfChanged(Map<String, dynamic> currentData) async {
    final futures = <Future>[];

    for (var key in ['ph', 'tds_ppm', 'ec_ms_cm', 'temp_c']) {
      final value = currentData[key];
      if (value == null) continue;

      final lastSnapshot = await refs.historyRef.child(key).limitToLast(1).get();
      final lastValue = getLastValue(lastSnapshot);

      if (lastValue == null || (value - lastValue).abs() >= getThreshold(key)) {
        final nowMs = DateTime.now().millisecondsSinceEpoch.toString();
        futures.add(refs.historyRef.child(key).child(nowMs).set(value));
      }
    }

    await Future.wait(futures);
  }
}
