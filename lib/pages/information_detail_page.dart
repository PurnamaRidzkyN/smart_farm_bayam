import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../controllers/information_controller.dart';
import '../models/information_model.dart';
import '../app_globals.dart';

class InformationDetailPage extends StatelessWidget {
  final InformationModel info;
  final int index;

  const InformationDetailPage({
    super.key,
    required this.info,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = InformationController(AppGlobals.refs);

    return Scaffold(
      backgroundColor: const Color(0xFFE0FFF2),

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
                      Text(
                        info.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔥 Full Markdown rendering
                      Expanded(
                        child: Markdown(
                          data: info.content,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 16, height: 1.4),
                            h1: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                            h2: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            listBullet: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (index >= 5)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Judul
                                    const Text(
                                      "Konfirmasi",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Isi pesan
                                    const Text(
                                      "Apakah Anda yakin ingin menghapus informasi ini?",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        height: 1.3,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Tombol aksi
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Tombol Batal
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text(
                                            "Batal",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // Tombol Hapus
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                          ),
                                          child: const Text(
                                            "Hapus",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          if (confirmDelete == true) {
                            await controller.removeInformation(info.id, index);
                            Navigator.pop(context);
                          }
                        },

                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          "Hapus Informasi",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(46),
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
}
