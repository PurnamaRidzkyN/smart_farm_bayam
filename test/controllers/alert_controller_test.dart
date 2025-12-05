import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_bayam/controllers/alert_controller.dart';
// Pastikan import mock yang sudah diperbaiki
import '../mocks/dashboard_refs_mock.dart'; 

void main() {
  late AlertController controller;
  late MockDatabaseReference mockRef;

  group('AlertController Tests', () {
    
    // --- TEST 1: Parsing & Cleaning String Logic ---
    // Ini test paling penting karena ada logika replaceAll di controller
    test('getAlerts cleans "type" string correctly (removes suffix and underscores)', () {
      final rawData = {
        'alert_001': {
          'type': 'ph_out_of_range', // Harusnya jadi: "ph"
          'message': 'pH terlalu tinggi',
          'timestamp': 123456789
        },
        'alert_002': {
          'type': 'tds_ppm_out_of_range', // Harusnya jadi: "tds ppm"
          'message': 'Nutrisi kurang',
          'timestamp': 123456799
        },
        'alert_003': {
          'type': 'simple', // Harusnya tetap: "simple"
          'message': 'Info biasa',
          'timestamp': 123456800
        }
      };

      // Kita inject langsung MockReference karena controller minta DatabaseReference
      mockRef = MockDatabaseReference(initialData: rawData);
      controller = AlertController(mockRef);

      // Karena outputnya Stream, kita pakai expect + emits
      expect(
        controller.getAlerts(),
        emits(predicate<List<dynamic>>((alerts) {
          // Kita cek apakah list-nya terisi 3 item
          if (alerts.length != 3) return false;

          // Kita cari alert berdasarkan ID (karena map tidak menjamin urutan, kita cek satu-satu)
          // Asumsi AlertModel punya properti 'type' dan 'id'
          final phAlert = alerts.firstWhere((a) => a.id == 'alert_001');
          final tdsAlert = alerts.firstWhere((a) => a.id == 'alert_002');
          final simpleAlert = alerts.firstWhere((a) => a.id == 'alert_003');

          // --- VERIFIKASI LOGIKA CLEANING ---
          // 'ph_out_of_range' -> replace '_out_of_range' -> trim -> 'ph'
          bool checkPh = phAlert.type == 'ph';
          
          // 'tds_ppm_out_of_range' -> replace '_out_of_range' -> 'tds_ppm' -> replace '_' spasi -> 'tds ppm'
          bool checkTds = tdsAlert.type == 'tds ppm'; 

          // 'simple' -> gak ada perubahan -> 'simple'
          bool checkSimple = simpleAlert.type == 'simple';

          return checkPh && checkTds && checkSimple;
        })),
      );
    });

    // --- TEST 2: Empty Data ---
    test('getAlerts emits empty list when no data exists', () {
      mockRef = MockDatabaseReference(initialData: null); // Data kosong
      controller = AlertController(mockRef);

      expect(controller.getAlerts(), emits([]));
    });

    // --- TEST 3: Remove Alert ---
    test('removeAlert deletes data from database', () async {
      final alertId = 'alert_tobedeleted';
      final initialData = {
        alertId: {'type': 'ph', 'message': 'Delete me'}
      };

      mockRef = MockDatabaseReference(initialData: initialData);
      controller = AlertController(mockRef);

      // Pastikan data ada dulu
      expect((await mockRef.child(alertId).get()).exists, true);

      // Act
      await controller.removeAlert(alertId);

      // Assert: Cek apakah child tersebut sudah hilang dari mock
      final afterSnap = await mockRef.child(alertId).get();
      expect(afterSnap.exists, false);
    });
  });
}