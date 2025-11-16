import '../models/device_model.dart';
import '../helper/manager.dart';

class DeviceController {
  final FirebaseRefs refs;
  DeviceController(this.refs);

  Stream<DeviceModel> getDeviceStream() {
    return refs.deviceRef.onValue.map((event) {
      if (event.snapshot.value == null) {
        return DeviceModel(pumpAcid: false, pumpNutrient: false, lamp: false);
      }
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      return DeviceModel.fromMap(map);
    });
  }

  // Update status
  Future<void> updateDevice(String key, bool value) async {
    await refs.deviceRef.child(key).set(value);
  }

  // Update semua sekaligus
  Future<void> updateAll(DeviceModel device) async {
    await refs.deviceRef.set(device.toMap());
  }
}
