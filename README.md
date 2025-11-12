# 🧘‍♀️ **DHYANA – Mindfulness & Wellness Companion App**

> “Technology meets tranquility.”  
> Dhyana is an AI-powered mindfulness application designed to help users achieve balance, mental clarity, and emotional well-being through guided therapies, journaling, and gamified wellness progress.

---

## 🌿 Overview

**Dhyana** is a holistic mobile application built with **Flutter** that combines **AI-driven support**, **mindfulness exercises**, and **gamified motivation** to improve emotional health and mindfulness habits.  

It integrates guided breathing, music and yoga therapy, journaling, and a conversational AI companion — creating a peaceful, interactive environment for self-care and personal growth.

---

## ✨ Features

| Category | Description |
|-----------|--------------|
| 🧘 **Therapy Suite** | Guided breathing (Box Breathing, 4-7-8), yoga, music & laughing therapy sessions |
| 🤖 **AI Wellness Companion** | Gemini API–powered chatbot for mindfulness tips, empathy, and emotional support |
| 📓 **Personal Journal** | Private journaling with mood tracking, gratitude logs, and pinned entries |
| 🏆 **Gamified Progress** | Earn “gems”, unlock levels & badges, and track streaks to stay motivated |
| 📚 **Educational Hub** | Curated mindfulness articles with Text-to-Speech (TTS) accessibility |
| 📶 **Offline Mode** | Download music and articles for offline access |
| ⚙️ **Admin Panel** | Manage content such as articles, videos, and feedback |
| 🌗 **Calm UI** | Minimal, distraction-free interface with dark and light modes |

---

## 🧱 System Architecture

### 🧩 Clean Architecture (Flutter + Riverpod)

- **Presentation Layer** – UI and user interaction (`screens`, `widgets`)  
- **Application Layer** – State management & business logic (`providers`, `models`)  
- **Data Layer** – APIs, Firebase, Cloudinary, and service integrations (`services`)  

**Core Principles**
- Separation of Concerns  
- Dependency Inversion  
- Scalability & Maintainability  
- Platform Independence  
- Testability  

---

## ⚙️ Tech Stack

| Component | Technology |
|------------|-------------|
| **Frontend** | Flutter (Dart) |
| **State Management** | Riverpod |
| **Backend & Auth** | Firebase (Auth, Firestore, Storage) |
| **AI/NLP** | Google Gemini API |
| **Media & Assets** | Cloudinary, Jamendo API |
| **Audio/Video** | JustAudio, YouTube Player Flutter |
| **Offline Storage** | SharedPreferences, Flutter Downloader |
| **Version Control** | Git & GitHub |

---

## 🚀 Getting Started

### 🧩 Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.4.3 or higher)
- Android Studio / VS Code
- Firebase Project Setup (with Firestore & Auth)
- Jamendo API Key  
- Google Gemini API access  
- Cloudinary account for media hosting  

### ⚙️ Installation

```bash
# Clone the repository
git clone https://github.com/AashishG-dev/dhyana.git

# Navigate into the project
cd dhyana

# Install dependencies
flutter pub get

# Run the app
flutter run
