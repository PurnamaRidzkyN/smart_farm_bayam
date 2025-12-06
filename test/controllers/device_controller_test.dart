import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_bayam/controllers/device_controller.dart';
import 'package:smart_farm_bayam/models/device_model.dart';
import '../mocks/device_refs_mock.dart';

void main() {
  late DeviceController controller;
  late MockDeviceFirebaseRefs mockRefs;

  // --- PERBAIKAN HELPER ---
  MockDeviceFirebaseRefs createMockRefs({
    required bool isManual,
    required Map<String, dynamic>? deviceData,
  }) {
    return MockDeviceFirebaseRefs(initialData: deviceData, isManual: isManual);
  }

  test('getDeviceStream returns correct DeviceModel', () async {
    mockRefs = createMockRefs(
      isManual: true,
      deviceData: {'pump_acid': true, 'pump_nutrient': false},
    );
    controller = DeviceController(mockRefs);

    final stream = controller.getDeviceStream();
    final device = await stream.first;

    expect(device.pumpAcid, true);
    expect(device.pumpNutrient, false);
  });

  test('updateDevice throws exception if manual mode is false', () async {
    mockRefs = createMockRefs(
      isManual: false,
      deviceData: {'pump_acid': false, 'pump_nutrient': false},
    );
    controller = DeviceController(mockRefs);

    expect(
      () => controller.updateDevice('pumpAcid', true),
      throwsA(isA<Exception>()),
    );
  });

  test('updateDevice works if manual mode is true', () async {
    mockRefs = createMockRefs(
      isManual: true,
      deviceData: {'pump_acid': false, 'pump_nutrient': false},
    );
    controller = DeviceController(mockRefs);

    await controller.updateDevice('pumpAcid', true);
  });

  test('updateAll throws exception if manual mode is false', () async {
    mockRefs = createMockRefs(
      isManual: false,
      deviceData: {'pump_acid': false, 'pump_nutrient': false},
    );
    controller = DeviceController(mockRefs);

    final device = DeviceModel(pumpAcid: true, pumpNutrient: true);
    expect(() => controller.updateAll(device), throwsA(isA<Exception>()));
  });

  test('updateAll works if manual mode is true', () async {
    mockRefs = createMockRefs(
      isManual: true,
      deviceData: {'pump_acid': false, 'pump_nutrient': false},
    );
    controller = DeviceController(mockRefs);

    final device = DeviceModel(pumpAcid: true, pumpNutrient: true);
    await controller.updateAll(device);
  });
}