# 🥬 Greenflow
Greenflow adalah solusi manajemen smart farming berbasis IoT yang dirancang khusus untuk otomasi dan optimalisasi budidaya bayam hidroponik. Aplikasi ini menghubungkan petani dengan kebun mereka melalui data real-time, memastikan hasil panen yang maksimal dengan intervensi manual minimal.

# 🚀 Fitur Utama
1. **Fitur Sensor (Wokwi)**

    Modul Sensor berfungsi untuk melakukan pembacaan data dari sensor yang disimulasikan menggunakan platform Wokwi. Nilai sensor diperoleh melalui data acak (random) atau melalui pengaturan slider yang merepresentasikan kondisi lingkungan secara real-time. Data yang telah dibaca kemudian dikirimkan ke Firebase sebagai basis data utama agar dapat diakses oleh modul lain, seperti modul kontrol, history, dan alert.
    Modul Kontrol (App & Wokwi)
    Modul Kontrol bertugas mengatur proses pengendalian perangkat berdasarkan mode yang dipilih, yaitu mode AUTO dan MANUAL.
    Jika Mode = AUTO: Wokwi membaca sensor -> Putuskan nyala/mati -> Update Firebase.
    Jika Mode = MANUAL: App kirim status ON/OFF -> Firebase -> Wokwi baca dan eksekusi.

2. **Fitur History** 

    Modul History berfungsi untuk menyimpan riwayat data sensor yang diterima dari setiap sensor secara berkala. Data historis ini digunakan untuk memantau perubahan kondisi lingkungan dari waktu ke waktu serta menjadi bahan evaluasi dan analisis kinerja sistem. Riwayat data juga dapat dimanfaatkan untuk pengambilan keputusan di masa mendatang.
    Modul information 

3. **Modul information**

    Modul Information digunakan untuk menyimpan dan menampilkan berbagai informasi yang berkaitan dengan tanaman atau kebutuhan pengguna. Informasi yang disediakan dapat berupa panduan perawatan tanaman, deskripsi sensor, maupun informasi pendukung lainnya. Modul ini membantu pengguna dalam memahami kondisi tanaman dan cara pengelolaannya secara lebih optimal. 

4. **Modul alert**

    Modul Alert berfungsi untuk memberikan peringatan kepada pengguna apabila nilai sensor melewati batas minimum atau maksimum yang telah ditentukan. Peringatan ini dapat berupa notifikasi pada aplikasi sehingga pengguna dapat segera mengambil tindakan yang diperlukan. Modul ini berperan penting dalam mencegah kondisi yang dapat merusak tanaman atau sistem.

5. **Modul  configurasi**

    Modul Konfigurasi digunakan untuk menyimpan dan mengelola pengaturan sistem, termasuk batas minimum dan maksimum dari setiap sensor serta perubahan mode kontrol (AUTO atau MANUAL). Pengaturan yang disimpan pada modul ini akan menjadi acuan bagi modul kontrol dan modul alert dalam menjalankan fungsinya. Dengan adanya modul konfigurasi, sistem menjadi lebih fleksibel dan dapat disesuaikan dengan kebutuhan pengguna.

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

2. **Bikin .env**