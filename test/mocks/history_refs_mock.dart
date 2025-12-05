import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_bayam/controllers/history_controller.dart';

// Import file mock "Pintar" yang sudah kita perbaiki tadi
import '../mocks/dashboard_refs_mock.dart';

void main() {
  late HistoryController controller;
  late MockDashboardFirebaseRefs mockRefs;

  // Helper setup (sama seperti sebelumnya, tapi kita sesuaikan kebutuhan History)
  MockDashboardFirebaseRefs createMockRefs({
    Map<String, dynamic>? history,
    Map<String, dynamic>? historyThreshold,
  }) {
    return MockDashboardFirebaseRefs(
      // Kita isi yang null dengan data kosong atau null sesuai kebutuhan
      dataRef: MockDatabaseReference(initialData: {}), 
      currentReadingRef: MockDatabaseReference(initialData: {}),
      configThresholdRef: MockDatabaseReference(initialData: {}),
      
      // Fokus test ini ada di dua ref ini:
      historyRef: MockDatabaseReference(initialData: history),
      historyThresholdRef: MockDatabaseReference(initialData: historyThreshold),
    );
  }

  group('HistoryController Tests', () {
    
    // --- TEST 1: Load Thresholds ---
    test('loadThresholds returns correct map when data exists', () async {
      final mockData = {
        'ph': 1.0,
        'tds_ppm': 50.0,
      };
      mockRefs = createMockRefs(historyThreshold: mockData);
      controller = HistoryController(mockRefs);

      final result = await controller.loadThresholds();

      expect(result['ph'], 1.0);
      expect(result['tds_ppm'], 50.0);
    });

    test('loadThresholds returns empty map when not exists', () async {
      mockRefs = createMockRefs(historyThreshold: null); // Null = not exists
      controller = HistoryController(mockRefs);

      final result = await controller.loadThresholds();

      expect(result, isEmpty);
    });

    // --- TEST 2: Save Thresholds ---
    test('saveThresholds updates the database', () async {
      mockRefs = createMockRefs(); // Kosong awal
      controller = HistoryController(mockRefs);

      final newData = {'ph': 2.5, 'temp_c': 10.0};
      
      await controller.saveThresholds(newData);

      // Verifikasi ke Mock DB
      final snap = await mockRefs.historyThresholdRef.get();
      final savedData = snap.value as Map;

      expect(savedData['ph'], 2.5);
      expect(savedData['temp_c'], 10.0);
    });

    // --- TEST 3: Load All History (Complex Nested Map) ---
    test('loadHistoryData aggregates data from all sensors', () async {
      // Struktur: history -> sensor -> timestamp -> value
      final historyData = {
        'ph': {
          '1000': 6.0,
        },
        'tds_ppm': {
          '2000': 500.0,
        }
        // ec_ms_cm & temp_c kosong
      };

      mockRefs = createMockRefs(history: historyData);
      controller = HistoryController(mockRefs);

      final result = await controller.loadHistoryData();

      // Cek sensor yang ada datanya
      expect(result['ph']?['1000'], 6.0);
      expect(result['tds_ppm']?['2000'], 500.0);
      
      // Cek sensor yang kosong (harus tetap return map kosong, bukan null/crash)
      expect(result['ec_ms_cm'], isEmpty);
      expect(result['temp_c'], isEmpty);
    });

    // --- TEST 4: Filter Logic (Paling Penting!) ---
    test('loadHistoryFiltered filters data by date range correctly', () async {
      final now = DateTime.now();
      
      // Kita buat 3 titik waktu:
      final tPast = now.subtract(const Duration(days: 5)); // Masa lalu (out)
      final tTarget = now.subtract(const Duration(hours: 1)); // Target (in)
      final tFuture = now.add(const Duration(days: 5)); // Masa depan (out)

      // Range Filter: Hari ini saja
      final startFilter = now.subtract(const Duration(days: 1));
      final endFilter = now.add(const Duration(days: 1));

      final historyData = {
        'ph': {
          '${tPast.millisecondsSinceEpoch}': 5.0,   // Harusnya kena filter
          '${tTarget.millisecondsSinceEpoch}': 7.0, // Harusnya MASUK
          '${tFuture.millisecondsSinceEpoch}': 9.0, // Harusnya kena filter
        }
      };

      mockRefs = createMockRefs(history: historyData);
      controller = HistoryController(mockRefs);

      // Panggil fungsi filter
      final result = await controller.loadHistoryFiltered('ph', startFilter, endFilter);

      // Assert
      expect(result.length, 1); // Cuma boleh ada 1 data
      expect(result.containsKey('${tTarget.millisecondsSinceEpoch}'), true);
      expect(result.containsKey('${tPast.millisecondsSinceEpoch}'), false); // Pastikan masa lalu gak masuk
    });

    test('loadHistoryFiltered returns empty if node does not exist', () async {
      mockRefs = createMockRefs(history: {}); // Kosong
      controller = HistoryController(mockRefs);

      final result = await controller.loadHistoryFiltered(
          'ph', DateTime.now(), DateTime.now().add(const Duration(days: 1)));

      expect(result, isEmpty);
    });

    // --- TEST 5: Delete All ---
    test('deleteAllHistory removes all data under history node', () async {
      final historyData = {
        'ph': {'123': 7.0},
        'tds_ppm': {'456': 100}
      };
      
      mockRefs = createMockRefs(history: historyData);
      controller = HistoryController(mockRefs);

      // Pastikan ada dulu
      expect((await mockRefs.historyRef.get()).exists, true);

      // Hapus
      await controller.deleteAllHistory();

      // Cek lagi
      final snap = await mockRefs.historyRef.get();
      // Tergantung implementasi mock kamu:
      // Kalau remove() bikin value jadi null -> exists false
      expect(snap.exists, false); 
    });

  });
}