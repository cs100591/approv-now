<p align="center">
  <img src="https://via.placeholder.com/200x200/4A90E2/FFFFFF?text=AN" alt="Approv Now Logo" width="200"/>
</p>

<h1 align="center">Approv Now</h1>

<p align="center">
  <b>Mobile-first deterministic approval engine with multi-workspace architecture</b>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-blue.svg" alt="Flutter"/></a>
  <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/Firebase-Cloud%20Firestore-orange.svg" alt="Firebase"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"/></a>
  <a href="https://github.com/cs100591/approv-now/releases"><img src="https://img.shields.io/badge/Version-1.0.0-blue.svg" alt="Version"/></a>
</p>

---

## 🚀 Features

### 🤖 AI-Powered Template Generation
- **15 preset scenarios** covering common business processes
- **DeepSeek AI integration** (50% cost savings vs OpenAI)
- **Local matching** + **AI fallback** for optimal performance
- Smart field and approval flow recommendations

### 🔄 Multi-Level Approval Engine
- Sequential approval workflows
- Multi-signature support (parallel approvals)
- Conditional routing based on amount, days, etc.
- Complete audit trail and history

### 📱 Cross-Platform
- **iOS** - Native performance
- **Android** - Material Design 3
- **Web** - Progressive Web App ready

### 📄 PDF Export & Verification
- One-click PDF generation
- Custom branding (header/footer)
- SHA-256 hash verification
- Tamper-proof documents

### 🏢 Multi-Workspace Management
- Auto-create default workspace
- Workspace switching
- Team member management
- Role-based permissions

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Frontend** | Flutter 3.x |
| **Backend** | Firebase (Firestore, Auth, Storage, FCM) |
| **State Management** | Provider |
| **AI** | DeepSeek API |
| **PDF** | pdf + printing |

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.0+ 
- Dart 3.0+
- Firebase account
- Xcode (for iOS)
- Android Studio (for Android)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/cs100591/approv-now.git
cd approv-now
```

2. **Install dependencies**
```bash
flutter pub get
cd ios && pod install && cd ..
```

3. **Configure Firebase**
   - Create a Firebase project at [firebase.google.com](https://firebase.google.com)
   - Add iOS/Android apps
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place in respective directories

4. **Run the app**
```bash
flutter run
```

---

## 📱 Usage

### 1. First Time Setup
- Open app → Register account
- System auto-creates default workspace

### 2. Create Approval Template
- Go to **Templates** → Tap **+**
- Enter template name (e.g., "Leave Request")
- AI automatically generates fields
- Save template

### 3. Submit Request
- Dashboard → **New Request**
- Select template → Fill form
- Submit for approval

### 4. Approve Request
- **My Approvals** → Review request
- Approve/Reject with comments

---

## 📊 Project Structure

```
lib/
├── core/                    # Core utilities
├── modules/                 # Feature modules
│   ├── auth/               # Authentication
│   ├── workspace/          # Workspace management
│   ├── template/           # Template system + AI
│   ├── request/            # Request management
│   ├── approval_engine/    # Approval logic
│   ├── export/             # PDF export
│   └── notification/       # Push notifications
└── main.dart
```

---

## 📄 Documentation

- [FEATURES.md](FEATURES.md) - Detailed feature documentation
- [TEST_REPORT.md](TEST_REPORT.md) - Testing and quality report
- [FINAL_REPORT.md](FINAL_REPORT.md) - Project completion report
- [FIREBASE_FIX_GUIDE.md](FIREBASE_FIX_GUIDE.md) - Firebase setup guide

---

## 🎯 Roadmap

### v1.1.0
- [ ] Advanced search functionality
- [ ] Offline mode support
- [ ] Push notification enhancements

### v1.2.0
- [ ] Workflow designer (visual)
- [ ] Third-party integrations
- [ ] Advanced analytics dashboard

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file.

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/cs100591/approv-now/issues)
- **Email**: support@approvnow.app

---

<p align="center">
  Made with ❤️ by the Approv Now Team
</p>
