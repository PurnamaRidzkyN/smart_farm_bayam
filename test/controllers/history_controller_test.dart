import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_bayam/controllers/history_controller.dart';
import '../mocks/dashboard_refs_mock.dart';

void main() {
  late HistoryController controller;
  late MockDashboardFirebaseRefs mockRefs;

  MockDashboardFirebaseRefs createMockRefs({
    Map<String, dynamic>? history,
    Map<String, dynamic>? historyThreshold,
  }) {
    return MockDashboardFirebaseRefs(
      dataRef: MockDatabaseReference(initialData: {}),
      currentReadingRef: MockDatabaseReference(initialData: {}),
      configThresholdRef: MockDatabaseReference(initialData: {}),
      historyRef: MockDatabaseReference(initialData: history),
      historyThresholdRef:
          MockDatabaseReference(initialData: historyThreshold),
    );
  }

  group('HistoryController', () {
    test('loadThresholds returns data when exists', () async {
      mockRefs = createMockRefs(historyThreshold: {
        'ph': 1.0,
        'tds_ppm': 50.0,
      });
      controller = HistoryController(mockRefs);

      final result = await controller.loadThresholds();

      expect(result['ph'], 1.0);
      expect(result['tds_ppm'], 50.0);
    });

    test('loadThresholds returns empty map when not exists', () async {
      mockRefs = createMockRefs(historyThreshold: null);
      controller = HistoryController(mockRefs);

      final result = await controller.loadThresholds();

      expect(result, isEmpty);
    });

    test('saveThresholds writes data correctly', () async {
      mockRefs = createMockRefs();
      controller = HistoryController(mockRefs);

      await controller.saveThresholds({
        'ph': 2.5,
        'temp_c': 10.0,
      });

      final snap = await mockRefs.historyThresholdRef.get();
      final saved = snap.value as Map;

      expect(saved['ph'], 2.5);
      expect(saved['temp_c'], 10.0);
    });

    test('loadHistoryData aggregates sensor data', () async {
      mockRefs = createMockRefs(history: {
        'ph': {'1000': 6.0},
        'tds_ppm': {'2000': 500.0},
      });
      controller = HistoryController(mockRefs);

      final result = await controller.loadHistoryData();

      expect(result['ph']?['1000'], 6.0);
      expect(result['tds_ppm']?['2000'], 500.0);
      expect(result['ec_ms_cm'], isEmpty);
      expect(result['temp_c'], isEmpty);
    });

    test('loadHistoryFiltered filters data by date range', () async {
      final now = DateTime.now();
      final tPast = now.subtract(const Duration(days: 5));
      final tTarget = now.subtract(const Duration(hours: 1));
      final tFuture = now.add(const Duration(days: 5));

      mockRefs = createMockRefs(history: {
        'ph': {
          '${tPast.millisecondsSinceEpoch}': 5.0,
          '${tTarget.millisecondsSinceEpoch}': 7.0,
          '${tFuture.millisecondsSinceEpoch}': 9.0,
        }
      });
      controller = HistoryController(mockRefs);

      final result = await controller.loadHistoryFiltered(
        'ph',
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(days: 1)),
      );

      expect(result.length, 1);
      expect(result.containsKey('${tTarget.millisecondsSinceEpoch}'), true);
    });

    test('loadHistoryFiltered returns empty when no data', () async {
      mockRefs = createMockRefs(history: {});
      controller = HistoryController(mockRefs);

      final result = await controller.loadHistoryFiltered(
        'ph',
        DateTime.now(),
        DateTime.now().add(const Duration(days: 1)),
      );

      expect(result, isEmpty);
    });

    test('deleteAllHistory clears history node', () async {
      mockRefs = createMockRefs(history: {
        'ph': {'123': 7.0},
      });
      controller = HistoryController(mockRefs);

      await controller.deleteAllHistory();

      final snap = await mockRefs.historyRef.get();
      expect(snap.value, anyOf(null, isEmpty));
    });
  });
}
