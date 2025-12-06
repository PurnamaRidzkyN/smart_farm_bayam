import 'package:flutter/material.dart';
import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import '../app_globals.dart';

class DevicePage extends StatefulWidget {
  final DeviceController? controller;

  const DevicePage({super.key, this.controller});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  late final DeviceController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? DeviceController(AppGlobals.refs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFE8FFF4,
      ), // hijau sangat muda (background)
      // PERBAIKAN 1: Bungkus body dengan SafeArea
      body: SafeArea(
        child: StreamBuilder<DeviceModel>(
          stream: controller.getDeviceStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final device = snapshot.data!;

            // Gunakan SingleChildScrollView jika isi konten bisa bertambah
            return SingleChildScrollView(
              child: Column(
                children: [
                  // PERBAIKAN 2: Tambahkan ruang di atas konten untuk estetika judul
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 12,
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text(
                                "Control Device",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ====== ITEMS ======
                          buildItem(
                            title: "Pompa Asam",
                            value: device.pumpAcid,
                            onChanged: (v) =>
                                controller.updateDevice('pump_acid', v),
                          ),
                          buildItem(
                            title: "Pompa Nutrisi",
                            value: device.pumpNutrient,
                            onChanged: (v) =>
                                controller.updateDevice('pump_nutrient', v),
                          ),

                          // Tambahkan item lain di sini jika ada...

                          // Tambahkan padding di bagian bawah container
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  // Padding di bawah SingleChildScrollView
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================
  // 	CUSTOM ITEM PILL
  // ===============================
  Widget buildItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FFF4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: Colors.teal.shade300,
            onChanged: (v) async {
              try {
                await onChanged(v); // manggil controller updateDevice
              } catch (e) {
                showWarning(e.toString().replaceAll('Exception: ', ''));
                setState(
                  () {},
                ); // refresh lagi biar switch balik ke posisi awal
              }
            },
          ),
        ],
      ),
    );
  }

  void showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent.shade200,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
