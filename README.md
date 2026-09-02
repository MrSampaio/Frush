# 📚 Frush: Reading Companion & Focus Tracker

Frush is a native iOS reading companion that helps readers build consistent habits by combining a personal book library, a distraction-free reading timer, and rich notes with photos. The app guides users from onboarding through daily reading sessions, tracking progress page by page and turning reading time into Live Activities on the Lock Screen and Dynamic Island. Frush allows readers to set daily goals, log their sessions, capture thoughts and images from their books, and watch their progress grow over time.

## 🚀 Features
- **Personal Book Library**: Add, edit, and organize books with cover, author, category, and total page count.
- **Reading Stopwatch**: A focused reading timer with pause/resume, background-aware state recovery, and animated pulsing rings.
- **Live Activities & Widgets**: The active reading session is mirrored on the Lock Screen and Dynamic Island via ActivityKit, plus a Home Screen widget built with WidgetKit.
- **Progress Tracking**: Log current page after each session, automatically calculate reading progress, and track when a book was started.
- **Notes with Photos**: Create notes linked to a book, attach photos from the camera or photo library, and browse them by category.
- **Daily Goals & Onboarding**: A guided onboarding flow lets users set a daily reading goal (in minutes) that's tracked across sessions.
- **Search**: Instantly search across saved books and notes by title.
- **Sound & Notification Feedback**: Custom sounds and local notifications reinforce session completion and daily goals.
- **Deep Linking**: Custom URL scheme (`frush://stopwatch`) routes users straight into an active reading session.

## 🛠️ Tech Stack
- **Frontend**: SwiftUI
- **Backend**: Not applicable (client-side application)
- **Database**: SwiftData (local persistence)
- **AI Tools**: Not applicable
- **Build Tools**: Xcode
- **Frameworks**: Combine, ActivityKit (Live Activities & Dynamic Island), WidgetKit, AppIntents, PhotosUI, UIKit (Camera Picker), AVKit (Splash video)
- **Libraries**: Not applicable

## 📂 Project Structure
```
Frush
├── FrushWidget
│   ├── FrushWidgetBundle.swift
│   ├── FrushWidget.swift
│   ├── FrushWidgetControl.swift
│   ├── FrushWidgetLiveActivity.swift
│   ├── AppIntent.swift
├── Shared
│   ├── ReadingActivityAttributes.swift
├── Flush
│   ├── CH4_BooksApp.swift
│   ├── ViewModel
│   │   ├── BookFilterViewModel.swift
│   │   ├── UserSettingsViewModel.swift
│   │   ├── AppRouter.swift
│   │   ├── StopwatchViewModel.swift
│   │   ├── NotesViewModel.swift
│   │   ├── PhotoLibraryViewModel.swift
│   │   ├── BooksViewModel.swift
│   ├── Managers
│   │   ├── CoreDataManager.swift
│   │   ├── SoundManager.swift
│   │   ├── NotificationManager.swift
│   │   ├── LiveActivityManager.swift
│   ├── Model
│   │   ├── NoteImageModel.swift
│   │   ├── UserSettingsModel.swift
│   │   ├── BooksModel.swift
│   │   ├── NotesModel.swift
│   ├── Extensions
│   │   ├── FontTypography.swift
│   ├── Services
│   │   ├── CameraPicker.swift
│   ├── View
│   │   ├── Onboarding
│   │   │   ├── SplashView.swift
│   │   │   ├── FirstOnboardView.swift
│   │   │   ├── SecondOnboardView.swift
│   │   ├── Core
│   │   │   ├── ContentView.swift
│   │   ├── Books
│   │   │   ├── BookSearchView.swift
│   │   │   ├── BookDetailsView.swift
│   │   │   ├── BookCaseView.swift
│   │   ├── Notes
│   │   │   ├── MyNotesListView.swift
│   │   │   ├── NotesView.swift
│   │   ├── Stopwatch
│   │   │   ├── StopwatchRunningView.swift
│   │   │   ├── StopwatchFlowView.swift
│   │   │   ├── StopwatchInicialView.swift
│   │   ├── Sheets
│   │   │   ├── SelectBookSheetView.swift
│   │   │   ├── NoteSheetView.swift
│   │   │   ├── NoteDetailSheetView.swift
│   │   │   ├── BottomSheet.swift
│   │   │   ├── PageProgressSheet.swift
│   │   │   ├── BookSheetView.swift
│   │   ├── Components
│   │   │   ├── StopwatchComponents/
│   │   │   ├── OnboardingComponents/
│   │   │   ├── NotesComponents/
│   │   │   ├── BooksComponents/
│   │   │   ├── BooksDetailsComponents/
│   │   │   ├── SheetsComponents/
│   │   │   ├── GeralComponents/
│   │   ├── PreviewHelper
│   │   │   ├── PreviewProviderHelper.swift
```

## 📱 System Showcase

<div align="center">
  <img src="./documentation/Shot.svg" alt="Frush App" width="1000"/>
</div>

## 📦 Installation & Build

Frush is a native iOS project built with Xcode. To run it locally, follow these steps:

**1. Clone the repository**

Open your Terminal and run:

```bash
git clone https://github.com/MrSampaio/Frush.git
```

**2. Open the project in Xcode**

Navigate to the cloned folder and double-click the `.xcodeproj` (or `.xcworkspace`) file to open it in Xcode.

**3. Select the Build Target**

In the Xcode top toolbar, click on the active scheme name (next to the Stop button) and choose the `Frush` scheme, then pick an iPhone Simulator (e.g., iPhone 15 Pro) or your connected physical device. Note that Live Activities and the Home Screen widget require a physical device or a simulator running iOS 16+.

**4. Compile and Run**

Press `Cmd + R` or click the Play (▶) button. Xcode will resolve any internal dependencies, compile the Swift code, and launch the application.

---

## 💻 Usage Guide

Once the application is compiled and running, explore the reading flow by following the core steps:

1. **Onboarding**: On first launch, watch the animated splash screen and set your daily reading goal (in minutes) through the guided onboarding.

2. **Add a Book**: From the library, add a new book with its title, author, category, cover image, and total page count.

3. **Start a Session**: Select a book and start the reading Stopwatch. Pause and resume freely — the app recovers your session state even if it's backgrounded or force-closed.

4. **Track on the Go**: Check your remaining reading time from the Lock Screen or Dynamic Island via the Live Activity, or glance at the Home Screen widget.

5. **Log Progress**: When the timer finishes, update your current page in the Page Progress sheet to keep your reading percentage accurate.

6. **Capture Notes**: Add notes to any book, attaching photos from your camera or photo library, and revisit them later from the Notes tab.

7. **Search Everything**: Use the search bar to instantly filter across your saved books and notes.

---

## 🍎 Thank you, Apple Developer Academy teammates!

This project was developed in collaboration with the Frush team. Without you guys, this wouldn't have been possible! ❤️
