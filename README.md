# Mindfull

> A personal project: Built this app for myself to track my own mindfulness,
> habits, and day-to-day life. It isn't a commercial product and isn't on any
> app store.

Mindfull puts a daily journal, habit tracker, task list, spending tracker, and
an experimental AI food scanner in one calm app with a dark frosted-glass
look. I built it because I wanted a single place to check in with myself each
day, instead of spreading that across five different apps.

You don't even have to open it: **native home screen widgets** (iOS and
Android) plus an iOS lock screen widget, **app icon shortcuts**, and **Siri / Back Tap** support put
the most common check-ins one tap away.

Built with **Flutter** for **iOS and Android**, with **Supabase** as the backend.

---

## Features

### 🏠 Today at a glance
- A home dashboard with a greeting, a new quote each day, and streak cards for
  journaling, habits, and tasks due
- A remaining-budget card with a progress gauge that turns amber, then red, as
  you get close to your limit
- Quick sections for today's tasks, habits, and journal prompts
  ("Write today's plan" / "Review what happened")

### 📓 Journal
- Write entries with a mood (😊 😐 😢 😰 🤩), photos, and an optional title
- Entries grouped by month, with search
- A full-screen editor that keeps the mood and save bar above the keyboard
- Morning and evening reminders to plan and reflect

### 💪 Routines
- Custom routines, each with an emoji icon, a color, and custom actions
- Reminders on the weekdays you pick, with action buttons in the notification
- A monthly calendar for each habit, showing streaks and completed days

### ✅ Todo
- Due dates, reminders, and subtask checklists with a progress bar
- Grouped into Today / Upcoming / No date / Completed
- A "Mark done" action right in the reminder notification

### 💰 CashFlow flow
- Log spending and income by category, with a monthly or daily budget
- Filter by Today / This Week / This Month / All
- A recap with a spending-by-category bar chart (drawn with `CustomPaint`)
- **✨ AI spending advice** (Gemini): an overview, where your money goes, and
  tips for saving

### 🧪 AI Lab (experimental)
- **Food calorie checker:** take a photo of a meal and Gemini Vision
  estimates the calories and macros (protein, carbs, fat, fiber), with a
  confidence level
- Keeps a history of past scans
- When Gemini is busy, the scan retries in the background automatically and
  a progress notification tracks it, so you can keep using the app

### 📱 Home screen widgets & shortcuts
Most check-ins shouldn't need the full app, so Mindfull reaches out onto the
home screen, the lock screen, and the system itself.

**Home screen widgets** (native, not a Flutter view):
- **iOS (SwiftUI + WidgetKit)**
  - *Small:* today's date, journal streak 🔥, and habits done today
  - *Medium:* all of the above, plus up to 3 of today's unfinished tasks;
    tap a task to open it
  - *Lock screen:* a circular gauge of today's habit progress
- **Android (Kotlin + RemoteViews)**
  - *Small (2×2)* and a resizable *Medium (4×2)*
  - Medium lists your habits with **action buttons you can tap right on the
    widget** to log a habit, plus today's tasks, and a ✏️ button that opens
    the quick-add menu
- Widgets refresh whenever the app opens and after every change, and their
  labels follow the app language

**App shortcuts:** long-press the app icon to jump straight to:
- 📓 New journal entry
- ✅ New task
- 💪 New habit
- 💰 Add money
- 📷 Scan food

The titles follow the app language and change as soon as you switch it.

**iOS App Intents: Siri, the Shortcuts app, and Back Tap**
- "Add spending" is a native App Intent, so it shows up in the Shortcuts app
  with no setup
- Say *"Add spending in Mindfull"* to Siri
- Bind it to **Back Tap** (Settings › Accessibility › Touch › Back Tap), then
  triple-tap the back of your phone to log an expense
- Works from a cold start too: the action waits until the app has finished
  launching, then opens the spending sheet

### ✨ Everyday touches
- **Floating island nav bar** with a colored accent for each tab, plus a
  write button: tap it for a quick-add menu, or hold and drag for a radial
  shortcut picker
- **Onboarding** with morphing `CustomPainter` illustrations and looping idle
  animations, built only with Flutter's own animation tools (no third-party
  animation packages)
- **English and Bahasa Indonesia**, switchable in the app; notifications and
  shortcuts switch language too
- **Offline-friendly:** changes are saved on the device first and sync later,
  with a gentle banner if something hasn't synced
- **Optional Google Drive backup** (monthly or on demand) with restore
- Honors the system's reduce-motion setting

---

## Tech highlights

| Area | Choice |
| --- | --- |
| State | Riverpod with code generation (`@riverpod`) |
| Navigation | go_router: a shell route with 6 tabs and auth redirects |
| Backend | Supabase (Postgres with row-level security on every table, Storage for photos) |
| Auth | Google Sign-In, exchanged for a Supabase session |
| Local cache | Hive: saves on the device first, then syncs to Supabase in the background |
| Models | Freezed + json_serializable |
| AI | Google Gemini (`google_generative_ai`) for vision and text |
| Notifications | flutter_local_notifications with action buttons and stable per-item IDs |
| Native | Swift (WidgetKit, App Intents) and Kotlin (RemoteViews home widgets), via `home_widget` + `quick_actions` |
| Localization | gen-l10n ARB files (en, id) |

Some engineering details I'm proud of:
- **Glass UI without jank:** screens are wrapped in `RepaintBoundary` so the
  `BackdropFilter` blur works well on Android.
- **Reliable reminders:** each task or habit keeps its own stored notification
  ID, and reminders are re-checked on every app start, so deleting one item
  never clobbers another's reminder.
- **Gemini errors made useful:** a busy model, a bad API key, a retired model,
  or a hit usage limit each get their own clear message, and only "busy" is
  retried.
- **Native widgets that do things:** Android widget rows use
  fill-in intents on a `PendingIntentTemplate` (the only way list rows in a
  widget can be tapped) to deep-link into the app and log a habit. iOS
  widgets read shared data from an App Group.
- **Intents that survive a cold start:** a `MethodChannel` bridge holds any
  App Intent that fires before Flutter is ready, and delivers it once the
  router reaches a home tab.
- **Tested:** 200+ unit and widget tests.

---

## Running it yourself

Requires Flutter 3.35+ / Dart 3.9+ (the version is pinned with FVM in `.fvm/fvm_config.json`).

1. **Install dependencies**
   ```sh
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Supabase:** create a project, then run the schema SQL from
   [`SPEC.md`](SPEC.md) (the core schema, plus the Money and AI Lab tables).
   Enable the Google auth provider and create a private `photos` storage
   bucket.

3. **Google OAuth:** create Web, Android, and iOS OAuth client IDs (the steps
   are in `lib/core/constants/google_auth_config.dart`).

4. **Secrets:** these files are gitignored, so they are never committed:
   ```sh
   cp .env.example .env                                           # Supabase, Gemini, Google Web client ID
   cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig  # Google iOS client ID
   ```

5. **Run**
   ```sh
   flutter run
   ```

---

## Project docs

- [`SPEC.md`](SPEC.md): the full product and design spec that the app was
  built from
- [`CLAUDE.md`](CLAUDE.md): coding conventions for the repo

## License

[MIT](LICENSE)

---

Made for myself, one mindful day at a time. 🌿
