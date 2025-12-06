import 'package:firebase_database/firebase_database.dart';
import 'package:smart_farm_bayam/helper/manager.dart'; // Pastikan path ini sesuai project kamu
import 'dart:async';

class MockDataSnapshot implements DataSnapshot {
  final dynamic _value;
  MockDataSnapshot({dynamic value}) : _value = value;

  @override
  bool get exists => _value != null;
  @override
  dynamic get value => _value;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// =========================================================
// 2. MOCK DATABASE REFERENCE (PINTAR & SHARED MEMORY)
// =========================================================
class MockSmartDatabaseRef implements DatabaseReference {
  // Ini memori bersama. Semua child/parent mengarah ke Map yang sama.
  final Map<String, dynamic> sharedStore;
  final String pathKey;

  MockSmartDatabaseRef(this.sharedStore, this.pathKey);

  // --- Helper untuk mengambil data yang benar ---
  dynamic _getScopedData() {
    if (pathKey == 'root_device') {
      // Kalau ambil root, return semua data KECUALI config internal
      final val = {...sharedStore};
      val.remove('is_manual');
      return val;
    } else {
      // Kalau ambil child (misal: 'pump_acid'), return value-nya aja
      return sharedStore[pathKey];
    }
  }

  @override
  Future<DataSnapshot> get() async {
    return MockDataSnapshot(value: _getScopedData());
  }

  @override
  DatabaseReference child(String path) {
    // Child tetap menggunakan memori yang sama
    return MockSmartDatabaseRef(sharedStore, path);
  }

  @override
  Future<void> set(dynamic value) async {
    // [PERBAIKAN PENTING DI SINI]
    // Kalau kita set di 'root_device' (misal dari updateAll),
    // jangan bikin key baru 'root_device', tapi sebar datanya ke sharedStore.
    if (pathKey == 'root_device' && value is Map) {
      value.forEach((k, v) {
        sharedStore[k] = v;
      });
    } else {
      // Kalau set di child spesifik (misal updateDevice 'pump_acid')
      sharedStore[pathKey] = value;
    }
  }

  @override
  Future<void> update(Map<String, Object?> value) async {
    if (pathKey == 'root_device') {
      value.forEach((k, v) => sharedStore[k] = v);
    } else {
      // Simulasi update pada child node
      if (sharedStore[pathKey] is Map) {
        (sharedStore[pathKey] as Map).addAll(value);
      } else {
        sharedStore[pathKey] = value;
      }
    }
  }

  @override
  Stream<DatabaseEvent> get onValue {
    final val = _getScopedData();
    final snap = MockDataSnapshot(value: val);
    return Stream.value(MockEvent(snapshot: snap));
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Wrapper Event
class MockEvent implements DatabaseEvent {
  final DataSnapshot snapshot;
  MockEvent({required this.snapshot});
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// =========================================================
// 3. MOCK FIREBASE REFS (UTAMA)
// =========================================================
class MockDeviceFirebaseRefs implements FirebaseRefs {
  late final DatabaseReference deviceRef;
  late final DatabaseReference
  configThresholdRef; // Sesuai nama di manager.dart

  // Database Bohongan Pusat
  final Map<String, dynamic> _fakeDatabase = {};

  MockDeviceFirebaseRefs({
    required Map<String, dynamic>? initialData, // Boleh null
    bool isManual = true, // Default Manual TRUE (Biar controller gak error)
  }) {
    // 1. Masukkan data device awal
    if (initialData != null) {
      _fakeDatabase.addAll(initialData);
    }

    // 2. Set Config Mode (Penting buat Controller Test logic _canEdit)
    _fakeDatabase['is_manual'] = isManual;

    // 3. Init Ref
    // deviceRef mengarah ke root map (nanti di filter di get/onValue)
    deviceRef = MockSmartDatabaseRef(_fakeDatabase, 'root_device');

    // configRef mengarah ke root map juga, tapi lewat helper khusus
    configThresholdRef = MockConfigRef(_fakeDatabase);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Helper Config Ref (Khusus handle is_manual)
class MockConfigRef implements DatabaseReference {
  final Map<String, dynamic> store;
  MockConfigRef(this.store);

  @override
  DatabaseReference child(String path) {
    // Kalau path == 'is_manual', kita arahkan ke store key 'is_manual'
    return MockSmartDatabaseRef(store, path);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
