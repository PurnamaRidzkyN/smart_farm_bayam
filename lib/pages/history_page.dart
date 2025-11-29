import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/history_controller.dart';
import '../app_globals.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController controller = HistoryController(AppGlobals.refs);

  Map<String, double> thresholds = {};
  Map<String, double> filteredData = {};

  String selectedSensor = "ph";
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    thresholds = await controller.loadThresholds();
    filteredData = await controller.loadHistoryFiltered(
      selectedSensor,
      startDate,
      endDate,
    );
    setState(() => loading = false);
  }

  // =====================================================================
  // 	RELOAD FILTER + AUTO BUKA POPUP
  // =====================================================================
  Future<void> _reloadFilter({bool openPopup = false}) async {
    final newData = await controller.loadHistoryFiltered(
      selectedSensor,
      startDate,
      endDate,
    );

    setState(() {
      filteredData = newData;
    });

    // jika dari sensorButton → auto popup grafik
    if (openPopup && mounted) {
      await Future.delayed(const Duration(milliseconds: 120));
      openChartPopup();
    }
  }

  // =====================================================================
  // 	POPUP THRESHOLD
  // =====================================================================
  void openThresholdPopup() {
    showDialog(
      context: context,
      builder: (context) {
        // ... (Fungsi openThresholdPopup tidak berubah) ...
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Setting Threshold",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Gunakan key yang ada di `thresholds` (seperti "ph") untuk mendapatkan nilai,
                // tapi label display menggunakan string yang lebih deskriptif.
                buildThreshold("pH", "ph"),
                buildThreshold("TDS (ppm)", "tds_ppm"),
                buildThreshold("EC (mS/cm)", "ec_ms_cm"),
                buildThreshold("Temperature (°C)", "temp_c"),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () async {
                    await controller.saveThresholds(thresholds);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                  ),
                  child: const Text(
                    "Simpan Threshold",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildThreshold(String label, String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FFF4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: TextEditingController(
          text: thresholds[key]?.toString() ?? "",
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        onChanged: (v) {
          final p = double.tryParse(v);
          if (p != null) thresholds[key] = p;
        },
      ),
    );
  }

  // =====================================================================
  // 	POPUP CHART
  // =====================================================================
  void openChartPopup() {
    // ... (Fungsi openChartPopup tidak berubah) ...
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 350,
          height: 350,
          child: Column(
            children: [
              Text(
                // Mengubah key menjadi label yang lebih baik untuk judul
                (selectedSensor == "ph" ? "pH" : selectedSensor)
                    .replaceAll("_", " ")
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: buildChart()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChart() {
    List<String> ts = filteredData.keys.toList()..sort();
    List<FlSpot> spots = [];

    for (int i = 0; i < ts.length; i++) {
      spots.add(FlSpot(i.toDouble(), filteredData[ts[i]]!));
    }

    return LineChart(
      LineChartData(
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ), // Sembunyikan label bawah
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            dotData: FlDotData(show: true),
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // 	BUILD UI
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FFF4), // Latar belakang utama
      body: SafeArea(
        // 1. Membungkus dengan SafeArea untuk mencegah pemotongan
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                // Padding hanya di bagian samping, padding atas diserahkan ke SafeArea + padding Container
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 20), // Jarak kecil di atas Main Card
                    // ================= MAIN CARD =================
                    Container(
                      // 2. Padding di dalam Container memberikan ruang yang cukup
                      //    untuk judul di bagian atas kartu.
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ================= TITLE: HISTORY (Kembali di dalam Card) =================
                          const Text(
                            "History",
                            style: TextStyle(
                              fontSize:
                                  24, // Disesuaikan agar terlihat seperti judul utama di card
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ---------- Setting Threshold Grouping ----------
                          GestureDetector(
                            onTap: openThresholdPopup,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.settings,
                                    color: Colors.teal,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Setting Threshold",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(
                            height: 24,
                            thickness: 1,
                            color: Color(0xFFE8FFF4),
                          ),

                          // ---------- SENSOR GRID LABEL ----------
                          const Text(
                            "Data Sensor",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ---------- SENSOR GRID ----------
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.3,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            children: [
                              _sensorButtonIcon("pH", "ph", Icons.science),
                              _sensorButtonIcon(
                                "Temp",
                                "temp_c",
                                Icons.thermostat_outlined,
                              ),
                              _sensorButtonIcon(
                                "TDS",
                                "tds_ppm",
                                Icons.water_drop_outlined,
                              ),
                              _sensorButtonIcon(
                                "EC",
                                "ec_ms_cm",
                                Icons.power_outlined,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ---------- DATE RANGE LABEL ----------
                          const Text(
                            "Pilih Rentang Waktu",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ---------- DATE RANGE PICKER BUTTON ----------
                          GestureDetector(
                            onTap: selectDateRange,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8FFF4),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${_formatDate(startDate)} - ${_formatDate(endDate)}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.teal,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // ---------- DELETE HISTORY BUTTON ----------
                          _deleteHistoryButton(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // =====================================================================
  // 	SENSOR BUTTON (Menggunakan ikon dan warna dari gambar)
  // =====================================================================
  Widget _sensorButtonIcon(String title, String key, IconData icon) {
    // Tentukan warna ikon dan latar belakang berdasarkan key
    Color iconColor;
    Color bgColor;

    switch (key) {
      case "ph":
        iconColor = const Color(0xFF38A3A5); // Warna ikon untuk pH
        bgColor = const Color(0xFFE8FFF4); // Warna latar belakang tombol pH
        break;
      case "temp_c":
        iconColor = const Color(0xFFE56B6F); // Warna ikon untuk Temp
        bgColor = const Color(0xFFFFF0F0);
        break;
      case "tds_ppm":
        iconColor = const Color(0xFF4C8CDA); // Warna ikon untuk TDS
        bgColor = const Color(0xFFF0F8FF);
        break;
      case "ec_ms_cm":
        iconColor = const Color(0xFF8B5CF6); // Warna ikon untuk EC
        bgColor = const Color(0xFFF5F0FF);
        break;
      default:
        iconColor = Colors.teal;
        bgColor = const Color(0xFFE8FFF4);
    }

    // Warna Latar belakang saat terpilih
    final isSelected = key == selectedSensor;
    final buttonColor = isSelected ? bgColor.withOpacity(0.8) : Colors.white;

    return GestureDetector(
      onTap: () async {
        setState(() => selectedSensor = key);
        _reloadFilter(openPopup: true);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(color: iconColor.withOpacity(0.5), width: 2)
              : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon Disesuaikan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // 	TOMBOL DELETE HISTORY
  // =====================================================================
  Widget _deleteHistoryButton() {
    return GestureDetector(
      onTap: () async {
        // === KONFIRMASI DULU ===
        final bool? confirm = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Konfirmasi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                "Apakah Anda yakin ingin menghapus semua history?",
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Hapus", style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );

        // Jika user memilih "Batal"
        if (confirm != true) return;

        // Jika user memilih "Hapus"
        await controller.deleteAllHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("History berhasil dihapus")),
        );

        // Reload tampilan history
        _reloadFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Delete History",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.cached, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }


  // =====================================================================
  // 	DATE RANGE PICKER
  // =====================================================================
  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal, // Warna utama
              onPrimary: Colors.white, // Warna teks pada primary
              surface: Colors.white, // Warna permukaan (background)
              onSurface: Colors.black, // Warna teks pada permukaan
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Menggunakan tanggal awal jam 00:00:00 dan tanggal akhir jam 23:59:59
        startDate = DateTime(
          picked.start.year,
          picked.start.month,
          picked.start.day,
        );
        endDate = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        );
      });

      _reloadFilter();
    }
  }

  // =====================================================================
  // 	FORMAT TANGGAL: MM/DD/YYYY
  // =====================================================================
  String _formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
  }
}
