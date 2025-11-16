import 'package:flutter/material.dart';
import '../controllers/config_controller.dart';
import '../models/config_model.dart';
import '../app_globals.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final controller = ConfigController(AppGlobals.refs);
  final Map<String, TextEditingController> fields = {
    'ph_min': TextEditingController(),
    'ph_max': TextEditingController(),
    'tds_min_ppm': TextEditingController(),
    'tds_max_ppm': TextEditingController(),
    'ec_min_ms_cm': TextEditingController(),
    'ec_max_ms_cm': TextEditingController(),
    'temp_min_c': TextEditingController(),
    'temp_max_c': TextEditingController(),
    'light_on_hour': TextEditingController(),
    'light_off_hour': TextEditingController(),
    'is_manual': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final config = await controller.loadConfig();
    if (config != null) {
      final map = config.toMap();
      map.forEach((key, value) {
        if (fields.containsKey(key)) {
          fields[key]!.text = value.toString();
        }
      });
    }
    setState(() {});
  }

  void _save() {
    final config = ConfigModel(
      phMin: double.tryParse(fields['ph_min']!.text) ?? 0,
      phMax: double.tryParse(fields['ph_max']!.text) ?? 0,
      tdsMin: double.tryParse(fields['tds_min_ppm']!.text) ?? 0,
      tdsMax: double.tryParse(fields['tds_max_ppm']!.text) ?? 0,
      ecMin: double.tryParse(fields['ec_min_ms_cm']!.text) ?? 0,
      ecMax: double.tryParse(fields['ec_max_ms_cm']!.text) ?? 0,
      tempMin: double.tryParse(fields['temp_min_c']!.text) ?? 0,
      tempMax: double.tryParse(fields['temp_max_c']!.text) ?? 0,
      isManual: fields['is_manual']!.text.toLowerCase() == 'true',
      lightOnHour: int.tryParse(fields['light_on_hour']!.text) ?? 6,
      lightOffHour: int.tryParse(fields['light_off_hour']!.text) ?? 18,
    );

    controller.saveConfig(config);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Konfigurasi berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfigurasi Smart Farm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Edit Batas Sensor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...fields.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: entry.value,
                decoration: InputDecoration(
                  labelText: entry.key.replaceAll('_', ' ').toUpperCase(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            );
          }),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }
}
