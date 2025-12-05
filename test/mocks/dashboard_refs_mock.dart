import 'package:firebase_database/firebase_database.dart';
import 'package:smart_farm_bayam/helper/manager.dart';
import 'dart:async';

// Mock DataSnapshot
class MockDataSnapshot implements DataSnapshot {
  final bool _exists;
  final dynamic _value;

  MockDataSnapshot({bool exists = true, dynamic value})
      : _exists = exists,
        _value = value;

  @override
  bool get exists => _exists;

  @override
  dynamic get value => _value;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock DatabaseReference (DIPERBAIKI)
class MockDatabaseReference implements DatabaseReference {
  // Penyimpanan data yang bisa berubah (Mutable)
  dynamic _currentData;
  
  // Cache untuk child references supaya state persisten
  final Map<String, MockDatabaseReference> _childrenVars = {};

  MockDatabaseReference({dynamic initialData}) : _currentData = initialData;

  @override
  Future<DataSnapshot> get() async {
    // Selalu kembalikan snapshot berdasarkan data TERBARU (_currentData)
    return MockDataSnapshot(
      exists: _currentData != null,
      value: _currentData,
    );
  }

  @override
  DatabaseReference child(String path) {
    // Jika child ref sudah pernah dibuat, gunakan instance yang sama (supaya state terjaga)
    if (_childrenVars.containsKey(path)) {
      return _childrenVars[path]!;
    }

    // Jika belum, cek apakah parent punya data Map untuk path ini
    dynamic childInitialData;
    if (_currentData is Map && (_currentData as Map).containsKey(path)) {
      childInitialData = _currentData[path];
    }

    // Buat ref baru dan simpan di cache
    final newChild = MockDatabaseReference(initialData: childInitialData);
    _childrenVars[path] = newChild;
    
    return newChild;
  }

  @override
  Future<void> set(dynamic value) async {
    // Update data lokal
    if (_currentData is Map && value is Map) {
      (_currentData as Map).addAll(value);
    } else {
      _currentData = value;
    }
  }
  
  @override
  Future<void> update(Map<String, Object?> value) async {
    if (_currentData == null) _currentData = {};
    if (_currentData is Map) {
      (_currentData as Map).addAll(value);
    }
  }

  @override
  Future<void> remove() async {
    _currentData = null;
  }

  // Stream sederhana: hanya emit data saat ini sekali
  @override
  Stream<DatabaseEvent> get onValue {
    final snap = MockDataSnapshot(exists: _currentData != null, value: _currentData);
    return Stream.value(MockDatabaseEvent(snapshot: snap));
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock DatabaseEvent
class MockDatabaseEvent implements DatabaseEvent {
  final DataSnapshot snapshot;
  MockDatabaseEvent({required this.snapshot});

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock FirebaseRefs
class MockDashboardFirebaseRefs implements FirebaseRefs {
  late final DatabaseReference dataRef;
  late final DatabaseReference currentReadingRef;
  late final DatabaseReference historyRef;
  late final DatabaseReference historyThresholdRef;
  late final DatabaseReference configThresholdRef;

  MockDashboardFirebaseRefs({
    required this.dataRef,
    required this.currentReadingRef,
    required this.historyRef,
    required this.historyThresholdRef,
    required this.configThresholdRef,
  });

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}