# 🏥 OctaKlinik

**OctaKlinik** adalah aplikasi mobile berbasis Flutter untuk pencatatan medis pasien pada klinik atau layanan kesehatan skala kecil-menengah. Proyek ini dikembangkan bertujuan untuk mempermudah proses pencatatan, pelacakan, dan pengelolaan data pasien secara digital.

---

![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white) ![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white) ![Gradle](https://img.shields.io/badge/Gradle-02303A?logo=gradle&logoColor=white)

## 🚀 Fitur Utama

### 🔐 Autentikasi
- Integrasi Firebase Authentication
- Login dan logout user untuk menjaga keamanan akses aplikasi
- Tampilan estetis dengan mode dark yang bisa di switch ke mode light

### 📝 Formulir Pasien
- Tambah data pasien baru dengan detail:
  - Nama
  - Tanggal Lahir
  - Jenis Kelamin
  - Nomor HP
  - Alamat
  - Riwayat Medis

### 🔍 Pencarian Data Pasien
- Search bar untuk mencari pasien berdasarkan **nama** atau **ID**
- Memudahkan pencarian data dalam jumlah besar

### 📅 Pencatatan Kunjungan (Visit)
- Formulir khusus untuk mencatat setiap kunjungan pasien
- Kolom keluhan dan keterangan medis yang fleksibel

### ⏱️ Filter Berdasarkan Waktu
- Filter data berdasarkan:
  - Hari ini
  - Minggu ini
  - Bulan ini
  - Semua waktu
- Sistem otomatis me-reset filter jika sudah melewati batas waktunya

### 🛠️ CRUD Data
- Tambah, edit, dan hapus data **pasien**
- Tambah, edit, dan hapus data **kunjungan/visit**

---

## 📸 Cuplikan Tampilan
https://github.com/fakhriiazhar/Octaklinik/tree/main/assets/screenshots

## ⚙️ Teknologi yang Digunakan

- **Flutter** (Frontend Framework)
- **Firebase Authentication** (User Login)
- **Sqlite** (Database)
- **Provider** (State Management)
- **Custom UI with Material Design**

---

## 🚧 Instalasi & Menjalankan Aplikasi

```bash
flutter pub get
flutter run
```

## ⚠️ File google-services.json tidak disertakan dalam repositori ini karena alasan keamanan. 
  Silakan tambahkan file tersebut ke direktori android/app/ untuk menjalankan Firebase di perangkat lokal Anda.

## 📄 Lisensi
Proyek ini bersifat open-source dan bebas digunakan untuk keperluan pembelajaran atau pengembangan lebih lanjut. Silakan fork dan kembangkan sesuai kebutuhan Anda.
