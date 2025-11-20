import 'package:flutter/material.dart';
import '../controllers/dashboard_controller.dart';
import '../app_globals.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController controller = DashboardController(AppGlobals.refs);
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
      controller.getCurrent().then((initial) {
          setState(() {
            data = initial ?? {};
          });
        });
    // Bersihkan data lama ke history saat login
    Future.microtask(() => controller.moveOldDataToHistory(DateTime.now()));

    // Stream realtime untuk UI
    controller.getLastSensorData().listen((newData) async {
    if (newData.isNotEmpty) {
      controller.updateCurrentReading(newData);
      controller.saveIfChanged(newData);
    }

    final latest = await controller.getCurrent();
    print("LATEST CURRENT READING: $latest");

    setState(() {
      data = latest ?? {};
    });
  });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: controller.loadThresholds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Pastikan moveOldDataToHistory hanya dipanggil sekali
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.moveOldDataToHistory(DateTime.now());
        });

        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard Smart Farm')),
          drawer: buildDrawer(context),
          body: data == null
              ? const Center(child: CircularProgressIndicator())
              : buildDashboard(context),
        );
      },
    );
  }

  Widget buildSensorCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.green),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatIso(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return iso; // fallback ke string asli kalau error
    }
  }

  Widget buildDashboard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          buildSensorCard("pH", "${data?['ph'] ?? '-'}", Icons.science),
          buildSensorCard(
            "TDS (ppm)",
            "${data?['tds_ppm'] ?? '-'}",
            Icons.water_drop,
          ),
          buildSensorCard(
            "EC (mS/cm)",
            "${data?['ec_ms_cm'] ?? '-'}",
            Icons.electrical_services,
          ),
          buildSensorCard(
            "Suhu (°C)",
            "${data?['temp_c'] ?? '-'}",
            Icons.thermostat,
          ),

          const SizedBox(height: 16),
          Text(
            "Terakhir update: ${formatIso(data?['timestamp_iso'] as String?)}",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(
              "Menu",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Config"),
            onTap: () => Navigator.pushNamed(context, "/config"),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("History"),
            onTap: () => Navigator.pushNamed(context, "/history"),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Pemberitahuan"),
            onTap: () => Navigator.pushNamed(context, "/notif"),
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text("Kontrol Device"),
            onTap: () => Navigator.pushNamed(context, "/device"),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Keluar Aplikasi"),
            onTap: () => Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.pop(context);
            }),
          ),
        ],
      ),
    );
  }
}
