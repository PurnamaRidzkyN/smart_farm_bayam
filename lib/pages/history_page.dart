import 'package:flutter/material.dart';
import '../controllers/history_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_globals.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController controller = HistoryController(AppGlobals.refs);
  Map<String, double> thresholds = {};
  Map<String, Map<String, double>> historyData = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    thresholds = await controller.loadThresholds();
    historyData = await controller.loadHistoryData();
    setState(() => loading = false);
  }

  // Simpan threshold
  void _saveThresholds() async {
    await controller.saveThresholds(thresholds);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Threshold berhasil disimpan")),
    );
  }

  // Build TextField untuk threshold setting
  Widget buildThresholdField(String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: key.toUpperCase(),
          border: const OutlineInputBorder(),
        ),
        controller: TextEditingController(
          text: thresholds[key]?.toString() ?? '',
        ),
        onChanged: (val) {
          double? parsed = double.tryParse(val);
          if (parsed != null) thresholds[key] = parsed;
        },
      ),
    );
  }

  // Build chart per sensor (line chart)
  Widget buildChart(String sensor, Map<String, double> data) {
    List<FlSpot> spots = [];
    List<String> keys = data.keys.toList()..sort();
    for (int i = 0; i < keys.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[keys[i]]!));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              dotData: FlDotData(show: true),
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // Build tabel
  Widget buildTable() {
    List<String> sensors = ['ph', 'tds_ppm', 'ec_ms_cm', 'temp_c'];
    List<TableRow> rows = [
      TableRow(
        children: sensors
            .map(
              (s) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  s.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
            .toList(),
      ),
    ];

    // Ambil max length
    int maxLength = historyData.values
        .map((e) => e.length)
        .fold(0, (p, c) => c > p ? c : p);
    List<String> timestamps = [];
    for (int i = 0; i < maxLength; i++) {
      timestamps.add(i.toString());
    }

    for (int i = 0; i < maxLength; i++) {
      rows.add(
        TableRow(
          children: sensors.map((s) {
            final vals = historyData[s]?.values.toList() ?? [];
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text(vals.length > i ? vals[i].toString() : "-"),
            );
          }).toList(),
        ),
      );
    }

    return Table(border: TableBorder.all(), children: rows);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History Smart Farm")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Setting Threshold",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                buildThresholdField('ph'),
                buildThresholdField('tds_ppm'),
                buildThresholdField('ec_ms_cm'),
                buildThresholdField('temp_c'),
                ElevatedButton(
                  onPressed: _saveThresholds,
                  child: const Text("Simpan Threshold"),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Trend Chart",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...historyData.entries.map(
                  (e) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.key.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      buildChart(e.key, e.value),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Data Table",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                buildTable(),
              ],
            ),
    );
  }
}
