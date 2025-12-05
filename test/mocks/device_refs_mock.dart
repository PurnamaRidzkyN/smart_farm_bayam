import 'package:firebase_database/firebase_database.dart';
import 'package:smart_farm_bayam/helper/manager.dart';
import 'package:mockito/mockito.dart';

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

// Mock DatabaseReference
class MockDatabaseReference implements DatabaseReference {
  final MockDataSnapshot snapshot;

  MockDatabaseReference({required this.snapshot});

  @override
  Future<DataSnapshot> get() async => snapshot;

  @override
  DatabaseReference child(String path) => this;

  @override
  Future<void> set(dynamic value) async {}

  @override
  Stream<DatabaseEvent> get onValue => Stream.value(MockDatabaseEvent(snapshot: snapshot));

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

// Mock FirebaseRefs untuk DeviceController
class MockDeviceFirebaseRefs extends Mock implements FirebaseRefs {
  late final DatabaseReference deviceRef;
  late final DatabaseReference configThresholdRef;

  MockDeviceFirebaseRefs({
    required MockDatabaseReference device,
    required MockDatabaseReference config,
  }) {
    deviceRef = device;
    configThresholdRef = config;
  }
}

