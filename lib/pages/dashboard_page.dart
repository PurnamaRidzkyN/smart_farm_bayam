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

    _initializeController();
  }

  Future<void> _initializeController() async {
    // 1. Load thresholds
    await controller.loadThresholds();

    // 2. Bersihkan readings lama saat page pertama load
    await controller.initLastValueCache();
    await controller.moveOldDataToHistory(DateTime.now());

    // 3. Ambil current reading awal untuk tampil di UI
    final initial = await controller.getCurrent();
    if (!mounted) return;
    setState(() {
      data = initial ?? {};
    });

    // 4. Listener realtime data baru dari sensor, dimulai setelah semua selesai
    controller.getLastSensorData().listen((newData) async {
      if (newData.isEmpty) return;

      final formattedData = newData.map(
        (k, v) =>
            MapEntry(k, (v is num) ? double.parse(v.toStringAsFixed(2)) : v),
      );

      await controller.updateCurrentReading(formattedData);
      await controller.saveIfChanged(formattedData); // langsung ke history

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
        // Dipanggil lagi di sini untuk memastikan data terbaru terambil
        thresholds = controller.thresholds;

        return data == null
            ? const Center(child: CircularProgressIndicator())
            : buildDashboard(context);
      },
    );
  }

  Widget buildDashboard(BuildContext context) {
    return Scaffold( // Menggunakan Scaffold untuk latar belakang dan struktur
      backgroundColor: const Color(0xFFE6FFF2), // Latar belakang Dashboard
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: const Color(0xFFE6FFF2),
          child: SingleChildScrollView(
            // PERBAIKAN PADDING: Mengatur padding bawah agar tidak terlalu jauh dari Bottom Nav Bar
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

                      // Status Hari Ini Card
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
                              color: Color(0xFF38A3A5), // Warna hijau teal
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
                      // GridView sudah aman karena menggunakan shrinkWrap: true di dalam SingleChildScrollView
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
                // Padding di bawah card agar tidak terlalu mepet dengan BottomNavBar
                const SizedBox(height: 80), 
              ],
            ),
          ),
        ),
      ),
      // Jika Anda menggunakan BottomNavigationBar di sini (diasumsikan), 
      // pastikan Scaffold menanganinya dengan benar.
      // Jika BottomNavigationBar adalah bagian dari layout parent, abaikan ini.
    );
  }

  // =====================================================================
  // 	SENSOR CARD BARU
  // =====================================================================

  Widget sensorBox(String title, String value, Color dotColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDFFBEF), 
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        // PERBAIKAN 1: Gunakan CrossAxisAlignment.center agar rata tengah horizontal
        crossAxisAlignment: CrossAxisAlignment.center, 
        // PERBAIKAN 2: Gunakan MainAxisAlignment.spaceBetween untuk memastikan dot di atas dan judul di bawah
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          // Dot Status (ditempatkan di pojok kanan atas)
          // Menggunakan Row untuk menempatkan dot di kanan dan Padding/Spacer di kiri
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.circle, size: 10, color: dotColor),
            ],
          ),
          
          // Nilai Sensor
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            // PERBAIKAN 3: Text Aligment Center memastikan teks senter di widget Text
            textAlign: TextAlign.center, 
          ),

          // Judul Sensor
          Text(
            title, 
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            textAlign: TextAlign.center, // Memastikan teks judul juga senter
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // 	STATUS LEGEND (NORMAL/WARNING/DANGER)
  // =====================================================================

  Widget statusLegend(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 14),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  // =====================================================================
  // 	STATUS COLOR BY THRESHOLD - LOGIKA DIPERBAIKI
  // =====================================================================

  Color getDotColor(String key) {
    if (data == null || !data!.containsKey(key)) return Colors.grey;
    if (!thresholds.containsKey(key)) return Colors.grey;

    final value = (data![key] ?? 0).toDouble();
    
    // Perbaikan untuk mengakses min/max dari sub-map 
    final thresholdMap = thresholds[key] is Map ? (thresholds[key] as Map<String, dynamic>) : {};
    
    final double min = (thresholdMap["min"] as num?)?.toDouble() ?? 0.0;
    final double max = (thresholdMap["max"] as num?)?.toDouble() ?? 99999.0;

    // Toleransi Warning (misalnya, 5% dari rentang ideal, atau nilai mutlak)
    // Untuk pH (7.0), TDS (800), Temp (25.0), kita pakai toleransi mutlak yang wajar.
    double tolerance;
    switch (key) {
      case "ph":
        tolerance = 0.5; // pH 6.5-7.5 (Normal)
        break;
      case "temp_c":
        tolerance = 5.0; // Temp 20-30°C (Normal)
        break;
      case "tds_ppm":
      case "ec_ms_cm":
        // Asumsi batas min/max TDS/EC lebih ketat
        tolerance = (max - min) * 0.1; 
        if (tolerance < 10) tolerance = 10; // min 10 ppm warning
        break;
      default:
        tolerance = 0.0;
    }
    
    // Batas Warning: sedikit di dalam batas min/max
    final double warnMin = min + tolerance;
    final double warnMax = max - tolerance;

    // 1. --- DANGER ---
    // Di luar batas min atau max
    if (value < min || value > max) {
        return Colors.red;
    }
    
    // 2. --- WARNING ---
    // Di antara batas min dan warnMin ATAU di antara warnMax dan max
    if (value < warnMin || value > warnMax) {
        return Colors.orange;
    }

    // 3. --- NORMAL ---
    return Colors.green;
  }

  // =====================================================================
  // 	FORMAT TANGGAL
  // =====================================================================

  String formatUnixMs(dynamic unixMs) {
    if (unixMs == null) return "-";
    // konversi dynamic -> int
    final ms = (unixMs is double) ? unixMs.toInt() : unixMs as int;
    final dt = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
