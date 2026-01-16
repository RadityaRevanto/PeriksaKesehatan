# 🏥 Periksa Kesehatan

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-Private-red)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey)

**Aplikasi Mobile untuk Monitoring Kesehatan Lansia**

Aplikasi kesehatan yang memungkinkan pengguna untuk memantau dan mencatat data kesehatan seperti tekanan darah, gula darah, berat badan, dan aktivitas harian dengan fitur offline-first dan sinkronisasi otomatis.

</div>

---

## 📋 Deskripsi Aplikasi

**Periksa Kesehatan** adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk membantu lansia dan keluarga mereka dalam memantau kondisi kesehatan secara berkala. Aplikasi ini menyediakan:

- ✅ **Pencatatan Data Kesehatan** - Tekanan darah, gula darah, berat badan, dan aktivitas
- ✅ **Offline-First Architecture** - Bekerja tanpa koneksi internet dengan sinkronisasi otomatis
- ✅ **Riwayat & Statistik** - Visualisasi data kesehatan dalam bentuk grafik dan tren
- ✅ **Peringatan Kesehatan** - Notifikasi otomatis untuk nilai kesehatan yang abnormal
- ✅ **Edukasi Kesehatan** - Video dan artikel edukatif tentang kesehatan
- ✅ **Export PDF** - Unduh riwayat kesehatan dalam format PDF
- ✅ **UI/UX Ramah Lansia** - Desain dengan font besar dan kontras tinggi

---

## 🚀 Tech Stack

### **Frontend (Mobile)**
- **Framework**: Flutter 3.9.2
- **Language**: Dart 3.9.2
- **State Management**: BLoC (flutter_bloc 8.1.6)
- **Dependency Injection**: GetIt + Injectable
- **Local Database**: SQLite (sqflite 2.4.2)
- **HTTP Client**: Dio 5.7.0
- **Local Storage**: SharedPreferences 2.3.2

### **Key Dependencies**
```yaml
# UI & Design
google_fonts: ^6.1.0              # Custom fonts
shimmer: ^3.0.0                   # Loading animations
phosphor_flutter: ^2.1.0          # Icon library

# State Management & Architecture
flutter_bloc: ^8.1.6              # BLoC pattern
equatable: ^2.0.5                 # Value equality
get_it: ^8.0.2                    # Service locator
injectable: ^2.4.4                # DI code generation
dartz: ^0.10.1                    # Functional programming

# Networking & Storage
dio: ^5.7.0                       # HTTP client
sqflite: ^2.4.2                   # Local database
shared_preferences: ^2.3.2        # Key-value storage
connectivity_plus: ^6.1.5         # Network status
internet_connection_checker: ^3.0.1

# Features
pdf: ^3.11.1                      # PDF generation
printing: ^5.13.3                 # PDF export
video_player: ^2.9.1              # Video playback
chewie: ^1.8.3                    # Video player UI
youtube_player_flutter: ^9.1.3    # YouTube integration
image_picker: ^1.0.7              # Camera & gallery
permission_handler: ^11.3.1       # Runtime permissions
url_launcher: ^6.3.1              # External links
share_plus: ^10.1.2               # Share functionality
intl: ^0.20.2                     # Internationalization
```

### **Backend**
- **Server**: PHP (Custom REST API)
- **Database**: MySQL
- **Base URL**: `http://192.168.1.19:8080/api`

### **Architecture Pattern**
- **Clean Architecture** - Separation of concerns (Data, Domain, Presentation)
- **Repository Pattern** - Abstraction layer for data sources
- **BLoC Pattern** - Reactive state management
- **Offline-First** - Local database with background sync

---

## 📦 Instalasi dan Setup

### **Prerequisites**

Pastikan Anda telah menginstal:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.9.2 atau lebih baru)
- [Dart SDK](https://dart.dev/get-dart) (versi 3.9.2 atau lebih baru)
- [Android Studio](https://developer.android.com/studio) atau [Xcode](https://developer.apple.com/xcode/) (untuk iOS)
- [Git](https://git-scm.com/)

### **Langkah Instalasi**

1. **Clone Repository**
   ```bash
   git clone https://github.com/RadityaRevanto/PeriksaKesehatan.git
   cd periksa_kesehatan
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Code (Dependency Injection & JSON Serialization)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Konfigurasi Backend URL**
   
   Edit file `lib/core/network/api_endpoints.dart`:
   ```dart
   class ApiEndpoints {
     static const String baseUrl = 'http://YOUR_IP_ADDRESS:8080/api';
     // Ganti YOUR_IP_ADDRESS dengan IP server backend Anda
   }
   ```

5. **Setup Backend Server**
   
   Pastikan backend PHP server sudah berjalan di `http://YOUR_IP:8080`
   - Database MySQL sudah dikonfigurasi
   - Endpoint API sudah tersedia

6. **Permissions Setup**

   **iOS** - Edit `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Aplikasi memerlukan akses kamera untuk mengubah foto profil</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>Aplikasi memerlukan akses galeri untuk memilih foto profil</string>
   ```

   **Android** - Sudah dikonfigurasi di `android/app/src/main/AndroidManifest.xml`

---

## 🏃‍♂️ Cara Menjalankan Aplikasi

### **Development Mode**

1. **Jalankan di Emulator/Simulator**
   ```bash
   # iOS Simulator
   open -a Simulator
   flutter run
   
   # Android Emulator (pastikan sudah running)
   flutter run
   ```

2. **Jalankan di Physical Device**
   ```bash
   # Hubungkan device via USB dan enable USB debugging
   flutter devices  # Cek device yang terhubung
   flutter run
   ```

3. **Hot Reload**
   - Tekan `r` di terminal untuk hot reload
   - Tekan `R` untuk hot restart
   - Tekan `q` untuk quit

### **Production Build**

**Android (APK)**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android (App Bundle)**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS**
```bash
flutter build ios --release
# Buka Xcode untuk archive dan distribute
```

### **Debug & Testing**

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Check for outdated packages
flutter pub outdated

# Clean build
flutter clean
flutter pub get
```

---

## 📡 Dokumentasi API

### **Base URL**
```
http://192.168.1.19:8080/api
```

### **Authentication**
Semua endpoint (kecuali login & register) memerlukan token autentikasi:
```
Authorization: Bearer {token}
```

### **Endpoints**

#### **1. Authentication**

**Login**
```http
POST /login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "user@example.com"
  }
}
```

**Register**
```http
POST /register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "user@example.com",
  "password": "password123",
  "phone": "081234567890"
}
```

**Logout**
```http
POST /logout
Authorization: Bearer {token}
```

#### **2. User Profile**

**Get Profile**
```http
GET /profile
Authorization: Bearer {token}

Response:
{
  "id": 1,
  "name": "John Doe",
  "email": "user@example.com",
  "phone": "081234567890",
  "photo_url": "uploads/profile_123.jpg",
  "created_at": "2026-01-15T10:30:00Z"
}
```

**Update Profile**
```http
POST /update-profile
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "name": "John Doe",
  "email": "user@example.com",
  "phone": "081234567890",
  "photo": <file>  // Optional
}
```

#### **3. Health Data**

**Save Health Data**
```http
POST /save-health-data
Authorization: Bearer {token}
Content-Type: application/json

{
  "systolic": 120,
  "diastolic": 80,
  "blood_sugar": 100,
  "weight": 70.5,
  "height": 170,
  "activity": "Ringan",
  "record_date": "2026-01-17"
}

Response:
{
  "success": true,
  "message": "Data kesehatan berhasil disimpan",
  "data": {
    "id": 123,
    "user_id": 1,
    "systolic": 120,
    "diastolic": 80,
    "blood_sugar": 100,
    "weight": 70.5,
    "height": 170,
    "activity": "Ringan",
    "record_date": "2026-01-17",
    "created_at": "2026-01-17T04:30:00Z"
  }
}
```

**Get Health Data**
```http
GET /get-health-data?date=2026-01-17
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "systolic": 120,
    "diastolic": 80,
    "blood_sugar": 100,
    "weight": 70.5,
    "height": 170,
    "activity": "Ringan",
    "record_date": "2026-01-17"
  }
}
```

**Get Health History**
```http
GET /get-health-history?start_date=2026-01-01&end_date=2026-01-31
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": [
    {
      "date": "2026-01-17",
      "systolic": 120,
      "diastolic": 80,
      "blood_sugar": 100,
      "weight": 70.5,
      "activity": "Ringan"
    },
    // ... more records
  ]
}
```

#### **4. Health Alerts**

**Check Health Alerts**
```http
GET /check-health-alerts
Authorization: Bearer {token}

Response:
{
  "success": true,
  "alerts": [
    {
      "id": 1,
      "type": "blood_pressure",
      "severity": "warning",
      "title": "Tekanan Darah Tinggi",
      "explanation": "Tekanan darah Anda 140/90 mmHg, lebih tinggi dari normal",
      "recommendation": "Kurangi konsumsi garam dan olahraga teratur",
      "created_at": "2026-01-17T04:30:00Z"
    }
  ]
}
```

#### **5. Education**

**Get Education Videos**
```http
GET /education-videos
Authorization: Bearer {token}

Response:
{
  "success": true,
  "videos": [
    {
      "id": 1,
      "title": "Cara Mengukur Tekanan Darah",
      "description": "Tutorial lengkap mengukur tekanan darah",
      "video_url": "https://youtube.com/watch?v=...",
      "thumbnail": "uploads/thumb_1.jpg",
      "category": "tutorial",
      "duration": "5:30"
    }
  ]
}
```

**Get Videos by Category**
```http
GET /education-videos/category/{categoryId}
Authorization: Bearer {token}
```

#### **6. PDF Export**

**Download Health History PDF**
```http
GET /download-health-history-pdf?start_date=2026-01-01&end_date=2026-01-31
Authorization: Bearer {token}

Response: PDF File (application/pdf)
```

---

## 🏗️ Struktur Project

```
lib/
├── core/                          # Core utilities & configurations
│   ├── cache/                     # Cache management
│   ├── constants/                 # App constants & colors
│   ├── database/                  # SQLite database helper
│   ├── di/                        # Dependency injection setup
│   ├── network/                   # API client & endpoints
│   ├── storage/                   # Local storage utilities
│   └── utils/                     # Helper functions
│
├── data/                          # Data layer
│   ├── datasources/
│   │   ├── local/                 # Local database datasources
│   │   └── remote/                # API datasources
│   ├── models/                    # Data models (JSON serializable)
│   └── repositories/              # Repository implementations
│
├── domain/                        # Domain layer
│   ├── entities/                  # Business entities
│   ├── repositories/              # Repository interfaces
│   └── usecases/                  # Business logic
│
├── presentation/                  # Presentation layer
│   ├── bloc/                      # BLoC state management
│   └── widgets/                   # Reusable widgets
│
├── pages/                         # UI screens
│   ├── auth/                      # Login, Register
│   ├── home/                      # Homepage
│   ├── riwayat/                   # Health history
│   ├── edukasi/                   # Education videos
│   ├── peringatan/                # Health alerts
│   ├── profil/                    # User profile
│   ├── input/                     # Data input forms
│   ├── legal/                     # Privacy policy, T&C
│   └── debug/                     # Debug tools
│
├── services/                      # Background services
│   ├── health_sync_service.dart   # Data synchronization
│   ├── pdf_export_service.dart    # PDF generation
│   └── remember_me_service.dart   # Remember me functionality
│
├── widgets/                       # Shared widgets
│   ├── cards/                     # Card components
│   ├── calendar/                  # Calendar picker
│   └── ...
│
└── main.dart                      # App entry point
```

---

## 🎨 Features

### **1. Offline-First Architecture**
- ✅ Data tersimpan lokal di SQLite
- ✅ Sinkronisasi otomatis saat online
- ✅ Queue system untuk pending sync
- ✅ Conflict resolution

### **2. Health Monitoring**
- ✅ Tekanan darah (Systolic/Diastolic)
- ✅ Gula darah (mg/dL)
- ✅ Berat badan & BMI
- ✅ Aktivitas harian
- ✅ Status kesehatan real-time

### **3. Data Visualization**
- ✅ Grafik tren kesehatan
- ✅ Statistik ringkasan
- ✅ Calendar view
- ✅ Color-coded status

### **4. Smart Alerts**
- ✅ Deteksi otomatis nilai abnormal
- ✅ Rekomendasi kesehatan
- ✅ Severity levels (Low, Medium, High)
- ✅ Historical alerts

### **5. Education Center**
- ✅ Video tutorial kesehatan
- ✅ YouTube integration
- ✅ Kategori konten
- ✅ Offline video support

### **6. Export & Share**
- ✅ PDF export riwayat kesehatan
- ✅ Share via WhatsApp, Email, dll
- ✅ Custom date range
- ✅ Professional formatting

---

## 🔐 Security & Privacy

- ✅ **Token-based Authentication** - JWT tokens untuk API security
- ✅ **Local Data Encryption** - Sensitive data encrypted di SQLite
- ✅ **Secure Storage** - SharedPreferences untuk credentials
- ✅ **HTTPS Ready** - Support untuk SSL/TLS
- ✅ **Privacy Policy** - Built-in privacy policy page
- ✅ **Terms & Conditions** - User agreement

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

---

## 📝 Code Quality & Best Practices

### **Clean Code Principles**
- ✅ **SOLID Principles** - Single responsibility, Open/closed, etc.
- ✅ **DRY (Don't Repeat Yourself)** - Reusable components
- ✅ **KISS (Keep It Simple, Stupid)** - Simple, readable code
- ✅ **Separation of Concerns** - Clean architecture layers

### **Flutter Best Practices**
- ✅ **BLoC Pattern** - Predictable state management
- ✅ **Dependency Injection** - Loose coupling
- ✅ **Repository Pattern** - Data abstraction
- ✅ **Error Handling** - Try-catch with proper error messages
- ✅ **Null Safety** - Sound null safety enabled
- ✅ **Code Generation** - Injectable, JSON serialization

### **Git Workflow**
```bash
# Feature branch workflow
git checkout -b feature/new-feature
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature

# Commit message convention
feat: New feature
fix: Bug fix
docs: Documentation
style: Code formatting
refactor: Code refactoring
test: Testing
chore: Maintenance
```

### **Commit History**
```
✅ feat: [RD] Offline-First - Implementasi offline-first architecture
✅ feat: [RD] Health Sync Service - Background sync service
✅ feat: [RD] PDF Export - Export health history to PDF
✅ feat: [RD] Remember Me - Auto-login functionality
✅ fix: [RD] Profile Image 404 - Fixed image loading error
✅ fix: [RD] Health Data Date Display - Fixed timezone issues
✅ refactor: [RD] Shimmer Loading - Modern loading animations
✅ style: [RD] Optimize Mobile UI - Better spacing for mobile
```

---

## 🐛 Known Issues & Troubleshooting

### **Issue: Hot reload tidak bekerja**
```bash
# Solution: Hot restart
flutter clean
flutter pub get
flutter run
```

### **Issue: Build error setelah update dependencies**
```bash
# Solution: Regenerate code
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### **Issue: Tidak bisa connect ke backend**
```bash
# Solution: Cek IP address dan pastikan backend running
# Edit lib/core/network/api_endpoints.dart
# Gunakan IP address yang benar (bukan localhost untuk physical device)
```

### **Issue: Permission denied (iOS)**
```bash
# Solution: Cek Info.plist dan rebuild
# Pastikan NSCameraUsageDescription dan NSPhotoLibraryUsageDescription ada
flutter clean
flutter build ios
```

---

## 📱 Screenshots

> **Note**: Tambahkan screenshots aplikasi di folder `screenshots/` dan update section ini

---

## 🤝 Contributing

Untuk kontribusi:
1. Fork repository
2. Buat feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

---

## 📄 License

Project ini bersifat **private** dan tidak untuk dipublikasikan.

---

## 👥 Team

**Developer**: Raditya Revanto  
**Repository**: [RadityaRevanto/PeriksaKesehatan](https://github.com/RadityaRevanto/PeriksaKesehatan)

---

## 📞 Support

Untuk pertanyaan atau bantuan:
- **Email**: support@periksakesehatan.com
- **GitHub Issues**: [Create an issue](https://github.com/RadityaRevanto/PeriksaKesehatan/issues)

---

<div align="center">

**Made with ❤️ using Flutter**

</div>
