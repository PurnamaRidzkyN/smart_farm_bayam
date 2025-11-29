import 'package:flutter/material.dart';
import '../controllers/alert_controller.dart';
import '../models/alert_model.dart';
import '../app_globals.dart';
import 'package:intl/intl.dart';

class AlertPage extends StatelessWidget {
  final AlertController controller = AlertController(AppGlobals.refs.alertRef);

  AlertPage({super.key});

  String formatTime(int ms) {
    if (ms == 0) return "-";
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('dd MMM yyyy • HH:mm').format(dt);
  }

  String formatAlertMessage(String type, double value) {
    String status = value < 0 ? "terlalu rendah" : "terlalu tinggi";

    switch (type.toLowerCase()) {
      case "ph":
        return "pH $status (nilai: $value)";
      case "temperature":
      case "temp":
        return "Temperatur $status (nilai: $value)";
      case "tds":
        return "TDS $status (nilai: $value)";
      case "ec":
        return "EC $status (nilai: $value)";
      default:
        return "$type tidak normal (nilai: $value)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FFF4), // sesuai gambar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18), // card utama seperti di gambar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Text(
                    "Alert",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Isi daftar alert
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: StreamBuilder<List<AlertModel>>(
                      stream: controller.getAlerts(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final alerts = snapshot.data!;
                        if (alerts.isEmpty) {
                          return const Center(child: Text("Tidak ada alert"));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];

                            return Card(
                              elevation: 1,
                              child: ListTile(
                                leading: const Icon(Icons.warning, color: Colors.red),
                                title: Text(formatAlertMessage(alert.type, alert.value)),
                                subtitle: Text(
                                  "Mulai: ${formatTime(alert.startMs)}\n"
                                  "Selesai: ${formatTime(alert.endMs)}",
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => controller.removeAlert(alert.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Tombol Back (di dalam card)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.teal),
                        SizedBox(width: 6),
                        Text(
                          "Back",
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}