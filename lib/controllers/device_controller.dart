import '../models/device_model.dart';
import '../helper/manager.dart';

class DeviceController {
  final FirebaseRefs refs;
  DeviceController(this.refs);

  Stream<DeviceModel> getDeviceStream() {
    return refs.deviceRef.onValue.map((event) {
      if (event.snapshot.value == null) {
        return DeviceModel(pumpAcid: false, pumpNutrient: false);
      }
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      return DeviceModel.fromMap(map);
    });
  }

  Future<bool> _canEdit() async {
    final snap = await refs.configThresholdRef.child("is_manual").get();
    if (!snap.exists) return true; 
    return snap.value == true;
  }

  Future<void> updateDevice(String key, bool value) async {
    final allowed = await _canEdit();
    if (!allowed) {
      // Lagi mode otomatis, jangan sentuh apa-apa
      throw Exception("Device tidak bisa diubah dalam mode otomatis silahkan ganti ke mode manual dibagian config");
    }
    await refs.deviceRef.child(key).set(value);
  }

  Future<void> updateAll(DeviceModel device) async {
    final allowed = await _canEdit();
    if (!allowed) {
      throw Exception("Device tidak bisa diubah dalam mode otomatis silahkan ganti ke mode manual dibagian config");
    }
    await refs.deviceRef.set(device.toMap());
  }
}
