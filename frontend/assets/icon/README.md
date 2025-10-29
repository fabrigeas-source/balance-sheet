Drop a high-resolution square PNG (recommended 1024x1024) named `app_icon.png` in this folder.

Then run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

This will generate platform app icons for Android and iOS using the image at `assets/icon/app_icon.png`.

Notes:
- If you want adaptive icons on Android, update `flutter_icons` configuration in `pubspec.yaml`.
- After generating icons, open Xcode and verify `ios/Runner/Assets.xcassets/AppIcon.appiconset` contains the new icons.
- If you plan to upload to the App Store, Apple requires a 1024x1024 App Store icon; ensure `app_icon.png` is that size.
