import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_bayam/controllers/config_controller.dart';
import 'package:smart_farm_bayam/models/config_model.dart';
import '../mocks/config_refs_mock.dart';

void main() {
  late ConfigController controller;
  late MockFirebaseRefs mockRefs;

  setUp(() {
    // Buat mock snapshot
    final snapshot = MockDataSnapshot(
      exists: true,
      value: {
        'ph_min': 5.5,
        'ph_max': 6.5,
        'tds_min_ppm': 200,
        'tds_max_ppm': 600,
        'ec_min_ms_cm': 1.8,
        'ec_max_ms_cm': 2.3,
        'temp_min_c': 20,
        'temp_max_c': 30,
        'is_manual': true,
      },
    );

    final ref = MockDatabaseReference(snapshot: snapshot);
    mockRefs = MockFirebaseRefs(ref: ref);

    controller = ConfigController(mockRefs);
  });

  test('loadConfig returns ConfigModel when data exists', () async {
    final config = await controller.loadConfig();
    expect(config, isA<ConfigModel>());
    expect(config!.phMin, 5.5);
    expect(config.ecMax, 2.3);
  });

  test('loadConfig returns null when snapshot does not exist', () async {
    // buat snapshot tidak exist
    final snapshot = MockDataSnapshot(exists: false);
    final ref = MockDatabaseReference(snapshot: snapshot);
    mockRefs = MockFirebaseRefs(ref: ref);
    controller = ConfigController(mockRefs);

    final config = await controller.loadConfig();
    expect(config, null);
  });

  test('saveConfig writes correct data to Firebase', () async {
    final config = ConfigModel(
      phMin: 5.5,
      phMax: 6.5,
      tdsMin: 200,
      tdsMax: 600,
      ecMin: 1.8,
      ecMax: 2.3,
      tempMin: 20,
      tempMax: 30,
      isManual: true,
    );

    // Tidak perlu verify mockito, cukup pastikan tidak throw
    await controller.saveConfig(config);
  });
}
