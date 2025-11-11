import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late DatabaseReference settingRef;
  final TextEditingController phMinController = TextEditingController();
  final TextEditingController phMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    settingRef = FirebaseService.getSettingRef();

    // ambil setting yang sudah ada
    settingRef.get().then((snapshot) {
      if (snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        phMinController.text = data['ph_min']?.toString() ?? '';
        phMaxController.text = data['ph_max']?.toString() ?? '';
        setState(() {});
      }
    });
  }

  void saveSettings() {
    final phMin = double.tryParse(phMinController.text);
    final phMax = double.tryParse(phMaxController.text);
    if (phMin != null && phMax != null) {
      settingRef.set({
        'ph_min': phMin,
        'ph_max': phMax,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setting tersimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setting Smart Farm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phMinController,
              decoration: const InputDecoration(labelText: 'pH Minimal'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: phMaxController,
              decoration: const InputDecoration(labelText: 'pH Maksimal'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveSettings,
              child: const Text('Simpan Setting'),
            ),
          ],
        ),
      ),
    );
  }
}
