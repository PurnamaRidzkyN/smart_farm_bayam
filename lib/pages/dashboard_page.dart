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
  Map<String, dynamic> thresholds = {};

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

  void loadThresholdMap() {
    thresholds = {
      "ph": {"min": 0, "max": controller.thresholds.ph},
      "tds_ppm": {"min": 0, "max": controller.thresholds.tdsPpm},
      "ec_ms_cm": {"min": 0, "max": controller.thresholds.ecMsCm},
      "temp_c": {"min": 0, "max": controller.thresholds.tempC},
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: controller.loadThresholds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // UPDATE: masukkan threshold ke map lokal
        loadThresholdMap();

        return data == null
            ? const Center(child: CircularProgressIndicator())
            : buildDashboard(context);
      },
    );
  }

  Widget buildDashboard(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        color: const Color(0xFFE6FFF2),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Smart Farm",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Status Hari Ini
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFFBEF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_florist,
                            size: 40,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Status Hari Ini",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatIso(data?["timestamp_iso"]),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Grid sensor 2x2
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.1,
                          ),
                      children: [
                        sensorBox(
                          "pH Level",
                          "${data?['ph'] ?? '-'}",
                          getDotColor("ph"),
                        ),
                        sensorBox(
                          "Temperature",
                          "${data?['temp_c'] ?? '-'}°C",
                          getDotColor("temp_c"),
                        ),
                        sensorBox(
                          "TDS (ppm)",
                          "${data?['tds_ppm'] ?? '-'}",
                          getDotColor("tds_ppm"),
                        ),
                        sensorBox(
                          "EC",
                          "${data?['ec_ms_cm'] ?? '-'}",
                          getDotColor("ec_ms_cm"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Legend
                    statusLegend(Colors.green, "Normal"),
                    const SizedBox(height: 6),
                    statusLegend(Colors.orange, "Warning"),
                    const SizedBox(height: 6),
                    statusLegend(Colors.red, "Danger"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //                          SENSOR CARD BARU

  Widget sensorBox(String title, String value, Color dotColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDFFBEF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.circle, size: 12, color: dotColor),
          ),
          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(title, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  //                       STATUS LEGEND (NORMAL/WARNING/DANGER)

  Widget statusLegend(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 14),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  //                         STATUS COLOR BY THRESHOLD

  Color getDotColor(String key) {
    if (data == null || !data!.containsKey(key)) return Colors.grey;
    if (!thresholds.containsKey(key)) return Colors.grey;

    // ini bisa disesuaikan dengan data di firebase
    final value = (data![key] ?? 0).toDouble();
    final min = thresholds[key]["min"] ?? 0.0;
    final max = thresholds[key]["max"] ?? 99999.0;

    // --- DANGER ---
    if (value < min) return Colors.red;
    if (value > max) return Colors.red;

    // --- WARNING (nilai tepat di batas) ---
    if (value == min) return Colors.orange;
    if (value == max) return Colors.orange;

    // --- NORMAL ---
    return Colors.green;
  }


  String formatIso(String? iso) {
    if (iso == null || iso.isEmpty) return "-";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (e) {
      return iso;
    }
  }
}
