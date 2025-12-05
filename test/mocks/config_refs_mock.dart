import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_farm_bayam/helper/manager.dart';

// Mock DataSnapshot
class MockDataSnapshot extends Mock implements DataSnapshot {
  final bool _exists;
  final dynamic _value;

  MockDataSnapshot({bool exists = true, dynamic value})
      : _exists = exists,
        _value = value;

  @override
  bool get exists => _exists;

  @override
  dynamic get value => _value;
}

// Mock DatabaseReference
class MockDatabaseReference extends Mock implements DatabaseReference {
  final MockDataSnapshot snapshot;

  MockDatabaseReference({required this.snapshot});

  @override
  Future<DataSnapshot> get() async => snapshot;

  @override
  Future<void> set(dynamic value) async {}
}

// Mock FirebaseRefs
class MockFirebaseRefs extends Mock implements FirebaseRefs {
  late final DatabaseReference configThresholdRef;

  MockFirebaseRefs({required MockDatabaseReference ref}) {
    configThresholdRef = ref;
  }
}
