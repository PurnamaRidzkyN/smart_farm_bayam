import '../helper/manager.dart';
import '../models/information_model.dart';

class InformationController {
  final FirebaseRefs refs;
  InformationController(this.refs);

  // Stream untuk menampilkan informasi
  Stream<List<InformationModel>> getInformationStream() {
    return refs.informationRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return data.entries.map((e) => InformationModel.fromMap(e.value, e.key)).toList();
    });
  }

  // Tambah informasi
  Future<void> addInformation(String title, String content) async {
    final newRef = refs.informationRef.push();
    await newRef.set({'title': title, 'content': content});
  }

  // Hapus informasi (tapi cek jika index > 4)
  Future<void> removeInformation(String id, int index) async {
    if (index < 5) return; // 5 pertama tidak bisa dihapus
    await refs.informationRef.child(id).remove();
  }
  
  Future<void> createInitialInfos() async {
  final snapshot = await refs.informationRef.get();
  if (!snapshot.exists) {
    final initialInfos = [
      {'title': 'Selamat Datang', 'content': 'Informasi awal aplikasi'},
      {'title': 'Tips Tanaman', 'content': 'Perawatan tanaman bayam'},
      {'title': 'Alarm Sensor', 'content': 'Notifikasi sensor penting'},
      {'title': 'Kontrol Pompa', 'content': 'Cara mengontrol pompa'},
      {'title': 'Lampu & Nutrisi', 'content': 'Pengaturan lampu dan nutrisi'},
    ];

    for (var info in initialInfos) {
      await refs.informationRef.push().set(info);
    }
  }
}

}