import 'package:flutter/material.dart';
import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import '../app_globals.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final DeviceController controller = DeviceController(AppGlobals.refs);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control Devices')),
      body: StreamBuilder<DeviceModel>(
        stream: controller.getDeviceStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final device = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                buildSwitch(
                  title: 'Pompa Asam',
                  value: device.pumpAcid,
                  onChanged: (val) => controller.updateDevice('pump_acid', val),
                ),
                buildSwitch(
                  title: 'Pompa Nutrisi',
                  value: device.pumpNutrient,
                  onChanged: (val) =>
                      controller.updateDevice('pump_nutrient', val),
                ),
                buildSwitch(
                  title: 'Lampu',
                  value: device.lamp,
                  onChanged: (val) => controller.updateDevice('lamp', val),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildSwitch({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
        ),
      ),
    );
  }
}
