# ⚡ TinyImg — Flutter Image Compression App

A minimal, modern image compression app built with Flutter.

## Features
- 🗜 Compress JPEG, PNG, WebP images
- 🎚 Adjustable quality (10–100%)
- 📦 Batch compress multiple images
- 📊 Live stats (saved size, compression %)
- 📤 Share compressed images
- 🌙 Dark minimal UI

## Project Structure

```
lib/
├── main.dart                  # App entry, theme, colors
├── models/
│   └── image_item.dart        # Image data model
├── screens/
│   └── home_screen.dart       # Main screen
├── services/
│   └── compression_service.dart
└── widgets/
    ├── drop_zone.dart          # Empty state / pick zone
    ├── image_card.dart         # Per-image card
    └── settings_bar.dart       # Quality & format controls
```

## Setup & Run

### 1. Install Flutter
https://docs.flutter.dev/get-started/install

### 2. Get dependencies
```bash
flutter pub get
```

### 3. Run on device/emulator
```bash
flutter run
```

### 4. Build APK
```bash
flutter build apk --release
```

## Packages Used

| Package | Purpose |
|---------|---------|
| `flutter_image_compress` | Core compression engine |
| `image_picker` | Gallery access |
| `path_provider` | Temp file storage |
| `share_plus` | Share compressed files |
| `permission_handler` | Runtime permissions |

## Permissions

### Android
- `READ_MEDIA_IMAGES` (Android 13+)
- `READ_EXTERNAL_STORAGE` (Android ≤12)
- `WRITE_EXTERNAL_STORAGE` (Android ≤9)

### iOS
Add to `Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>TinyImg needs access to compress your photos.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>TinyImg saves compressed images to your library.</string>
```

## Color Palette

| Token | Hex |
|-------|-----|
| Background | `#0A0A0F` |
| Surface | `#13131A` |
| Accent | `#7C5CFC` |
| Accent2 | `#E05AFF` |
| Green | `#2AFFA3` |
| Red | `#FF5A7E` |
