import 'package:flutter/material.dart';
import 'package:smart_farm_bayam/pages/information_detail_page.dart';
import '../controllers/information_controller.dart';
import '../models/information_model.dart';
import '../app_globals.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final InformationController controller =
      InformationController(AppGlobals.refs);

  @override
  void initState() {
    super.initState();
    controller.createInitialInfos();
  }

  // Fungsi utilitas untuk memotong konten
  String _getSnippet(String content, {int maxLength = 100}) {
    // Menghilangkan baris baru/spasi berlebihan dan memotong
    final cleanedContent = content.replaceAll('\n', ' ').trim();
    if (cleanedContent.length > maxLength) {
      return cleanedContent.substring(0, maxLength).trim() + '...';
    }
    return cleanedContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0FFF2),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: const Color(0xFF009f7f),
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Information",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: StreamBuilder<List<InformationModel>>(
                          stream: controller.getInformationStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final infos = snapshot.data!;
                            return ListView.builder(
                              itemCount: infos.length,
                              itemBuilder: (context, index) {
                                final info = infos[index];
                                
                                // 🔥 Modifikasi di sini: Ambil cuplikan konten
                                final snippet = _getSnippet(info.content, maxLength: 150);

                                return Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    title: Text(info.title),

                                    // Mengganti MarkdownBody dengan Text jika Anda hanya perlu preview singkat tanpa parsing Markdown
                                    // Namun, karena konten Anda Markdown, kita bisa gunakan MarkdownBody dengan konten yang sudah dipotong.
                                    // Pilihan: Menggunakan Text biasa lebih efektif untuk cuplikan.
                                    subtitle: Text(
                                      snippet,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 3, // Batasi jumlah baris untuk Text widget
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    
                                    // Menggunakan MarkdownBody dengan konten yang sudah dipotong (Alternatif, tapi Text lebih disarankan untuk cuplikan)
                                    /* subtitle: MarkdownBody(
                                      data: snippet, // Gunakan snippet yang sudah dipotong
                                      softLineBreak: true,
                                      fitContent: false,
                                      styleSheet: MarkdownStyleSheet(
                                        p: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    */

                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => InformationDetailPage(
                                            info: info,
                                            index: index,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: const [
                            Icon(Icons.arrow_back, color: Color(0xFF009f7f)),
                            SizedBox(width: 6),
                            Text(
                              "Back",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF009f7f),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Informasi"),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration:
                    const InputDecoration(labelText: "Konten (Markdown)"),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.addInformation(
                titleController.text,
                contentController.text,
              );
              Navigator.pop(context);
            },
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }
}