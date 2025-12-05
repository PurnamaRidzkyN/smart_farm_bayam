import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_bayam/controllers/dashboard_controller.dart';
import 'package:smart_farm_bayam/models/history_threshold_model.dart';
// Sesuaikan import ini dengan lokasi file mock kamu
import '../mocks/dashboard_refs_mock.dart';

void main() {
  late DashboardController controller;
  late MockDashboardFirebaseRefs mockRefs;

  // Helper untuk setup Mock dengan data awal yang fleksibel
  // Helper untuk setup Mock dengan data awal yang fleksibel
  MockDashboardFirebaseRefs createMockRefs({
    Map<String, dynamic>? data,
    Map<String, dynamic>? current,
    Map<String, dynamic>? history,
    Map<String, dynamic>? historyThreshold,
    Map<String, dynamic>? config,
  }) {
    // Ubah logika inisialisasi: Langsung pass Map ke MockDatabaseReference
    return MockDashboardFirebaseRefs(
      dataRef: MockDatabaseReference(initialData: data),
      currentReadingRef: MockDatabaseReference(initialData: current),
      historyRef: MockDatabaseReference(initialData: history),
      historyThresholdRef: MockDatabaseReference(initialData: historyThreshold),
      // Jika config null, jangan pass {}, biarkan null agar dianggap not exists
      configThresholdRef: MockDatabaseReference(initialData: config),
    );
  }

  group('DashboardController Complete Tests', () {
    // --- TEST 1: Stream & Sorting ---
    test(
      'getLastSensorData returns correct latest data based on sorted keys',
      () async {
        // Simulasi data acak (tidak urut)
        final rawData = {
          '1000': {'ph': 6.0}, // Lama
          '3000': {'ph': 8.0}, // Paling baru
          '2000': {'ph': 7.0}, // Tengah
        };

        mockRefs = createMockRefs(data: rawData);
        controller = DashboardController(mockRefs);

        // Ambil elemen pertama dari stream
        final result = await controller.getLastSensorData().first;

        // Harusnya mengambil key '3000' (terbesar)
        expect(result['ph'], 8.0);
      },
    );

    // --- TEST 2: Update Current Reading ---
    test('updateCurrentReading adds timestamp and updates data', () async {
      mockRefs = createMockRefs(current: {'ph': 5.0});
      controller = DashboardController(mockRefs);

      await controller.updateCurrentReading({'ph': 6.5, 'tds_ppm': 300});

      final snap = await mockRefs.currentReadingRef.get();
      final savedData = snap.value as Map;

      expect(savedData['ph'], 6.5);
      expect(savedData['tds_ppm'], 300);
      expect(
        savedData.containsKey('unix_ms'),
        true,
      ); // Pastikan timestamp dibuat
    });

    // --- TEST 3: Caching Logic ---
    test('initLastValueCache populates local cache from history', () async {
      // Struktur History di Firebase: history -> sensor_type -> timestamp -> value
      final historyData = {
        'ph': {
          '1000': 6.0,
          '2000': 6.2, // Value terakhir
        },
        'tds_ppm': {
          '1500': 400, // Value terakhir
        },
      };

      mockRefs = createMockRefs(history: historyData);
      controller = DashboardController(mockRefs);

      await controller.initLastValueCache();

      // Cek apakah cache lokal controller sudah terisi
      expect(controller.lastValueCache['ph'], 6.2);
      expect(controller.lastValueCache['tds_ppm'], 400.0);
      expect(
        controller.lastValueCache['ec_ms_cm'],
        null,
      ); // Tidak ada di history
    });

    // --- TEST 4: Save Logic & Thresholds (CORE LOGIC) ---
    test('saveIfChanged respects thresholds (Save vs Skip)', () async {
      mockRefs = createMockRefs();
      controller = DashboardController(mockRefs);

      // 1. Setup Threshold Manual
      controller.historyThreshold = HistoryThreshold(
        ph: 0.5, // Perubahan harus >= 0.5 baru disimpan
        tdsPpm: 10.0,
        ecMsCm: 0.1,
        tempC: 1.0,
      );

      // 2. Setup Cache Awal (Seolah-olah data terakhir adalah pH 7.0)
      controller.lastValueCache['ph'] = 7.0;

      // KASUS A: Perubahan KECIL (7.0 -> 7.2) | Diff = 0.2 (< 0.5)
      // Harusnya TIDAK disimpan ke history
      final dataSmallChange = {'unix_ms': 1000, 'ph': 7.2};
      await controller.saveIfChanged(dataSmallChange);

      // Cek History: Harusnya kosong (belum ada child 'ph/1000')
      var historySnap = await mockRefs.historyRef
          .child('ph')
          .child('1000')
          .get();
      expect(historySnap.exists, false);

      // KASUS B: Perubahan BESAR (7.0 -> 7.6) | Diff = 0.6 (>= 0.5)
      // Harusnya DISIMPAN
      final dataBigChange = {'unix_ms': 2000, 'ph': 7.6};
      await controller.saveIfChanged(dataBigChange);

      // Cek History: Harusnya ada
      historySnap = await mockRefs.historyRef.child('ph').child('2000').get();
      expect(historySnap.exists, true);
      expect(historySnap.value, 7.6);

      // Cache juga harus berubah jadi 7.6
      expect(controller.lastValueCache['ph'], 7.6);
    });

    test('saveIfChanged always removes data from dataRef after processing', () async {
      // Setup dataRef seolah-olah ada data antrian
      final timestamp = '123456789';
      final initialData = {
        timestamp: {'unix_ms': 123456789, 'ph': 7.0},
      };

      mockRefs = createMockRefs(data: initialData);
      // Kita perlu manual set storage di mock karena createMockRefs menaruh di root snapshot value,
      // tapi controller akan memanggil remove() pada child.
      // Di MockDatabaseReference kamu, remove() hanya clear storage local child tersebut.
      // Jadi kita harus pastikan child itu "eksis" dulu di logika mock.
      // *Catatan*: Mock yang kamu berikan agak tricky di bagian remove().
      // Kita asumsikan flow controller: saveIfChanged menerima Map, lalu panggil remove pada key.

      controller = DashboardController(mockRefs);

      // Panggil fungsi
      await controller.saveIfChanged({'unix_ms': 123456789, 'ph': 7.0});

      // Verify remove dipanggil.
      // Di mock kamu: remove() men-clear storage.
      // Kita cek child tersebut.
      final checkSnap = await mockRefs.dataRef.child(timestamp).get();
      // Karena mock .remove() me-clear storage, exists harusnya false (atau value null) tergantung implementasi mock detailnya.
      // Berdasarkan mock kamu: exists = storage[path] != null. Jika clear, maka null.
      expect(checkSnap.exists, false);
    });

    // --- TEST 5: Move Old Data (Migration) ---
    test('moveOldDataToHistory moves only data BEFORE login time', () async {
      final now = DateTime.now();
      final past = now.subtract(const Duration(hours: 1)); // Masa lalu
      final future = now.add(const Duration(hours: 1));    // Masa depan

      final pastMs = past.millisecondsSinceEpoch;
      final futureMs = future.millisecondsSinceEpoch;

      final rawData = {
        '$pastMs': {'unix_ms': pastMs, 'ph': 6.0}, // Harus pindah
        '$futureMs': {'unix_ms': futureMs, 'ph': 8.0}, // Harus tetap diam
      };

      mockRefs = createMockRefs(data: rawData);
      controller = DashboardController(mockRefs);

      // Load threshold dulu supaya tidak error saat saveIfChanged
      await controller.loadThresholds();

      // Act: User Login "Sekarang"
      await controller.moveOldDataToHistory(now);

      // --- ASSERT 1: Cek Data Masa Lalu (Harus Hilang dari dataRef) ---
      final pastSnapSource = await mockRefs.dataRef.child(pastMs.toString()).get();
      expect(pastSnapSource.exists, false, reason: 'Data lama harus dihapus dari source');

      // --- ASSERT 2: Cek Data Masa Depan (Harus Masih Ada di dataRef) ---
      final futureSnapSource = await mockRefs.dataRef.child(futureMs.toString()).get();
      expect(futureSnapSource.exists, true, reason: 'Data masa depan TIDAK BOLEH dihapus');
      
      // PERBAIKAN DI SINI: Tambahkan (as Map)
      expect((futureSnapSource.value as Map)['ph'], 8.0);

      // --- ASSERT 3: Cek Data Masa Lalu (Harus Muncul di historyRef) ---
      final pastSnapDest = await mockRefs.historyRef.child('ph').child(pastMs.toString()).get();
      expect(pastSnapDest.exists, true, reason: 'Data lama harus masuk ke history');
      expect(pastSnapDest.value, 6.0);
    });

    // --- TEST 6: Config & Threshold Parsing ---
    test('loadConfig parses configuration correctly', () async {
      final configData = {
        'ph_min': 5.5, 'ph_max': 7.5,
        'tds_min': 100, 'tds_max': 800,
        // ... field lain
      };

      mockRefs = createMockRefs(config: configData);
      controller = DashboardController(mockRefs);

      await controller.loadConfig();

      expect(controller.config, isNotNull);
      expect(controller.config?.phMin, 5.5);

      // Cek threshold map generation
      expect(controller.thresholds['ph']!['min'], 5.5);
      expect(controller.thresholds['ph']!['max'], 7.5);
    });

    test('generateThresholdMap handles null config safely', () async {
      mockRefs = createMockRefs(config: null); // config kosong
      controller = DashboardController(mockRefs);

      await controller.loadConfig(); // config akan null

      expect(controller.config, isNull);
      expect(controller.thresholds['ph']!['min'], 0); // Default 0
    });
  });
  // --- TEST TAMBAHAN: Basic Fetching ---

  test('getCurrent fetches and formats data correctly', () async {
    // Setup mock data
    final currentData = {'ph': 6.54321, 'tds_ppm': 400};
    mockRefs = createMockRefs(current: currentData);
    controller = DashboardController(mockRefs);

    // Act
    final result = await controller.getCurrent();

    // Assert
    expect(
      result['ph'],
      6.54,
    ); // Harus dibulatkan 2 desimal (sesuai logic controller)
    expect(result['tds_ppm'], 400);
  });

  test('loadThresholds sets default values if data is empty', () async {
    mockRefs = createMockRefs(historyThreshold: null); // Simulasi data kosong
    controller = DashboardController(mockRefs);

    await controller.loadThresholds();

    // Harus pakai default value (sesuai logic controller)
    expect(controller.historyThreshold.ph, 1.0);
    expect(controller.historyThreshold.tdsPpm, 50.0);
  });
}
