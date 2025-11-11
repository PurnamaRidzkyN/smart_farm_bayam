import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';

class SensorDataPage extends StatefulWidget {
  const SensorDataPage({super.key});

  @override
  State<SensorDataPage> createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseService.getSensorDataRef();
  }

  Color getPhColor(double ph, double phMin, double phMax) {
    if (ph < phMin) return Colors.red.shade200;
    if (ph > phMax) return Colors.orange.shade200;
    return Colors.green.shade200;
  }

  @override
  Widget build(BuildContext context) {
    final settingRef = FirebaseService.getSettingRef();

    return Scaffold(
      appBar: AppBar(title: const Text('Data Sensor Smart Farm')),
      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final dataSnapshot = snapshot.data!.snapshot.value;
          final Map<String, Map<String, dynamic>> dataMap =
              (dataSnapshot as Map<dynamic, dynamic>).map(
            (key, value) => MapEntry(
              key.toString(),
              Map<String, dynamic>.from(value as Map),
            ),
          );

          return StreamBuilder(
            stream: settingRef.onValue,
            builder: (context, settingSnapshot) {
              double phMin = 5.5;
              double phMax = 7.5;

              if (settingSnapshot.hasData &&
                  settingSnapshot.data!.snapshot.value != null) {
                final s = Map<String, dynamic>.from(
                    settingSnapshot.data!.snapshot.value as Map);
                phMin = (s['ph_min'] as num).toDouble();
                phMax = (s['ph_max'] as num).toDouble();
              }

              final sortedKeys = dataMap.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return ListView.builder(
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final key = sortedKeys[index];
                  final sensor = dataMap[key]!;

                  final ph = (sensor['ph'] as num).toDouble();
                  final tds = (sensor['tds'] as num).toInt();
                  final ec = (sensor['ec'] as num).toDouble();
                  final temp = (sensor['temperature'] as num).toDouble();

                  return Card(
                    color: getPhColor(ph, phMin, phMax).withOpacity(0.3),
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        'pH: $ph, TDS: $tds ppm, EC: $ec mS/cm',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Suhu: $temp °C\nTimestamp: $key'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
