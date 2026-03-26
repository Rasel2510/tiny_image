# ⚡ TinyImg — Flutter Image Compression App

A minimal, modern **offline** image compression app built with Flutter.

---

## Features

- 🗜 Compress JPEG, PNG, WebP images
- 🎚 Adjustable quality slider (10–100%)
- 📦 Batch compress multiple images at once
- 📊 Live stats — files done, total saved, average %
- 💾 Save compressed image to gallery
- 📤 Share single or all compressed images
- 🔁 Retry failed compressions
- ⚠️ Detects if compressed file is larger than original
- 🌙 Dark minimal UI with purple gradient accents
- 🔒 100% offline — no internet needed

---

## Project Structure

```
tinyimg/
├── lib/
│   ├── main.dart                        # Entry point, theme, AppColors
│   ├── models/
│   │   └── image_item.dart              # Immutable data model with copyWith
│   ├── screens/
│   │   └── home_screen.dart             # Main screen, all business logic
│   ├── services/
│   │   └── compression_service.dart     # Compression + gallery save
│   └── widgets/
│       ├── drop_zone.dart               # Animated empty state
│       ├── image_card.dart              # Per-image card widget
│       └── settings_bar.dart            # Quality slider + format selector
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/example/tinyimg/MainActivity.kt
│   │       └── res/xml/file_paths.xml   # Required for FileProvider (share_plus)
│   ├── build.gradle
│   ├── gradle.properties
│   └── settings.gradle
├── ios/
│   └── Runner/
│       └── Info.plist                   # Photo permissions for iOS
└── pubspec.yaml
```

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_image_compress` | ^2.3.0 | Core compression (JPEG/PNG/WebP) |
| `image_picker` | ^1.1.2 | Pick images from gallery |
| `path_provider` | ^2.1.4 | Temp directory for output files |
| `share_plus` | ^10.1.4 | Share compressed files |
| `permission_handler` | ^11.3.1 | Runtime storage permissions |
| `gal` | ^2.3.0 | Save to device gallery |

---

## Setup & Run

### 1. Prerequisites
- Flutter SDK ≥ 3.3.0
- Android Studio or Xcode
- A device or emulator

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run in debug mode
```bash
flutter run
```

### 4. Build release APK
```bash
flutter build apk --release
```

### 5. Build release AAB (for Play Store)
```bash
flutter build appbundle --release
```

### 6. Build for iOS
```bash
flutter build ios --release
```

---

## Android Permissions Explained

| Permission | SDK | Reason |
|-----------|-----|--------|
| `READ_EXTERNAL_STORAGE` | ≤ 32 | Read images on Android 12 and below |
| `WRITE_EXTERNAL_STORAGE` | ≤ 29 | Write files on Android 9 and below |
| `READ_MEDIA_IMAGES` | 33+ | Read images on Android 13+ |
| `INTERNET` | all | Reserved for future features |
| `VIBRATE` | all | Haptic feedback on compression done |

---

## iOS Permissions (Info.plist)

| Key | Reason |
|-----|--------|
| `NSPhotoLibraryUsageDescription` | Read photos for compression |
| `NSPhotoLibraryAddUsageDescription` | Save compressed image to gallery |
| `NSCameraUsageDescription` | Optional: compress camera photos |

---

## Known Notes

- **PNG compression**: PNG is lossless — quality slider has no effect on PNG.
  File size reduction comes from metadata stripping only.
- **WebP**: Best compression ratio for photos. Recommended format.
- **"Larger" warning**: If compressed file is bigger than original (common with
  low-quality PNGs), the card shows a red "+larger" badge. Use JPEG or WebP instead.
