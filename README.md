# 🥬 Greenflow
Greenflow adalah solusi manajemen smart farming berbasis IoT yang dirancang khusus untuk otomasi dan optimalisasi budidaya bayam hidroponik. Aplikasi ini menghubungkan petani dengan kebun mereka melalui data real-time, memastikan hasil panen yang maksimal dengan intervensi manual minimal.

# 🚀 Fitur Utama
1. **Fitur Sensor (Wokwi)**

    Fitur Sensor berfungsi untuk melakukan pembacaan data dari sensor yang disimulasikan menggunakan platform Wokwi. Nilai sensor diperoleh melalui data acak (random) atau melalui pengaturan slider yang merepresentasikan kondisi lingkungan secara real-time. Data yang telah dibaca kemudian dikirimkan ke Firebase sebagai basis data utama agar dapat diakses oleh Fitur lain, seperti Fitur kontrol, history, dan alert.
    Fitur Kontrol (App & Wokwi)
    Fitur Kontrol bertugas mengatur proses pengendalian perangkat berdasarkan mode yang dipilih, yaitu mode AUTO dan MANUAL.
    Jika Mode = AUTO: Wokwi membaca sensor -> Putuskan nyala/mati -> Update Firebase.
    Jika Mode = MANUAL: App kirim status ON/OFF -> Firebase -> Wokwi baca dan eksekusi.

2. **Fitur History** 

    Fitur History berfungsi untuk menyimpan riwayat data sensor yang diterima dari setiap sensor secara berkala. Data historis ini digunakan untuk memantau perubahan kondisi lingkungan dari waktu ke waktu serta menjadi bahan evaluasi dan analisis kinerja sistem. Riwayat data juga dapat dimanfaatkan untuk pengambilan keputusan di masa mendatang.

3. **Fitur information**

    Fitur Information digunakan untuk menyimpan dan menampilkan berbagai informasi yang berkaitan dengan tanaman atau kebutuhan pengguna. Informasi yang disediakan dapat berupa panduan perawatan tanaman, deskripsi sensor, maupun informasi pendukung lainnya. Fitur ini membantu pengguna dalam memahami kondisi tanaman dan cara pengelolaannya secara lebih optimal. 

4. **Fitur alert**

    Fitur Alert berfungsi untuk memberikan peringatan kepada pengguna apabila nilai sensor melewati batas minimum atau maksimum yang telah ditentukan. Peringatan ini dapat berupa notifikasi pada aplikasi sehingga pengguna dapat segera mengambil tindakan yang diperlukan. Fitur ini berperan penting dalam mencegah kondisi yang dapat merusak tanaman atau sistem.

5. **Fitur  configurasi**

    Fitur Konfigurasi digunakan untuk menyimpan dan mengelola pengaturan sistem, termasuk batas minimum dan maksimum dari setiap sensor serta perubahan mode kontrol (AUTO atau MANUAL). Pengaturan yang disimpan pada Fitur ini akan menjadi acuan bagi Fitur kontrol dan Fitur alert dalam menjalankan fungsinya. Dengan adanya Fitur konfigurasi, sistem menjadi lebih fleksibel dan dapat disesuaikan dengan kebutuhan pengguna.

# 📦 Instalasi (Flutter)

1. **Clone Repository**
   ```bash
   $ git clone https://github.com/PurnamaRidzkyN/smart_farm_bayam.git

2. **Siapkan Firebase Anda**

3. **Masukkan google service json dari firebase ke Android / App**

<!-- 4. **Buka VS Code** -->

4. **Instalasi Dependency (Frontend)**
    ```bash
    $ flutter pub get

5. **Jalankan Flutter**
    ```bash
    $ flutter run


# 📦 Instalasi (IOT)

1. **Clone Repository**
   ```bash
   $ git clone https://github.com/aqilrahmat3/smartfarmbayam.git
   $ cd smartfarmbayam
    ````

2. **Buat File Konfigurasi (`env.h`)**

   Setelah repository di-clone, **WAJIB** membuat file konfigurasi Firebase.

   * Masuk ke folder:

     ```
     src/
     ```

   * Salin file contoh:

     ```bash
     cp env_example.h env.h
     ```

   * Isi file `env.h` sesuai konfigurasi Firebase:

     ```cpp
     #define FIREBASE_HOST "your-project-id.firebaseio.com"
     #define FIREBASE_EMAIL "your-email@gmail.com"
     #define FIREBASE_PASSWORD "your-password"
     #define FIREBASE_API_KEY "your-api-key"
     ```

   > **Catatan:**
   > File `env.h` berisi data sensitif dan tidak boleh diunggah ke repository publik.

3. **Pastikan Extension VS Code Terpasang**

   Proyek IoT ini dijalankan menggunakan **Visual Studio Code**, dengan extension berikut:

   * **PlatformIO**
   * **Wokwi**

   Tanpa kedua extension tersebut, simulasi tidak dapat dijalankan.

4. **Build proyek menggunakan PlatformIO (satu kali) sebelum menjalankan diagram.json**

5. **Jalankan Simulasi Wokwi**

   * Buka proyek menggunakan **Visual Studio Code**
   * Buka file:

     ```
     diagram.json
     ```
# 📦 Cara Membuat APK Agar Dapat Dibagikan (Release)

Bagian ini menjelaskan langkah singkat untuk menghasilkan **APK release** dari aplikasi Greenflow agar dapat dibagikan dan diinstal pada perangkat Android lain.

1. **Pastikan Konfigurasi Sudah Siap**
   - Dependency Flutter sudah terinstal
   - Firebase sudah terhubung
   - File `google-services.json` sudah berada di folder:
     ```
     android/app/
     ```

2. **Build APK Release**
   Jalankan perintah berikut pada root project Flutter:
   ```bash
   flutter build apk --release
    ````

3. **Hasil APK**
   Setelah proses build selesai, file APK akan tersimpan di:

   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

4. **Distribusi APK**
   File `app-release.apk` dapat dibagikan dan diinstal secara manual pada perangkat Android dengan mengaktifkan izin **Install from unknown sources**.

> **Catatan:**
> APK release digunakan untuk distribusi aplikasi. Untuk keperluan pengembangan dan debugging, gunakan `flutter run`.


## Penutup
Aplikasi **Greenflow** dikembangkan oleh **Kelompok 2 – Sayuran Hidroponik** sebagai proyek smart farming berbasis IoT. Proyek ini dibuat untuk mengintegrasikan simulasi sensor, sistem kontrol otomatis dan manual, serta aplikasi mobile dalam satu sistem pemantauan dan pengelolaan budidaya bayam hidroponik.

