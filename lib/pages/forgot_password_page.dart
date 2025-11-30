import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  // Fungsi utilitas untuk menampilkan SnackBar
  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void reset() async {
    final emailAddress = emailController.text.trim();

    // 1. Validasi Input Kosong
    if (emailAddress.isEmpty) {
      _showSnackbar(context, 'Email tidak boleh kosong.', Colors.red);
      return;
    }

    try {
      await auth.sendPasswordResetEmail(email: emailAddress);

      // 2. Notifikasi Berhasil (Sukses)
      _showSnackbar(
        context,
        'Tautan reset password telah dikirim ke $emailAddress. Silakan cek email Anda!',
        Colors.green,
      );
      
      // Opsional: Kosongkan field setelah berhasil
      emailController.clear(); 

    } on FirebaseAuthException catch (e) {
      // 3. Penanganan Error Spesifik Firebase
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
          errorMessage = 'Email tidak ditemukan atau tidak valid. Pastikan Anda memasukkan email yang terdaftar.';
          break;
        default:
          errorMessage = 'Gagal mengirim email reset: ${e.message}';
      }

      _showSnackbar(context, errorMessage, Colors.red);
    } catch (e) {
      // 4. Penanganan Error Umum
      _showSnackbar(context, 'Terjadi kesalahan: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FFF4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Reset Password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Mengganti nama controller agar konsisten
              TextField(
                controller: emailController, 
                keyboardType: TextInputType.emailAddress, // Tambahkan ini untuk keyboard yang sesuai
                decoration: InputDecoration(
                  hintText: "Masukkan email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: reset,
                  child: const Text(
                    "Kirim Email",
                    style: TextStyle(color: Colors.white),
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