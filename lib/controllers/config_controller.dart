import '../models/config_model.dart';
import '../helper/manager.dart';

class ConfigController {
  final FirebaseRefs refs;

  ConfigController(this.refs);

  // Load config
  Future<ConfigModel?> loadConfig() async {
    final snapshot = await refs.configThresholdRef.get();
    if (!snapshot.exists) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return ConfigModel.fromMap(data);
  }

  // Save config
  Future<void> saveConfig(ConfigModel config) async {
    await refs.configThresholdRef.set(config.toMap());
  }
}
