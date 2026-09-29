# FotoPro 📸

Ücretsiz, filigransız fotoğraf düzenleme uygulaması.
Android ve iOS hedeflenmiştir.

## Özellikler — v1.0
- Galeriden fotoğraf seçme
- Kameradan fotoğraf çekme
- Kırpma
- Parlaklık
- Kontrast
- Doygunluk
- Sıcaklık
- Hazır filtreler
- Yazı ekleme
- Çerçeve
- Sıfırlama
- Paylaşma
- Koyu modern arayüz

## GitHub'a yükledikten sonra

GitHub Codespaces veya Flutter kurulu bilgisayarda:

```bash
flutter pub get
flutter run
```

Android APK:
```bash
flutter build apk --release
```

iOS için macOS ve Xcode gerekir:
```bash
flutter build ipa --release
```

## Önemli

Bu paket kaynak kodunu GitHub'a yüklemek için hazırlanmıştır.
Flutter'ın Android/iOS platform klasörleri (`android/` ve `ios/`) GitHub'a yüklemeden önce:

```bash
flutter create .
```

komutuyla oluşturulmalıdır.

Sonraki geliştirmelerde nesne silme, gelişmiş filtreler, fotoğraf kaydetme/export kalitesi ve mağaza hazırlığı eklenebilir.
