# Flutter Mobile App Release Guide

This document outlines the steps to build, sign, and release the KrushikaDhara mobile app for production on Android (Google Play).

## 1. Prerequisites

Before building the app, ensure the following steps are complete:
- Update `lib/services/api_service.dart` to point to the **Production URL**.
- Remove any dummy or hardcoded testing accounts.

## 2. Generating Android App Icons & Splash Screen
Ensure your logo is placed inside the `assets/` folder.

1. **Icons**: Run the flutter launcher icons builder:
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```
2. **Splash Screen**: Update `flutter_native_splash.yaml` and run:
   ```bash
   flutter pub run flutter_native_splash:create
   ```

## 3. Configuring Permissions
Verify `android/app/src/main/AndroidManifest.xml` contains only the required permissions for the village farmers:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/> <!-- For Voice Assistant -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/> <!-- For Farmer Connect -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

## 4. Signing the App (KeyStore)
Google Play requires all APKs and AppBundles to be digitally signed.

1. **Create a Keystore**:
   ```bash
   keytool -genkey -v -keystore c:\Users\Name\krushika_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias krushika
   ```
2. Create `android/key.properties`:
   ```properties
   storePassword=your_password
   keyPassword=your_password
   keyAlias=krushika
   storeFile=C:/Users/Name/krushika_key.jks
   ```
3. Update `android/app/build.gradle` to reference `key.properties`.

## 5. Building for Production

### To test on devices (APK):
```bash
flutter build apk --release
```
_Find the APK in `build/app/outputs/flutter-apk/app-release.apk`_

### To upload to Google Play Store (AppBundle):
```bash
flutter build appbundle --release
```
_Find the AAB in `build/app/outputs/bundle/release/app-release.aab`_

## 6. Play Store Metadata Checklist
When uploading to the Google Play Console, you will need:
- **Title**: KrushikaDhara: Smart Farming
- **Short Description**: Crop disease detection, market prices, and Kannada voice assistant for farmers.
- **Full Description**: (Include details on AI detection, weather integration, and farmer community).
- **Screenshots**: Minimum 4 screens showing the Pest UI, Market, Voice UI, and Community Map.
- **Privacy Policy URL**: Link to your hosted privacy policy (required because of Camera and Location permissions).
