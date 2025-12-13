# 📱 Play Store Release Checklist

## ✅ Yang Sudah Siap

### 1. Build Configuration
- ✅ Version: 1.0.0+5 (versionName + versionCode)
- ✅ Application ID: com.newtodolist
- ✅ Min SDK: Sudah dikonfigurasi
- ✅ Target SDK: Sudah dikonfigurasi
- ✅ Signing config: Sudah dikonfigurasi (key.properties)
- ✅ App icon: Sudah ada di semua density

### 2. Code Quality
- ✅ No linter errors
- ✅ No TODO/FIXME comments (sudah dibersihkan)
- ✅ DebugPrint masih ada (acceptable untuk error logging)

### 3. UI/UX
- ✅ Dark mode support
- ✅ Responsive design
- ✅ Error handling
- ✅ Loading states

## ⚠️ Yang Perlu Diperbaiki SEBELUM Release

### 🔴 CRITICAL - Security Issues

1. **API Keys Hardcoded** ⚠️
   - File: `lib/utils/constants.dart`
   - **Masalah**: Supabase URL dan anon key hardcoded
   - **Risiko**: Jika di-commit ke public repo, keys bisa terlihat
   - **Solusi**: 
     - Pindahkan ke environment variables
     - Atau gunakan `flutter_dotenv` package
     - Atau pastikan file ini di `.gitignore` (tapi tidak disarankan)

2. **Google Client ID Hardcoded** ⚠️
   - File: `lib/services/supabase_service.dart` line 12-13
   - **Masalah**: Google Client ID hardcoded
   - **Risiko**: Bisa digunakan oleh orang lain
   - **Solusi**: Pindahkan ke environment variables

3. **Credentials File di Codebase** ⚠️
   - File: `lib/services/client_secret_*.json`
   - **Masalah**: File credentials Google ada di codebase
   - **Risiko**: Credentials bisa ter-expose
   - **Solusi**: 
     - Hapus dari codebase
     - Tambahkan ke `.gitignore`
     - Gunakan environment variables

4. **Network Security Config** ✅ (SUDAH DIPERBAIKI)
   - File: `android/app/src/main/res/xml/network_security_config.xml`
   - **Status**: Sudah diubah ke `cleartextTrafficPermitted="false"`

5. **Key Properties** ⚠️
   - File: `android/key.properties`
   - **Masalah**: Berisi password signing
   - **Status**: Sudah ditambahkan ke `.gitignore`
   - **Action**: Pastikan file ini TIDAK di-commit ke git

### 🟡 IMPORTANT - App Configuration

1. **App Name** ✅ (SUDAH DIPERBAIKI)
   - AndroidManifest: "DoList"
   - pubspec.yaml description: Sudah diupdate

2. **Version Number**
   - Current: 1.0.0+5
   - **Rekomendasi**: Untuk first release, bisa tetap 1.0.0+1

3. **Package Name**
   - Current: com.newtodolist
   - **Status**: OK, tapi pastikan unik dan sesuai brand

### 🟢 NICE TO HAVE - Before Release

1. **Privacy Policy & Terms**
   - Saat ini masih "coming soon"
   - **Action**: Buat halaman privacy policy dan terms of service
   - **URL**: Bisa di GitHub Pages atau website sederhana

2. **App Screenshots**
   - Siapkan screenshots untuk Play Store listing
   - Minimal: Phone (2x), Tablet (1x), Feature graphic

3. **App Description**
   - Siapkan description panjang (4000 chars)
   - Siapkan short description (80 chars)
   - Siapkan keywords untuk ASO

4. **ProGuard Rules** (Optional)
   - File: `android/app/proguard-rules.pro`
   - Untuk obfuscation dan minification
   - Bisa ditambahkan nanti jika perlu

5. **Crash Reporting**
   - Pertimbangkan menambahkan Firebase Crashlytics
   - Atau Sentry untuk error tracking

6. **Analytics** (Optional)
   - Pertimbangkan Firebase Analytics
   - Untuk tracking user behavior

## 📋 Pre-Release Checklist

### Build & Test
- [ ] Build release APK: `flutter build apk --release`
- [ ] Build release App Bundle: `flutter build appbundle --release`
- [ ] Test APK di berbagai device
- [ ] Test di Android 5.0+ (min SDK)
- [ ] Test di Android 14+ (latest)
- [ ] Test semua fitur utama
- [ ] Test login/logout flow
- [ ] Test offline behavior (jika ada)

### Security
- [ ] Pastikan key.properties TIDAK di-commit
- [ ] Pastikan upload-key.jks TIDAK di-commit
- [ ] Review semua API keys (jika perlu pindah ke env vars)
- [ ] Test dengan network security config baru

### Store Listing
- [ ] Siapkan app icon (512x512 PNG)
- [ ] Siapkan feature graphic (1024x500 PNG)
- [ ] Siapkan screenshots (minimal 2, maksimal 8)
- [ ] Tulis app description
- [ ] Tulis short description
- [ ] Pilih category
- [ ] Set content rating
- [ ] Set target audience
- [ ] Set pricing (Free/Paid)

### Legal
- [ ] Privacy Policy URL (wajib untuk Play Store)
- [ ] Terms of Service URL (optional tapi recommended)
- [ ] Data safety form di Play Console

### Testing
- [ ] Internal testing di Play Console
- [ ] Closed testing dengan beta testers
- [ ] Open testing (optional)

## 🚀 Release Steps

1. **Final Build**
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```

2. **Upload ke Play Console**
   - Login ke Google Play Console
   - Create new app (jika belum)
   - Upload AAB file
   - Isi semua metadata
   - Submit for review

3. **Monitor**
   - Monitor crash reports
   - Monitor user reviews
   - Siapkan update jika ada bug critical

## ⚠️ PERINGATAN PENTING

1. **JANGAN commit file berikut ke git:**
   - `android/key.properties`
   - `android/app/upload-key.jks`
   - `lib/services/client_secret_*.json`
   - File dengan API keys/credentials

2. **Pastikan `.gitignore` sudah benar** sebelum push ke repository

3. **API Keys**: Pertimbangkan untuk memindahkan ke environment variables untuk production

4. **Test thoroughly** sebelum release ke production

## 📝 Notes

- Version 1.0.0+5 sudah OK untuk first release
- App name "DoList" sudah lebih professional
- Network security sudah diperbaiki
- Key properties sudah di-ignore

**Status Overall**: 🟡 **Hampir Siap** - Perlu perbaikan security issues sebelum release

