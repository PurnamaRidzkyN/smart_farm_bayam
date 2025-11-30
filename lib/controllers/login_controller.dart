import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;

  // Fungsi utilitas untuk menampilkan SnackBar
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 1. Validasi Input Kosong
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar(context, 'Email dan password tidak boleh kosong.');
      return; // Menghentikan eksekusi jika ada input kosong
    }

    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Jika berhasil
      Navigator.pushReplacementNamed(context, '/dashboard');
      
    } on FirebaseAuthException catch (e) {
      // 2. Penanganan Error Spesifik dari Firebase
      String errorMessage;

      switch (e.code) {
        case 'invalid-credential': 
          // Pesan yang lebih umum untuk mencakup user-not-found atau wrong-password
          errorMessage = 'Email atau Password yang Anda masukkan salah.';
          break;
        default:
          // Menangkap error lain yang tidak terkait kredensial (misalnya, masalah koneksi)
          errorMessage = 'Terjadi kesalahan login: ${e.message}';
          break;
      }

      _showErrorSnackbar(context, errorMessage);
      
    } catch (e) {
      // 3. Penanganan Error Lain (misalnya koneksi, dll.)
      _showErrorSnackbar(context, 'Terjadi kesalahan umum: $e');
    }
  }
}