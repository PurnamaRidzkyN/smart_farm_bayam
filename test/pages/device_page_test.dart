// Lokasi: test/pages/device_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_bayam/controllers/device_controller.dart';
import 'package:smart_farm_bayam/pages/device_page.dart'; // Sesuaikan import

// Import Mock Khusus tadi
import '../mocks/device_refs_mock.dart';

void main() {
  late DeviceController controller;
  late MockDeviceFirebaseRefs mockRefs;

  // Helper render halaman
  Future<void> pumpPage(WidgetTester tester, DeviceController ctrl) async {
    await tester.pumpWidget(MaterialApp(home: DevicePage(controller: ctrl)));
    await tester.pump(); // Selesaikan animasi/loading awal
  }

  group('Device Page Tests', () {
    // TEST 1: Cek Tampilan Awal (Switch ON/OFF)
    testWidgets('Tampilan switch sesuai data Firebase', (
      WidgetTester tester,
    ) async {
      // 1. Siapkan Data Palsu
      final dataAwal = {
        'pump_acid': true, // Nyala
        'pump_nutrient': false, // Mati
      };

      // 2. Masukkan ke Mock & Controller
      mockRefs = MockDeviceFirebaseRefs(initialData: dataAwal);
      controller = DeviceController(mockRefs);

      // 3. Render
      await pumpPage(tester, controller);

      // 4. Cek Judul
      expect(find.text('Control Device'), findsOneWidget);
      expect(find.text('Pompa Asam'), findsOneWidget);

      // 5. Cek Switch
      // Switch pertama (Pompa Asam) harus TRUE
      final switchAsam = tester.widget<Switch>(find.byType(Switch).first);
      expect(switchAsam.value, true);

      // Switch kedua (Pompa Nutrisi) harus FALSE
      final switchNutrisi = tester.widget<Switch>(find.byType(Switch).at(1));
      expect(switchNutrisi.value, false);
    });

    // TEST 2: Cek Interaksi (Klik Switch)
    testWidgets('Klik switch mengubah data di database', (
      WidgetTester tester,
    ) async {
      // 1. Data Awal: Mati Semua
      final dataAwal = {'pump_acid': false, 'pump_nutrient': false};

      mockRefs = MockDeviceFirebaseRefs(initialData: dataAwal);
      controller = DeviceController(mockRefs);

      await pumpPage(tester, controller);

      // 2. Klik Switch Pertama (Pompa Asam)
      await tester.tap(find.byType(Switch).first);
      await tester.pump(); // Rebuild UI

      // 3. Cek Database Mock: Harusnya jadi TRUE
      final snap = await mockRefs.deviceRef.get();
      final dataBaru = snap.value as Map;

      expect(dataBaru['pump_acid'], true);
    });
  });
}
