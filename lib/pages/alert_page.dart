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
    String status = value < 0 ? "terlalu rendah" : "terlalu tinggi"; // contoh logika

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
        return "$type dalam kondisi tidak normal (nilai: $value)";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FFF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Alerts / Pemberitahuan',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AlertModel>>(
        stream: controller.getAlerts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final alerts = snapshot.data!;
          if (alerts.isEmpty) return const Center(child: Text("Tidak ada alert"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(formatAlertMessage(alert.type, alert.value)),
                  subtitle: Text(
                    "Mulai: ${formatTime(alert.startMs)}\nSelesai: ${formatTime(alert.endMs)}",
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
    );
  }
}
