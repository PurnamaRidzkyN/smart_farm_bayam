import '../helper/manager.dart';

class HistoryController {
  final FirebaseRefs refs;
  HistoryController(this.refs);

  // Load threshold setting dari Firebase
  Future<Map<String, double>> loadThresholds() async {
    final snapshot = await refs.historyThresholdRef.get();
    if (!snapshot.exists) return {};
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  // Simpan threshold
  Future<void> saveThresholds(Map<String, double> thresholds) async {
    await refs.historyThresholdRef.set(thresholds);
  }

  // Load semua sensor seperti sebelumnya
  Future<Map<String, Map<String, double>>> loadHistoryData() async {
    Map<String, Map<String, double>> result = {};
    List<String> sensors = ['ph', 'tds_ppm', 'ec_ms_cm', 'temp_c'];

    for (var sensor in sensors) {
      final snapshot = await refs.historyRef.child(sensor).get();
      if (!snapshot.exists) {
        result[sensor] = {};
      } else {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        result[sensor] = data.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    }
    return result;
  }

  // NEW: Load data filter berdasarkan sensor dan tanggal
  Future<Map<String, double>> loadHistoryFiltered(
      String sensor, DateTime start, DateTime end) async {
    final snapshot = await refs.historyRef.child(sensor).get();
    if (!snapshot.exists) return {};

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    Map<String, double> filtered = {};
    data.forEach((ts, val) {
      DateTime t = DateTime.fromMillisecondsSinceEpoch(int.parse(ts));
      if (t.isAfter(start) && t.isBefore(end)) {
        filtered[ts] = (val as num).toDouble();
      }
    });

    return filtered;
  }

  Future<void> deleteAllHistory() async {
    try {
      await refs.historyRef.remove(); // hapus seluruh node history
    } catch (e) {
      print("Gagal hapus semua history: $e");
    }
  }
}
