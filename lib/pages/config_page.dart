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
    'temp_min_c': TextEditingController(),
    'temp_max_c': TextEditingController(),
    'tds_min_ppm': TextEditingController(),
    'tds_max_ppm': TextEditingController(),
    'ec_min_ms_cm': TextEditingController(),
    'ec_max_ms_cm': TextEditingController(),
    'is_manual': TextEditingController(),
  };

  bool isManual = false;

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
      isManual = config.isManual;
    }
    setState(() {});
  }

  void _save() async {
    // === TAMPILKAN KONFIRMASI ===
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
            "Apakah Anda yakin ingin menyimpan perubahan konfigurasi?",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      // === VALIDASI & BIKIN CONFIG DI DALAM TRY ===
      final config = ConfigModel(
        phMin: parseOrThrow("pH Minimum", fields['ph_min']!.text),
        phMax: parseOrThrow("pH Maximum", fields['ph_max']!.text),
        tempMin: parseOrThrow(
          "Temperature Minimum",
          fields['temp_min_c']!.text,
        ),
        tempMax: parseOrThrow(
          "Temperature Maximum",
          fields['temp_max_c']!.text,
        ),
        tdsMin: parseOrThrow("TDS Minimum", fields['tds_min_ppm']!.text),
        tdsMax: parseOrThrow("TDS Maximum", fields['tds_max_ppm']!.text),
        ecMin: parseOrThrow("EC Minimum", fields['ec_min_ms_cm']!.text),
        ecMax: parseOrThrow("EC Maximum", fields['ec_max_ms_cm']!.text),
        isManual: isManual,
      );

      await controller.saveConfig(config);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.teal.shade400,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Konfigurasi berhasil disimpan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Input Tidak Valid"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  double parseOrThrow(String label, String text) {
    final val = double.tryParse(text);
    if (val == null) {
      throw Exception("$label harus berupa angka");
    }
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FFF4),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
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
                      "Smart Farm Setting",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  "Edit Batas Sensor",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                buildSensorSection("pH", fields['ph_min']!, fields['ph_max']!),
                buildSensorSection(
                  "Temperature",
                  fields['temp_min_c']!,
                  fields['temp_max_c']!,
                ),
                buildSensorSection(
                  "TDS",
                  fields['tds_min_ppm']!,
                  fields['tds_max_ppm']!,
                ),
                buildSensorSection(
                  "EC",
                  fields['ec_min_ms_cm']!,
                  fields['ec_max_ms_cm']!,
                ),

                const SizedBox(height: 20),

                // Switch IS MANUAL
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FFF4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Control Device (Manual)",
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: isManual,
                        onChanged: (v) {
                          setState(() {
                            isManual = v;
                            fields['is_manual']!.text = v.toString();
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.teal.shade300,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade400,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  //     UI FOR MIN / MAX INPUT
  // ===============================
  Widget buildSensorSection(
    String title,
    TextEditingController minCtrl,
    TextEditingController maxCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // Label min/max
        Row(
          children: [
            Expanded(
              child: Text(
                "Min",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Max",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Input min/max
        Row(
          children: [
            Expanded(child: buildPillInput("Min", minCtrl)),
            const SizedBox(width: 12),
            Expanded(child: buildPillInput("Max", maxCtrl)),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildPillInput(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDFFEF0),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
