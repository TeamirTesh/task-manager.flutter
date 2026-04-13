# Task Manager

A Flutter app that manages tasks with Firebase Cloud Firestore. You can create tasks, mark them complete, add nested subtasks, and sync data in real time. The UI includes validation, search, and swipe gestures for a smoother workflow.

## Enhanced Features

- **Search / filter by task name** — A search bar at the top filters the task list locally (case-insensitive match on the task name). Clear the field to show all tasks again.
- **Swipe-to-delete with `Dismissible`** — Each task row can be swiped horizontally to delete it, with a visible delete background while dragging.

## Setup Instructions

1. **Install dependencies**

   ```bash
   flutter pub get
   ```

2. **Configure Firebase for this app**

   From the project directory, run the FlutterFire CLI so `firebase_options.dart` matches your Firebase project:

   ```bash
   flutterfire configure
   ```

   Select your Firebase project and the platforms you intend to run (for example, Android, iOS, web, Windows).

3. **Run the app**

   ```bash
   flutter run
   ```

   Use a connected device or emulator, and ensure Firestore rules and indexes allow the operations your app performs.

## Known Limitations

- **Firebase required** — The app expects Firebase to be initialized and Firestore to be reachable; running without valid configuration or network access will show errors instead of tasks.
- **Search is client-side only** — Filtering applies to the tasks already loaded in the stream; it does not query Firestore with server-side search.
- **Subtasks** — Empty subtask names are not submitted from the UI, but the data model does not enforce uniqueness beyond Firestore array behavior.
- **Swipe vs. expand** — Horizontal swipe deletes a task; expanding/collapsing uses the tile chevron—wide horizontal drags may feel similar on some devices, so users should use the chevron when they only want to expand.
