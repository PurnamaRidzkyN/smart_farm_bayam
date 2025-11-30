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

    // 1. Load thresholds
    controller.loadThresholds().then((_) {
      // Bersihkan data lama sebelum page aktif
      Future.microtask(() => controller.moveOldDataToHistory(DateTime.now()));
    });

    // 2. Ambil current reading awal untuk tampil di UI
    controller.getCurrent().then((initial) {
      if (!mounted) return;
      setState(() {
        data = initial ?? {};
      });
    });

    // 3. Listener realtime data baru dari sensor
    controller.getLastSensorData().listen((newData) async {
      if (newData.isEmpty) return;

      // 1. Format semua angka ke 2 desimal
      final formattedData = newData.map(
        (k, v) =>
            MapEntry(k, (v is num) ? double.parse(v.toStringAsFixed(2)) : v),
      );

      // 2. Update current reading
      await controller.updateCurrentReading(formattedData);

      // 3. Simpan ke history & hapus dataRef
      await controller.moveOldDataToHistory(DateTime.now());
      // ← sekarang dipanggil tiap ada data baru

      // 4. Update UI langsung
      if (!mounted) return;
      setState(() {
        data = {
          ...data!,
          ...formattedData,
          'unix_ms': DateTime.now().millisecondsSinceEpoch,
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: controller.loadConfig(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // UPDATE: masukkan threshold ke map lokal
        thresholds = controller.thresholds;

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
                                formatUnixMs(data?["unix_ms"]),
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

  String formatUnixMs(dynamic unixMs) {
    if (unixMs == null) return "-";
    // konversi dynamic -> int
    final ms = (unixMs is double) ? unixMs.toInt() : unixMs as int;
    final dt = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
