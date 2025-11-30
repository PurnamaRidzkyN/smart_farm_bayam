import '../models/history_threshold_model.dart';
import '../helper/manager.dart';
import '../models/config_model.dart';

class DashboardController {
  late HistoryThreshold historyThreshold;
  final FirebaseRefs refs;
  ConfigModel? config;
  Map<String, Map<String, double>> thresholds = {};
  DashboardController(this.refs);

  // Ambil data terakhir untuk ditampilkan
  Stream<Map<String, dynamic>> getLastSensorData() {
    return refs.dataRef.onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw == null) return {};

      final readings = Map<String, dynamic>.from(raw as Map);
      if (readings.isEmpty) return {};

      final sortedKeys = readings.keys.map(int.parse).toList()..sort();
      final lastKey = sortedKeys.last.toString();
      return Map<String, dynamic>.from(readings[lastKey]);
    });
  }

  Future<Map<String, dynamic>> getCurrent() async {
    final snap = await refs.currentReadingRef.get();
    if (!snap.exists) return {};

    final raw = Map<String, dynamic>.from(snap.value as Map);

    final result = raw.map((key, value) {
      if (value is num) {
        // bulatkan float ke 2 angka
        return MapEntry(key, double.parse(value.toStringAsFixed(2)));
      }
      return MapEntry(key, value);
    });

    return result;
  }

  Future<void> updateCurrentReading(Map<String, dynamic>? newData) async {
    if (newData == null || newData.isEmpty) return;

    final snap = await refs.currentReadingRef.get();

    final now = DateTime.now();

    if (!snap.exists) {
      // Kalau node current_reading belum ada, buat langsung
      await refs.currentReadingRef.set({
        ...newData,
        'unix_ms': now.millisecondsSinceEpoch,
      });
      return;
    }

    final current = Map<String, dynamic>.from(snap.value as Map);

    // update hanya jika perlu
    await refs.currentReadingRef.set({
      ...current,
      ...newData,
      'unix_ms': now.millisecondsSinceEpoch,
    });
  }

  // Load threshold
  Future<void> loadThresholds() async {
    final snapshot = await refs.historyThresholdRef.get();

    if (!snapshot.exists) {
      historyThreshold = HistoryThreshold(
        ph: 1.0,
        tdsPpm: 50.0,
        ecMsCm: 0.5,
        tempC: 5.0,
      );
    } else {
      historyThreshold = HistoryThreshold.fromMap(
        Map<String, dynamic>.from(snapshot.value as Map),
      );
    }
  }

  // Ambil last value dari history by MAX KEY (timestamp terakhir)
  double? getLastValueFromHistory(Map rawMap) {
    if (rawMap.isEmpty) return null;

    final keys =
        rawMap.keys
            .map((e) => int.tryParse(e.toString()))
            .where((v) => v != null)
            .map((v) => v!)
            .toList()
          ..sort();

    final lastKey = keys.last.toString();
    final val = rawMap[lastKey];

    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  double getThreshold(String key) {
    switch (key) {
      case 'ph':
        return historyThreshold.ph;
      case 'tds_ppm':
        return historyThreshold.tdsPpm;
      case 'ec_ms_cm':
        return historyThreshold.ecMsCm;
      case 'temp_c':
        return historyThreshold.tempC;
    }
    return 0;
  }

  // Move old data to history
  Future<void> moveOldDataToHistory(DateTime loginTime) async {
    // Baca readings sekali
    final snapshot = await refs.dataRef.get();
    if (!snapshot.exists) return;

    final readings = Map<String, dynamic>.from(snapshot.value as Map);

    // Baca seluruh history sekali
    final historySnap = await refs.historyRef.get();
    final fullHistory = historySnap.exists
        ? Map<String, dynamic>.from(historySnap.value as Map)
        : {};

    final futures = <Future>[];

    for (var entry in readings.entries) {
      final timestamp = int.tryParse(entry.key);
      if (timestamp == null) continue;

      final entryTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (!entryTime.isBefore(loginTime)) continue;
      final data = Map<String, dynamic>.from(entry.value);

      // Check 4 sensor
      for (var key in ['ph', 'tds_ppm', 'ec_ms_cm', 'temp_c']) {
        final sensorValue = data[key];
        if (sensorValue == null) continue;

        // Ambil history map per sensor
        final sensorHistory = (fullHistory[key] is Map)
            ? Map<String, dynamic>.from(fullHistory[key])
            : {};

        final lastValue = getLastValueFromHistory(sensorHistory);

        if (lastValue == null ||
            (sensorValue - lastValue).abs() >= getThreshold(key)) {
          // Simpan ke history dengan timestamp asli
          futures.add(
            refs.historyRef.child(key).child(entry.key).set(sensorValue),
          );

          // Update cache supaya next compare tidak ngeget lagi
          sensorHistory[entry.key] = sensorValue;
          fullHistory[key] = sensorHistory;
        }
      }

      // Hapus dari readings
      futures.add(refs.dataRef.child(entry.key).remove());
    }

    await Future.wait(futures);
  }

  // Simpan data baru kalau berubah lebih dari threshold
  Future<void> saveIfChanged(Map<String, dynamic> newData) async {
    if (newData.isEmpty) return;

    final current = await getCurrent();
    final changedKeys = <String>[];

    for (var key in ['ph', 'tds_ppm', 'ec_ms_cm', 'temp_c']) {
      final oldVal = current[key];
      final newVal = newData[key];

      if (oldVal == null || newVal == null) continue;

      if ((newVal - oldVal).abs() >= getThreshold(key)) {
        changedKeys.add(key);
      }
    }

    if (changedKeys.isEmpty) return;

    final unixMs = DateTime.now().millisecondsSinceEpoch.toString();

    for (var key in changedKeys) {
      await refs.historyRef.child(key).child(unixMs).set(newData[key]);
    }
  }

  // buat peringatan
  Future<void> loadConfig() async {
    final snapshot = await refs.configThresholdRef.get();
    if (!snapshot.exists) {
      config = null;
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    config = ConfigModel.fromMap(data);

    _generateThresholdMap();
  }

  // bikin threshold map
  void _generateThresholdMap() {
    if (config == null) {
      thresholds = {
        "ph": {"min": 0, "max": 0},
        "tds_ppm": {"min": 0, "max": 0},
        "ec_ms_cm": {"min": 0, "max": 0},
        "temp_c": {"min": 0, "max": 0},
      };
      return;
    }

    thresholds = {
      "ph": {"min": config!.phMin, "max": config!.phMax},
      "tds_ppm": {"min": config!.tdsMin, "max": config!.tdsMax},
      "ec_ms_cm": {"min": config!.ecMin, "max": config!.ecMax},
      "temp_c": {"min": config!.tempMin, "max": config!.tempMax},
    };
  }
}
