# SmartToolkit - Comprehensive Flutter Utility App

SmartToolkit là một ứng dụng Flutter đa năng với 15+ công cụ tiện ích thiết yếu, được xây dựng theo Clean Architecture với Material 3 design.

## 🚀 Tính năng chính

### 📱 15 công cụ tiện ích:
- **Calculator** - Máy tính cơ bản với giao diện đẹp
- **Notes** - Ghi chú với lưu trữ local
- **Password Generator** - Tạo mật khẩu an toàn
- **QR Generator** - Tạo mã QR từ text/URL
- **QR Scanner** - Quét mã QR và barcode
- **Tip Calculator** - Tính tip và chia bill
- **Unit Converter** - Chuyển đổi đơn vị (độ dài, trọng lượng)
- **Age Calculator** - Tính tuổi chi tiết
- **BMI Calculator** - Tính chỉ số BMI và phân loại
- **Stopwatch** - Đồng hồ bấm giờ
- **Countdown Timer** - Đếm ngược thời gian
- **Todo List** - Quản lý công việc
- **Flashlight** - Đèn pin sử dụng camera flash
- **Image to Text** - Trích xuất text từ hình ảnh (OCR)
- **Sound Meter** - Đo độ ồn môi trường

### 🎨 UI/UX Features:
- Material 3 Design System
- Dark/Light Theme support
- Responsive grid layout
- Search functionality
- Smooth animations
- Modern card-based interface

## 🏗️ Kiến trúc

### Clean Architecture Structure:
```
lib/
├── core/
│   ├── constants/          # App constants & tool data
│   ├── theme/             # Material 3 themes
│   ├── services/          # Storage & theme providers
│   └── navigation/        # App routing
├── features/              # Feature modules
│   ├── calculator/
│   ├── notes/
│   ├── password_generator/
│   ├── qr_generator/
│   ├── qr_scanner/
│   ├── tip_calculator/
│   ├── unit_converter/
│   ├── age_calculator/
│   ├── bmi_calculator/
│   ├── stopwatch/
│   ├── countdown_timer/
│   ├── todo_list/
│   ├── flashlight/
│   ├── image_to_text/
│   └── sound_meter/
└── main.dart
```

## 📦 Dependencies chính

```yaml
dependencies:
  provider: ^6.1.2          # State Management
  qr_flutter: ^4.1.0        # QR Generator
  mobile_scanner: ^5.2.3    # QR Scanner
  google_mlkit_text_recognition: ^0.14.0  # OCR
  image_picker: ^1.1.2      # Image handling
  shared_preferences: ^2.3.2 # Local Storage
  torch_light: ^1.0.0       # Flashlight
  vibration: ^2.0.0         # Vibration
  audio_streamer: ^4.0.1    # Audio
  permission_handler: ^11.3.1 # Permissions
```

## 🛠️ Cài đặt & Chạy

### Yêu cầu:
- Flutter SDK >= 3.10.0
- Android SDK (API 21+)

### Commands:
```bash
# Cài đặt dependencies
flutter pub get

# Chạy app
flutter run

# Build APK
flutter build apk --release

# Build AAB cho Play Store
flutter build appbundle --release
```

## 📱 Build Production

### Tạo Keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Build Commands:
```bash
# APK Release
flutter build apk --release

# AAB Release  
flutter build appbundle --release

# Với obfuscation
flutter build appbundle --obfuscate --split-debug-info=build/debug-info --release
```

## 🔐 Permissions Required

- `CAMERA` - QR Scanner, Image to Text
- `FLASHLIGHT` - Flashlight feature
- `RECORD_AUDIO` - Sound Meter
- `WRITE_EXTERNAL_STORAGE` - Notes storage
- `INTERNET` - Optional online features

## 🚀 App Configuration

- **Package**: com.smarttoolkit.app
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Version**: 1.0.0 (1)

## 🎯 Features Implemented

✅ **Core Architecture**
- Clean Architecture pattern
- SOLID principles
- Provider state management
- Material 3 theming

✅ **All 15 Tools**
- Fully functional implementations
- Local data persistence
- Hardware integrations
- Modern UI design

✅ **Production Ready**
- Android build configuration
- Permissions setup
- Optimized performance
- Ready for Play Store

## 📱 Screenshots & Assets

### Recommended Assets:
- **App Icon**: 1024x1024 PNG
- **Feature Graphic**: 1024x500 PNG
- **Screenshots**: Various device sizes

### Icon Design:
- Modern toolkit/toolbox concept
- Material Design guidelines
- Primary color: #6200EE
- Clean, recognizable symbols

## 🤝 Support & Contributing

1. Fork repository
2. Create feature branch
3. Submit Pull Request

For issues and questions, please use the GitHub Issues tab.

---

**SmartToolkit** - Your complete utility companion! 🛠️✨
