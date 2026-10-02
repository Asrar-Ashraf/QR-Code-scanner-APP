<div align="center">

# 📱 QR Studio

### Generate • Scan • Share QR codes with a modern dark UI

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material%203-7C6CFF?style=for-the-badge&logo=materialdesign&logoColor=white)
![Platform](https://img.shields.io/badge/Android%20%7C%20iOS-22D3EE?style=for-the-badge)

</div>

---

## ✨ Overview

**QR Studio** is a Flutter app that lets you create QR codes from text or links, scan existing QR codes, and turn them into a clean, printable **QR card** with your name and date. You can save the card to your gallery or share it with anyone.

The whole app uses a dark glass-style design with smooth animations.

---

## 📸 Screenshots

<div align="center">

| 🏠 Home | ⚡ Generate QR | 🪪 QR Card |
|:-------:|:-------------:|:----------:|
| [<img src="image/home.jpeg" width="230" alt="Home Screen">](image/home.jpeg) | [<img src="image/GQR.jpeg" width="230" alt="Generate QR">](image/GQR.jpeg) | [<img src="image/QRCard.jpeg" width="230" alt="QR Card">](image/QRCard.jpeg) |

*Click any screenshot to view it in full size.*

[Home](image/home.jpeg) · [Generate QR](image/GQR.jpeg) · [QR Card](image/QRCard.jpeg)

</div>

---

## 🚀 Features

| | Feature | Description |
|---|---------|-------------|
| 🎬 | **Animated Splash** | QR-style logo animation with a smooth transition to Home |
| 🏠 | **Modern Home** | Animated background with three option cards |
| 📷 | **Scan QR Code** | Scan any QR, enter a name, and get a QR card |
| ✍️ | **Text / Link to QR** | Type text or a link plus a name to generate a QR card |
| 🔗 | **Scan & Open** | Scan a QR and instantly open its link, phone number or email |
| 🪪 | **QR Card** | Poster-style card with QR, user name and date |
| ⬇️ | **Download** | Save the card to the phone gallery |
| 📤 | **Share** | Share the card through any app |
| 🌙 | **Dark Design** | Glass containers, gradients and smooth animations |
| 🛡️ | **Validation** | Friendly errors for empty fields, long text and camera permission |

---

## 🔄 App Flow

```
Splash ──► Home ──┬──► Scan QR Code ──► Enter Name ──► QR Card ──► Download / Share
                  ├──► Text / Link  ──► Enter Name ──► QR Card ──► Download / Share
                  └──► Scan & Open  ──► Open link / call / email
```

---

## 🛠️ Tech Stack

| Package | Purpose |
|---------|---------|
| `mobile_scanner` | QR scanning with the camera |
| `qr_flutter` | QR code generation |
| `gal` | Saving images to the gallery |
| `share_plus` + `path_provider` | Sharing the QR card |
| `url_launcher` | Opening links, phone calls and emails |
| `google_fonts` | Poppins and Inter typography |
| `flutter_animate` | Smooth animations |

---

## 📂 Project Structure

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── scanner_screen.dart
│   ├── quick_scan_screen.dart
│   ├── text_link_screen.dart
│   └── final_card_screen.dart
└── widgets/
    ├── animated_background.dart
    ├── option_card.dart
    └── qr_poster_card.dart
```

---

## ⚙️ Getting Started

**1. Clone the repository**
```bash
git clone <your-repo-link>
cd qr_generator
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Run the app** (use a real device or an emulator with a camera)
```bash
flutter run
```

### 🔐 Permissions

| Platform | Setup |
|----------|-------|
| **Android** | `CAMERA` permission and `minSdk 23` |
| **iOS** | `NSCameraUsageDescription` and `NSPhotoLibraryAddUsageDescription` in `Info.plist` |

---

## 👤 Author

**Muhammad Asrar**
Flutter Developer

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/your-username)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://linkedin.com/in/your-profile)

---

<div align="center">

⭐ If you like this project, give it a star!

</div>
