# OpenStack

AI-Assisted Open-Source Contribution Finder (MVP) A Flutter application, designed to help developers discover GitHub issues and repositories to contribute to.

The goal of this app is to eventually help users find suitable GitHub issues and repositories to contribute to, with AI assistance for summarization and recommendations.

## 📂 Folder Structure

```text
.
├─ android/        # Android project (Gradle)
├─ ios/            # iOS project (Xcode)
├─ lib/            # Dart source (see below)
├─ web/            # Web entry
├─ windows/ linux/ macos/  # Desktop shells
├─ test/           # Tests
├─ pubspec.yaml    # Flutter deps & config
└─ README.md
```

## lib/ (source layout)

```text
lib/
├─ core/                # shared utilities (e.g., pagination, result)
├─ domain/              # entities + enums
│  ├─ entities/         # User, Issue, Repository, etc.
│  └─ enums/            # AuthProvider, DifficultyPreference
├─ data/                # repository interfaces & sources
│  ├─ repositories/     # AuthRepository, ProfileRepository, ...
│  └─ local/ sources/   # LocalCache, GitHubSource
├─ services/            # business logic services (AI, recs, badges)
│  └─ ai/               # AI provider interfaces & heuristics
├─ presentation/        # Riverpod controllers (no UI yet)
│  └─ controllers/
├─ app.dart             # root app widget
└─ main.dart            # entrypoint
```

## 🛠️ Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/oRioN-Genics/OpenStack.git
cd OpenStack
```

### 2. Install dependencies

```
flutter pub get
```

### 3. Run the app

```
flutter run
```
