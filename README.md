## 🚀 Build & Run Instructions

### 📦 Requirements

- **Flutter SDK** (≥ 3.x)
- **Dart SDK**
- **Android Studio**, **VS Code**, or any Flutter-compatible IDE
- A connected **Android device** or **emulator**
- Internet access to fetch meme templates

---

### 🔧 Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Dustymon111/offline-meme-editor.git
   cd offline-meme-editor
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Generate necessary files**<br>
    This project uses build_runner to generate:
    - Hive type adapters for local caching
    - Mockito mocks for unit testing
   ```bash
   flutter pub run build_runner build
   ```
### 🛠️ Run the App
  ```bash
    flutter run
   ```
### ✅ Run Tests
   ```bash
    flutter test
   ```
