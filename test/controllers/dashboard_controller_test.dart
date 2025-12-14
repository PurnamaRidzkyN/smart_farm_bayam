import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_bayam/controllers/dashboard_controller.dart';
import 'package:smart_farm_bayam/models/history_threshold_model.dart';

import '../mocks/dashboard_refs_mock.dart';

void main() {
  late DashboardController controller;
  late MockDashboardFirebaseRefs mockRefs;

  MockDashboardFirebaseRefs createMockRefs({
    Map<String, dynamic>? data,
    Map<String, dynamic>? current,
    Map<String, dynamic>? history,
    Map<String, dynamic>? historyThreshold,
    Map<String, dynamic>? config,
  }) {
    return MockDashboardFirebaseRefs(
      dataRef: MockDatabaseReference(initialData: data),
      currentReadingRef: MockDatabaseReference(initialData: current),
      historyRef: MockDatabaseReference(initialData: history),
      historyThresholdRef: MockDatabaseReference(initialData: historyThreshold),
      configThresholdRef: MockDatabaseReference(initialData: config),
    );
  }

  group('DashboardController Complete Tests', () {
    test(
      'getLastSensorData returns latest data based on sorted keys',
      () async {
        final rawData = {
          '1000': {'ph': 6.0},
          '3000': {'ph': 8.0},
          '2000': {'ph': 7.0},
        };

        mockRefs = createMockRefs(data: rawData);
        controller = DashboardController(mockRefs);

        final result = await controller.getLastSensorData().first;
        expect(result['ph'], 8.0);
      },
    );

    test('updateCurrentReading updates data and adds timestamp', () async {
      mockRefs = createMockRefs(current: {'ph': 5.0});
      controller = DashboardController(mockRefs);

      await controller.updateCurrentReading({'ph': 6.5, 'tds_ppm': 300});

      final snap = await mockRefs.currentReadingRef.get();
      final savedData = snap.value as Map;

      expect(savedData['ph'], 6.5);
      expect(savedData['tds_ppm'], 300);
      expect(savedData.containsKey('unix_ms'), true);
    });

    test('initLastValueCache populates cache from history', () async {
      final historyData = {
        'ph': {'1000': 6.0, '2000': 6.2},
        'tds_ppm': {'1500': 400},
      };

      mockRefs = createMockRefs(history: historyData);
      controller = DashboardController(mockRefs);

      await controller.initLastValueCache();

      expect(controller.lastValueCache['ph'], 6.2);
      expect(controller.lastValueCache['tds_ppm'], 400.0);
      expect(controller.lastValueCache['ec_ms_cm'], null);
    });

    test('saveIfChanged respects threshold rules', () async {
      mockRefs = createMockRefs();
      controller = DashboardController(mockRefs);

      controller.historyThreshold = HistoryThreshold(
        ph: 0.5,
        tdsPpm: 10.0,
        ecMsCm: 0.1,
        tempC: 1.0,
      );

      controller.lastValueCache['ph'] = 7.0;

      await controller.saveIfChanged({'unix_ms': 1000, 'ph': 7.2});
      var snap = await mockRefs.historyRef.child('ph').child('1000').get();
      expect(snap.exists, false);

      await controller.saveIfChanged({'unix_ms': 2000, 'ph': 7.6});
      snap = await mockRefs.historyRef.child('ph').child('2000').get();

      expect(snap.exists, true);
      expect(snap.value, 7.6);
      expect(controller.lastValueCache['ph'], 7.6);
    });

    test('saveIfChanged always removes processed data', () async {
      final timestamp = '123456789';
      final initialData = {
        timestamp: {'unix_ms': 123456789, 'ph': 7.0},
      };

      mockRefs = createMockRefs(data: initialData);
      controller = DashboardController(mockRefs);

      await controller.saveIfChanged({'unix_ms': 123456789, 'ph': 7.0});

      final snap = await mockRefs.dataRef.child(timestamp).get();
      expect(snap.exists, false);
    });

    test('moveOldDataToHistory moves only past data', () async {
      final now = DateTime.now();
      final past = now.subtract(const Duration(hours: 1));
      final future = now.add(const Duration(hours: 1));

      final rawData = {
        '${past.millisecondsSinceEpoch}': {
          'unix_ms': past.millisecondsSinceEpoch,
          'ph': 6.0,
        },
        '${future.millisecondsSinceEpoch}': {
          'unix_ms': future.millisecondsSinceEpoch,
          'ph': 8.0,
        },
      };

      mockRefs = createMockRefs(data: rawData);
      controller = DashboardController(mockRefs);

      await controller.loadThresholds();
      await controller.moveOldDataToHistory(now);

      final pastSnap = await mockRefs.dataRef
          .child(past.millisecondsSinceEpoch.toString())
          .get();
      expect(pastSnap.exists, false);

      final futureSnap = await mockRefs.dataRef
          .child(future.millisecondsSinceEpoch.toString())
          .get();
      expect(futureSnap.exists, true);
      expect((futureSnap.value as Map)['ph'], 8.0);

      final historySnap = await mockRefs.historyRef
          .child('ph')
          .child(past.millisecondsSinceEpoch.toString())
          .get();
      expect(historySnap.exists, true);
      expect(historySnap.value, 6.0);
    });

    test('loadConfig parses config and generates thresholds', () async {
      final configData = {
        'ph_min': 5.5,
        'ph_max': 7.5,
        'tds_min': 100,
        'tds_max': 800,
      };

      mockRefs = createMockRefs(config: configData);
      controller = DashboardController(mockRefs);

      await controller.loadConfig();

      expect(controller.config, isNotNull);
      expect(controller.config?.phMin, 5.5);
      expect(controller.thresholds['ph']!['min'], 5.5);
      expect(controller.thresholds['ph']!['max'], 7.5);
    });

    test('generateThresholdMap handles null config safely', () async {
      mockRefs = createMockRefs(config: null);
      controller = DashboardController(mockRefs);

      await controller.loadConfig();

      expect(controller.config, isNull);
      expect(controller.thresholds['ph']!['min'], 0);
    });
  });

  test('getCurrent fetches and formats data', () async {
    final currentData = {'ph': 6.54321, 'tds_ppm': 400};

    mockRefs = createMockRefs(current: currentData);
    controller = DashboardController(mockRefs);

    final result = await controller.getCurrent();

    expect(result['ph'], 6.54);
    expect(result['tds_ppm'], 400);
  });

  test('loadThresholds sets default values when empty', () async {
    mockRefs = createMockRefs(historyThreshold: null);
    controller = DashboardController(mockRefs);

    await controller.loadThresholds();

    expect(controller.historyThreshold.ph, 1.0);
    expect(controller.historyThreshold.tdsPpm, 50.0);
  });

  test('saveIfChanged ignores null sensor values', () async {
    mockRefs = createMockRefs();
    controller = DashboardController(mockRefs);

    await controller.saveIfChanged({'unix_ms': 1000, 'ph': null});

    final snap = await mockRefs.historyRef.child('ph').child('1000').get();
    expect(snap.exists, false);
  });

  test('saveIfChanged ignores data without unix_ms', () async {
    mockRefs = createMockRefs();
    controller = DashboardController(mockRefs);

    await controller.saveIfChanged({'ph': 7.0});

    final snap = await mockRefs.historyRef.child('ph').get();
    expect(snap.exists, false);
  });

  test('saveIfChanged ignores null sensor values', () async {
    mockRefs = createMockRefs();
    controller = DashboardController(mockRefs);

    await controller.saveIfChanged({'unix_ms': 1000, 'ph': null});

    final snap = await mockRefs.historyRef.child('ph').child('1000').get();
    expect(snap.exists, false);
  });
}
