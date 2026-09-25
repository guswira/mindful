# Mindfull App

A personal productivity app for daily journaling, habit tracking, and task
management. Frosted glass dark theme throughout. Google Sign-In auth.
Supabase primary database. Google Drive optional backup.

---

## Auth

- Sign in with Google (OAuth2) via google_sign_in
- Exchange Google ID token for Supabase session
- Only Supabase session maintained after login
- Drive OAuth in Settings only, never at login

---

## Stack decisions (do not deviate)

- State: Riverpod (code-gen with @riverpod)
- Navigation: go_router with named routes
- Auth: google_sign_in + supabase_flutter
- Backend: Supabase (database + photo storage)
- Drive: googleapis (backup + restore only)
- Local cache: Hive
- Secure storage: flutter_secure_storage
- Models: Freezed + json_serializable
- Notifications: flutter_local_notifications
- Images: image_picker + cached_network_image
- Date/time: intl
- Localization: flutter_localizations + gen-l10n (ARB files), English + Bahasa Indonesia
- Env vars: flutter_dotenv
- Home widget: home_widget
- App shortcuts: quick_actions
- Animations: Flutter built-in only, no third-party animation packages

---

## Theme — Frosted Glass Dark

### Background
Color(0xFF0A1628) deep navy, full screen on all screens.

### Blob background (shared/widgets/blob_background.dart)
Every main screen uses BlobBackground widget — Stack with:
  layer 0: IgnorePointer — 3 positioned blurred circles:
    blob 1: 200×200 Color(0xFF14E6AA) opacity 0.18 blur 60, top:-40 right:-30
    blob 2: 160×160 Color(0xFF378ADD) opacity 0.18 blur 60, bottom:200 left:-40
    blob 3: 120×120 Color(0xFF7C6AF7) opacity 0.12 blur 60, top:280 right:20
  layer 1: child content

### GlassTheme (ThemeExtension — lib/core/theme/glass_theme.dart)

Glass card:
  cardColor:        Color(0x0FFFFFFF)   // rgba(255,255,255,0.06)
  cardBorder:       Color(0x1FFFFFFF)   // rgba(255,255,255,0.12)
  borderRadius:     18px
  blur:             ImageFilter.blur(sigmaX:20, sigmaY:20)

Glass strong:
  strongCardColor:  Color(0x14FFFFFF)   // rgba(255,255,255,0.08)
  strongCardBorder: Color(0x26FFFFFF)   // rgba(255,255,255,0.15)
  blur:             ImageFilter.blur(sigmaX:24, sigmaY:24)

Text:
  textPrimary:      Colors.white
  textSecondary:    Colors.white.withOpacity(0.55)
  textMuted:        Colors.white.withOpacity(0.35)
  textHint:         Colors.white.withOpacity(0.25)

### Feature accent colors (in GlassTheme)

Each feature has its own accent color used for:
active nav icon, active nav dot, pill buttons, progress bars,
checkbox fills, streak numbers, card highlights.

  homeAccent:    Color(0xFFFFFFFF)   white
  taskAccent:    Color(0xFF60A5FA)   blue
  habitAccent:   Color(0xFFA78BFA)  purple
  journalAccent: Color(0xFFFCD34D)  yellow
  writeAccent:   Color(0xFF14E6AA)  teal  ← write button + global success only

Legacy single accents (kept for non-feature use):
  accentTeal:    Color(0xFF14E6AA)
  accentPurple:  Color(0xFF7C6AF7)
  accentAmber:   Color(0xFFF7C46A)
  accentBlue:    Color(0xFF6BB8F0)

### GlassCard widget (shared/widgets/glass_card.dart)
ClipRRect → BackdropFilter → Container (glass bg + border) → child
params: child, strong:bool, borderRadius:double, padding:EdgeInsets, margin:EdgeInsets
Wrap all main screens in RepaintBoundary for Android BackdropFilter compatibility.

### TintedPill widget (shared/widgets/tinted_pill.dart)
params: label:String, color:Color, onTap:VoidCallback?
background: color.withOpacity(0.18)
border: 0.5px color.withOpacity(0.25)
text: color, 13px, weight 600, borderRadius 20

---

## Quotes

Source: https://gist.github.com/nasrulhazim/54b659e43b1035215cd0ba1d4577ee80
Bundled as: assets/quotes.json
Format: { "quotes": [{ "quote": "...", "author": "..." }] }

QuoteService (shared/services/quote_service.dart):
- loadQuotes(): Future<List<Quote>> from rootBundle
- dailyQuote(): quote at index = dayOfYear % quotes.length
  same quote all day, changes at midnight

Display on home screen:
  italic 13px white40, max 2 lines + ellipsis
  "— Author" 12px white30 below
  tap → bottom sheet full quote + author in GlassCard

Quote model (shared/models/quote.dart): { quote:String, author:String }

---

## Data storage strategy

### Primary — Supabase
PostgreSQL, Supabase Storage for photos, RLS on all tables.

### Local — Hive cache
Optimistic writes: Hive first, Supabase async.
Sync on open, skip if last sync < 5 min ago.

### Offline
Failed writes: syncStatus = pending in Hive.
Retry on next open or connectivity restored.
Subtle banner on HomeScreen if pending > 24h:
  "Some data hasn't synced. Tap to retry." → triggers manual sync.

### Backup — Drive (optional)
Monthly auto + on-demand from Settings.
JSON export to /AppFolder/backups/YYYY-MM/
Restore: explicit opt-in, skip-existing conflict rule.

---

## Supabase schema

```sql
create table journal_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  date date not null, title text, body text not null,
  mood text, photo_urls text[],
  sync_status text default 'synced',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create table habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  name text not null, icon text not null, color text not null,
  reminder_days int[], reminder_time time, actions jsonb,
  created_at timestamptz default now(), archived boolean default false
);
create table habit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  habit_id uuid references habits not null,
  date date not null, completed_action_id text, note text,
  sync_status text default 'synced',
  created_at timestamptz default now(),
  unique(habit_id, date)
);
create table tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  name text not null, is_completed boolean default false,
  due_date date, reminder_at timestamptz, checkboxes jsonb,
  sync_status text default 'synced',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
alter table journal_entries enable row level security;
alter table habits enable row level security;
alter table habit_logs enable row level security;
alter table tasks enable row level security;
create policy "own" on journal_entries for all using (auth.uid()=user_id);
create policy "own" on habits for all using (auth.uid()=user_id);
create policy "own" on habit_logs for all using (auth.uid()=user_id);
create policy "own" on tasks for all using (auth.uid()=user_id);
```

---

## Features

### 1. Onboarding (first launch only)

Flag stored in flutter_secure_storage.
SplashScreen: if !hasSeenOnboarding → /onboarding

4 slides, morphing CustomPainter transitions, deep blue background.
1. "Improve day by day" — growth chart illustration
2. "Daily journal" — open book with pen writing (looping idle)
3. "Build habits" — calendar with dots
4. "To-do lists" — checklist with tick animations

Custom pagination indicator: 4 icons 📈 📓 📅 ✅
Active: scale 1.4x + writeAccent underline dot pill
Interpolated from AnimationController.value for fluid mid-swipe feel.

CTA: "Next" slides 1–3, "Let's go! →" slide 4
Slide 4 tap: triggers Google sign-in directly (not navigate to /login)
  loading: CircularProgressIndicator writeAccent
  success: setOnboardingSeen() → /home/today
  fail: SnackBar "Sign-in cancelled. Try again."
  exit animation: content scales down → checklist fills screen → white flash → sign-in

Idle animations per slide (looping, paused during transitions):
  Slide 1 (ChartIdlePainter): bars breathe ±4px, dot bobs up/down
  Slide 2 (BookIdlePainter): pen moves along writing path, ink trail draws/fades
  Slide 3 (CalendarIdlePainter): one dot pulses, checkmark draws/undraws
  Slide 4 (ChecklistIdlePainter): 3rd checkbox tick draws/undraws, 4th row glows

Transition painters (progress: double 0.0→1.0):
  chart_to_book_painter.dart: chart dissolves → book opens → pen draws
  book_to_calendar_painter.dart: book closes → calendar morphs → dots pop
  calendar_to_list_painter.dart: calendar compresses → rows → ticks draw

OnboardingController (ChangeNotifier):
  animationController (600ms, easeInOutCubic) — transition
  idleController (2400ms, repeat reverse) — idle per slide
  goNext() / goBack() — pauses idle, plays transition, resumes idle
  indicatorValue(i): double — smooth interpolation for indicator

Accessibility: if MediaQuery.disableAnimations → skip animations.

---

### 2. Auth

SplashScreen flow:
1. check hasSeenOnboarding() → false → /onboarding
2. check Supabase session → valid → /home/today
3. else → /login

LoginScreen:
  "Sign in with Google" button only, deep blue background matching onboarding.
  Flow: google_sign_in → get idToken → supabase.auth.signInWithIdToken
  Drive NOT connected at login.

---

### 3. Home Screen (default tab)

Background: BlobBackground widget.
Layout: CustomScrollView SliverList, RepaintBoundary wrapper.

TOP BAR (not in a card):
  Row mainAxisAlignment.spaceBetween:
    left Column:
      date: "Monday, October 26" — 13px white45 letterSpacing 0.3
      name: "Good morning, [firstName]" — 26px bold white letterSpacing -0.5
      QuoteWidget (italic, muted, tappable)
    right: Settings button — 38×38 circle GlassCard:
      Icon(Icons.settings_outlined, size:18, white60)
      onTap → context.push('/settings')
      NO settings in bottom nav

STREAK ROW (3 equal flex GlassCards in Row, borderRadius 14, padding 12):
  card 1: journal streak number (writeAccent/teal), "Journal streak" label
  card 2: "X/Y" habits (habitAccent/purple), "Habits today" label
  card 3: tasks due count (taskAccent/blue), "Tasks due" label
  all show 0 / "0/0" / 0 in empty state

TODAY'S TASKS SECTION:
  header: "Today's tasks" 16px white90 + "view all" 13px white35 → /home/tasks
  GlassCard:
    empty: dashed-border container "What needs to be done today?" white25
    with data: up to 3 task rows (checkbox + name + due chip)
    bottom row: + glass icon button left + TintedPill("Add task", taskAccent) right
    "Add task" tap → AddTaskSheet bottom sheet

HABITS SECTION:
  header: "Habits" + "view all" → /home/habits
  empty: GlassCard row — fire icon (habitAccent glass square) +
    "Build your first habit" + TintedPill("Start", habitAccent)
  with data: habit rows with inline action buttons (habitAccent)
  "Start" tap → AddHabitSheet bottom sheet

JOURNAL SECTION:
  header: "Journal" + "view all" → /home/journal
  GlassCard two rows + 0.5px white7 divider:
    row 1: pencil icon (journalAccent glass square) +
           "Write today's plan" / "Outline your goals..." +
           TintedPill("Start", journalAccent)
           tap → AddJournalSheet bottom sheet
    row 2: book icon (habitAccent glass square) +
           "Review what happened" / "Reflect on your day..." +
           TintedPill("Reflect", taskAccent)
           tap → AddJournalSheet bottom sheet

UNSYNCED BANNER (AnimatedSwitcher, only when pending > 24h):
  subtle glass strip: "Some data hasn't synced. Tap to retry."
  tap → sync_service.retryPending()

---

### 4. Floating Island Nav Bar (shared/widgets/floating_nav_bar.dart)

REPLACES standard BottomNavigationBar entirely.
Positioned at bottom of shell route Scaffold via Stack.

Layout — SafeArea → Padding(bottom:12, horizontal:14):
Row:
  LEFT — glass island (flex:1):
    background: rgba(255,255,255,0.09)
    border: 0.5px rgba(255,255,255,0.18)
    borderRadius: 28px  ← more rounded
    padding: EdgeInsets.symmetric(horizontal:10, vertical:13)
    BackdropFilter blur(24)
    Row 4 _NavItem widgets (equal flex)

  SizedBox(width:10)

  RIGHT — write button (52×52):
    borderRadius: 22px
    gradient: LinearGradient writeAccent → Color(0xFF0EB8DF)
    boxShadow: writeAccent.withOpacity(0.30) blurRadius 20 offset (0,4)
    Icon(Icons.edit_outlined, color:Color(0xFF0A1628), size:22)
    onTap: showModalBottomSheet write options
    onLongPress: show radial arc overlay

_NavItem widget:
  Column: icon (22px) + AnimatedContainer dot
  NO text labels — icon + dot only
  active icon color (per tab):
    index 0 Home:    homeAccent    Color(0xFFFFFFFF) white
    index 1 Tasks:   taskAccent    Color(0xFF60A5FA) blue
    index 2 Habits:  habitAccent   Color(0xFFA78BFA) purple
    index 3 Journal: journalAccent Color(0xFFFCD34D) yellow
  inactive icon: Colors.white.withOpacity(0.28)
  active dot: AnimatedContainer width 16, height 4, borderRadius 2,
              color = tab accent color
  inactive dot: width 4, transparent

4 tab icons (outline style):
  Home:    Icons.home_outlined
  Tasks:   Icons.checklist_outlined
  Habits:  Icons.calendar_month_outlined
  Journal: Icons.menu_book_outlined

Shell Scaffold body: Stack [ child, Positioned bottom:0 FloatingNavBar ]
All tab screens: add bottom padding ≥ 88px so content clears the nav.

Write button tap → showModalBottomSheet (glass):
  ListTile "📓 Write journal" → AddJournalSheet()
  ListTile "✅ Add task" → AddTaskSheet()
  ListTile "💪 Add habit" → AddHabitSheet()

Write button long press → radial arc overlay:
  drag left → AddJournalSheet
  drag up → AddTaskSheet
  drag right → AddHabitSheet

---

### 5. Journal Editor Screen (keyboard-aware, full page for edit)

Route: /journal/:id/edit only (new entries use AddJournalSheet)

Scaffold resizeToAvoidBottomInset: true
AppBar: back arrow, date title, "⋯" more button (edit mode: delete via sheet)

Body Column:
  Expanded SingleChildScrollView:
    title TextField (optional, 20px white, no border)
    body TextField (required, autofocus:TRUE, 16px white80,
                    no border, maxLines:null)
    photo strip (horizontal, 80×80 thumbnails + add button)
    SizedBox(200) breathing room

  _MoodRow (sticky, outside scroll):
    GlassCard padding 8 12 margin 12 4 borderRadius 14
    5 emoji buttons: 😊 😐 😢 😰 🤩
    selected: AnimatedScale 1.3x + journalAccent underline dot
    unselected: opacity 0.4

  _ActionBar (sticky, outside scroll):
    GlassCard padding 8 12 margin 12 0 borderRadius 14
    Row: photo IconButton left + TintedPill("Save", journalAccent) right

  SizedBox height = viewInsets.bottom == 0 ? padding.bottom : 0

---

### 6. Add Sheets (bottom sheet style — NOT full page navigation)

All "add" and "detail" actions use showModalBottomSheet:
  isScrollControlled: true
  backgroundColor: Colors.transparent
  shape: RoundedRectangleBorder top radius 28
  content: GlassCard strong:true borderRadius 28
  drag handle: 40×4 pill white30 centered at top

#### AddJournalSheet (lib/features/journal/presentation/add_journal_sheet.dart)
Title: "What's going on"
  body TextField autofocus:TRUE, 4+ lines, no border, white80
  _MoodRow (same as editor, journalAccent)
  Row: photo button left + TintedPill("Save entry", journalAccent) right
  Padding bottom: MediaQuery.viewInsets.bottom (rides keyboard)
  save: create JournalEntry → journal_repository → pop

#### AddTaskSheet (lib/features/tasks/presentation/add_task_sheet.dart)
Title: "What to do"
  task name TextField autofocus:TRUE, taskAccent cursor
  due date row: icon + "Add due date" + date picker on tap
  reminder row: icon + "Add reminder" (enabled only if due date set,
                defaults to 9:00 AM on due date)
  subtasks toggle: Switch (taskAccent) → animated list of subtask TextFields
  TintedPill("Add task", taskAccent) full width at bottom
  empty name → shake animation (ShakeWidget)

#### AddHabitSheet (lib/features/habits/presentation/add_habit_sheet.dart)
Title: "Build new habit"
  name TextField autofocus:TRUE, 18px bold, habitAccent cursor
  emoji icon grid (20 options, selected: habitAccent border + corner dot)
  color swatches row (7 colors, selected: scale 1.2 + white ring)
  reminder toggle + day chips (Mon–Sun multi-select, habitAccent active)
  + time picker when enabled
  custom actions list (add/remove/rename)
  TintedPill(edit?"Save changes":"Add habit", habitAccent) full width
  empty name → shake animation

#### TaskDetailSheet (lib/features/tasks/presentation/task_detail_sheet.dart)
Shows task name, due date, reminder.
Subtask checkboxes with taskAccent fill when checked.
LinearProgressIndicator taskAccent.
"⋯" more → nested sheet: Edit (AddTaskSheet pre-filled) / Delete (confirm).
TintedPill("Mark as done", taskAccent) if not completed.

#### JournalDetailSheet (lib/features/journal/presentation/journal_detail_sheet.dart)
Shows date, mood emoji, title, full body (scrollable).
Photo thumbnails horizontal scroll → tap for full screen.
"⋯" more → Edit (push /journal/:id/edit) / Delete (confirm).

---

### 7. Daily Journal Tab (/home/journal)

List entries grouped by month, newest first.
GlassCard per entry: date, mood emoji, first line, photo thumbnail,
unsynced dot if pending. journalAccent highlights.
Search bar (glass input) at top.
Tap card → JournalDetailSheet.

---

### 8. Habit Tracker (/home/habits)

HabitTab: today's habits, glass rows.
  each row: icon, name, action buttons (habitAccent), done checkmark
  long press → sheet: Edit / Archive / Delete
  "Add habit" → AddHabitSheet

HabitDetailScreen (/habits/:id — full page):
  monthly calendar, habitAccent dots, streak count, swipe months.

AddHabitSheet / edit: uses bottom sheet (see Add Sheets above).

Notifications: per-habit, habitAccent action buttons, fires on selected days.

---

### 9. Task Manager (/home/tasks)

TaskTab: grouped Today / Upcoming / No date / Completed (collapsed).
  glass rows: checkbox (taskAccent fill when checked) + name + due chip
  tap row → TaskDetailSheet
  long press → sheet: Edit / Delete
  "Add task" → AddTaskSheet

Notifications: per-task at reminderAt, "Mark done" action button (taskAccent).

---

### 10. Settings (/settings — accessed from home top-right gear icon)

Opened via settings gear button top-right of HomeScreen.
NOT in bottom nav.

Language: "System default (<device language>)" / English / Bahasa Indonesia
  picker (see Localization). Default follows the device language.
Drive Backup: connect/disconnect, last backup date, pending count,
  back up now, auto-backup toggle.
Drive Restore (Drive connected): import from Drive, month picker,
  preview, warning dialog, skip-existing import.
Notifications: journal 8am toggle, journal 10pm toggle.
Account: Google photo + name + email, sign out.
Debug (kDebugMode only): "Reset onboarding" → clearOnboardingSeen().
  "Schedule test notification (5 min)" (lib/features/settings/presentation/
  debug_section.dart) → NotificationService.scheduleTestNotification():
  fires a real, standalone scheduled notification (id 9001) 5 minutes out,
  in the same exact/inexact mode a real reminder would use — for telling
  apart an app scheduling bug from an OS/device-level restriction
  (notification permission, a muted/sticky notification channel, OEM
  battery/autostart limits, Do Not Disturb, ...) when a real task/habit
  reminder doesn't show. SnackBar confirms the exact time it's scheduled
  for.

---

### 11. App Shortcuts (quick_actions)

Shortcut titles are localized (see Localization) and re-set whenever the
app language changes.

Long-press app icon:
  📓 New Journal Entry → opens AddJournalSheet
  ✅ New Task → opens AddTaskSheet
  💪 New Habit → opens AddHabitSheet

---

### 11b. iOS App Intents — Back Tap / Shortcuts / Siri

iOS doesn't let apps detect Back Tap directly; Settings > Accessibility >
Touch > Back Tap can only run a system action or a Shortcut. So the app
exposes an App Intent, and the user binds it to Double/Triple Tap.

ios/Runner/AppDelegate.swift (iOS 16+):
  AddSpendingIntent — "Add spending", openAppWhenRun
  MindfullShortcuts (AppShortcutsProvider) — lists it in Shortcuts with no
    user setup; Siri phrases "Add/Log spending in Mindfull"
  AppActionBridge — MethodChannel `mindfull/app_actions`:
    native → Dart: `action` (arg: action id, e.g. 'addSpending')
    Dart → native: `takePendingAction` — collects an action that fired
      before Dart registered its handler (cold start from Back Tap)

lib/core/router/app_intent_actions.dart — listenForAppIntentActions(router),
  called from main() next to quick_actions:
  'addSpending' → openAddMoneySheet (AddMoneySheet, Spending selected)
  waits until the router is on a /home tab first — a cold start lands on
  splash/login, and a sheet opened there would be torn down by the
  redirect

User setup: Settings > Accessibility > Touch > Back Tap > Triple Tap >
  "Add spending" (under Shortcuts; if it isn't listed, add it from the
  Mindfull section of the Shortcuts app first).

Intent titles/phrases are native (English only), like the home widgets'
labels — out of scope for the Dart ARB files.



widget_service.dart updates on every app open and after any write.

Small 2×2: date, journal streak (teal), habits X/Y (habitAccent)
Medium 4×2: above + up to 3 incomplete tasks due today
iOS lock screen: circular habit count (habitAccent)

---

## Localization

Supported languages: English (`en`, fallback) and Bahasa Indonesia (`id`)
only. Every user-facing copy string — screens, sheets, dialogs, SnackBars,
tooltips/semantics labels, notification titles/bodies/actions/channel
names, app shortcut titles, AI error messages — comes from the ARB files;
no hardcoded copy in Dart.

Setup:
  l10n.yaml → gen-l10n, arb-dir lib/l10n, output lib/l10n/generated
  lib/l10n/app_en.arb (template) + lib/l10n/app_id.arb
  MaterialApp: AppLocalizations.localizationsDelegates/supportedLocales
    (includes GlobalMaterialLocalizations, so date pickers etc. follow too)

lib/core/l10n/:
  app_language.dart — AppLanguage enum { system, english, bahasa },
    resolveAppLocale(): matches by language code, falls back to English
    (a device in any other language gets English)
  app_language_controller.dart — AppLanguageController (@riverpod,
    keepAlive): restore() in main() before runApp (no flash of the wrong
    language), select() persists + switches instantly
  l10n.dart — `context.l10n` in widgets; `currentL10n` for code with no
    BuildContext (NotificationService, GeminiService, quick actions).
    setCurrentAppLocale() also sets Intl.defaultLocale so every DateFormat /
    NumberFormat follows the app language.

Persistence: flutter_secure_storage key `app_language`
  ('system' | 'english' | 'bahasa'), via SettingsRepository. Unset → system.

Default: follow the device language (locale: null on MaterialApp);
Settings can override it. Changing it:
  - rebuilds the UI immediately
  - re-sets quick action titles
  - re-schedules journal/habit/task reminders and the budget reset
    reminder, so already-scheduled notifications use the new language

Not translated (data, not copy): user content, quotes.json, persisted
values (money categories are stored in English and mapped to a label at
display time; mood values; habit action names the user typed), currency
codes, debug logs.

Bahasa style: casual "kamu" tone. Glossary: Tugas, Kebiasaan, Jurnal,
Keuangan, Anggaran, Pengeluaran, Pemasukan, Runtutan (streak), Pengaturan,
Pengingat, Lab AI.

Native home/lock screen widgets render their own labels in Kotlin/Swift
and are out of scope for the Dart ARB files.

---

## Navigation (go_router)

```
/splash            → SplashScreen
/onboarding        → OnboardingScreen  (no auth redirect)
/login             → LoginScreen
/home              → HomeScreen shell (FloatingNavBar, 4 tabs)
  /home/today      → HomeTab  (default)
  /home/tasks      → TaskTab
  /home/habits     → HabitTab
  /home/journal    → JournalTab
/journal/:id/edit  → JournalEditorScreen  (edit only, full page)
/habits/:id        → HabitDetailScreen    (calendar, full page)
/settings          → SettingsScreen
```

REMOVED routes (replaced by bottom sheets):
  /journal/new, /journal/:id, /habits/new, /habits/:id/edit,
  /tasks/new, /tasks/:id, /tasks/:id/edit

Redirects:
  unauthenticated → /login (except /onboarding)
  authenticated on /login or /splash → /home/today

---

## UI conventions

- Floating island nav bar — 4 tabs, NO profile tab, NO labels
- Settings accessed via gear icon top-right of HomeScreen only
- Each tab has its own accent color (see Feature accent colors)
- Write button bottom-right of nav row — always teal gradient
- All add actions → bottom sheet (NOT full page navigation)
- Detail views → bottom sheet (NOT full page, except habit calendar)
- Primary actions always at bottom of sheet/screen
- NEVER put primary actions in AppBar
- Destructive actions in nested bottom sheet or AlertDialog only
- Journal editor (edit mode): sticky mood + action bar above keyboard
- Autofocus first TextField on every add sheet
- GlassCard for all content cards throughout app
- BlobBackground on all main screens
- RepaintBoundary wrapping all screens (Android BackdropFilter fix)
- Unsynced dot: small subtle, never disruptive
- Write button long press: radial arc overlay for quick access
- ShakeWidget on empty required field submit attempt

---

## Folder structure

```
assets/
  quotes.json

lib/
├── main.dart
├── app.dart
├── l10n/
│   ├── app_en.arb
│   ├── app_id.arb
│   └── generated/          ← gen-l10n output, never edit
├── core/
│   ├── constants/supabase_constants.dart
│   ├── extensions/
│   ├── l10n/
│   │   ├── app_language.dart
│   │   ├── app_language_controller.dart
│   │   └── l10n.dart
│   ├── router/router.dart
│   └── theme/
│       ├── app_theme.dart
│       └── glass_theme.dart
├── features/
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── onboarding_screen.dart
│   │       ├── onboarding_controller.dart
│   │       └── painters/
│   │           ├── chart_to_book_painter.dart
│   │           ├── book_to_calendar_painter.dart
│   │           ├── calendar_to_list_painter.dart
│   │           ├── chart_idle_painter.dart
│   │           ├── book_idle_painter.dart
│   │           ├── calendar_idle_painter.dart
│   │           └── checklist_idle_painter.dart
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── domain/auth_state.dart
│   │   └── presentation/
│   │       ├── splash_screen.dart
│   │       └── login_screen.dart
│   ├── home/
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       └── widgets/
│   │           ├── greeting_header.dart    ← includes settings gear
│   │           ├── quote_widget.dart
│   │           ├── streak_row.dart
│   │           ├── today_tasks_strip.dart
│   │           ├── upcoming_habits_strip.dart
│   │           └── journal_section.dart
│   ├── journal/
│   │   ├── data/
│   │   │   ├── journal_repository.dart
│   │   │   └── supabase_journal_datasource.dart
│   │   ├── domain/journal_entry.dart
│   │   └── presentation/
│   │       ├── journal_tab.dart
│   │       ├── journal_detail_sheet.dart   ← bottom sheet
│   │       ├── add_journal_sheet.dart      ← bottom sheet
│   │       └── journal_editor_screen.dart  ← full page edit only
│   ├── habits/
│   │   ├── data/
│   │   │   ├── habit_repository.dart
│   │   │   └── supabase_habit_datasource.dart
│   │   ├── domain/
│   │   │   ├── habit.dart
│   │   │   ├── habit_action.dart
│   │   │   └── habit_log.dart
│   │   └── presentation/
│   │       ├── habit_tab.dart
│   │       ├── habit_detail_screen.dart    ← full page calendar
│   │       └── add_habit_sheet.dart        ← bottom sheet add + edit
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── task_repository.dart
│   │   │   └── supabase_task_datasource.dart
│   │   ├── domain/
│   │   │   ├── task.dart
│   │   │   └── task_checkbox.dart
│   │   └── presentation/
│   │       ├── task_tab.dart
│   │       ├── task_detail_sheet.dart      ← bottom sheet
│   │       └── add_task_sheet.dart         ← bottom sheet
│   └── settings/
│       └── presentation/settings_screen.dart
└── shared/
    ├── widgets/
    │   ├── glass_card.dart
    │   ├── blob_background.dart
    │   ├── tinted_pill.dart
    │   ├── unsynced_badge.dart
    │   ├── floating_nav_bar.dart    ← island nav + write button
    │   └── shake_widget.dart        ← invalid field animation
    ├── services/
    │   ├── notification_service.dart
    │   ├── supabase_service.dart
    │   ├── drive_service.dart
    │   ├── sync_service.dart
    │   ├── storage_service.dart
    │   ├── quote_service.dart
    │   └── widget_service.dart
    └── models/
        ├── sync_status.dart
        └── quote.dart
```

---

## Notification icons (Android)
- Small (status bar): `@drawable/ic_stat_notification` — white-on-transparent
  silhouette of the app icon, set once in AndroidInitializationSettings.
  Never `@mipmap/ic_launcher`: Android draws small icons from alpha only,
  so the opaque launcher icon shows as a solid white blob.
- Large (inside the notification): `@drawable-nodpi/ic_notification_large`
  — the full-colour app icon, on every AndroidNotificationDetails.
- Both listed in res/raw/keep.xml so release resource shrinking keeps them
  (the plugin looks them up by name).
- If assets/icon/app_icon.png changes, regenerate both.
- iOS uses the app icon automatically.

## Notification IDs
- 1001 journal 8am, 1002 journal 10pm
- 4001 budget reset, 4002 food scan, 4003 money AI advice
- 2000–2999 habit (7 ids per habit, one per weekday)
- 3000–3999 task (1 id per task)
- 9001 Settings debug screen's test notification (see Settings section)

Habit/task ids are assigned per-item, not by a habit/task's position in its
list — a stable id (persisted in a Hive-backed
`NotificationIdAllocator`/`shared/services/notification_id_allocator.dart`)
is allocated the first time a given habit/task id is scheduled, and freed
only when that habit/task is permanently deleted (`forgetHabitReminder`/
`forgetTaskReminder`; merely completing, archiving, or editing one keeps
its id via `cancelHabitReminder`/`cancelTaskReminder`). Deriving the id
from list position instead (`2000 + index`) let deleting one item shift
every later item's index, which could silently overwrite or orphan a
different, still-pending item's reminder — this is why that scheme was
replaced.

Habit/task reminders are also reconciled on every app start (see
`taskRemindersProvider`/`habitRemindersProvider`, read from router.dart
alongside `journalRemindersProvider`) — otherwise they're only ever
(re)scheduled once, when their Add/Edit sheet is saved, and never come
back if the OS ever drops the alarm (app force-stopped, an OEM battery
manager, ...).

---

## Supabase setup
1. supabase.com → new project
2. Run schema SQL above in SQL editor
3. Auth → Providers → Google (enable, add client ID + secret)
4. Storage bucket `photos` — private, RLS enabled
5. .env (never commit, template in .env.example): SUPABASE_URL, SUPABASE_ANON_KEY,
   GEMINI_API_KEY, GOOGLE_SERVER_CLIENT_ID
6. ios/Flutter/Secrets.xcconfig (never commit, template in
   Secrets.xcconfig.example): GOOGLE_IOS_CLIENT_ID + its reversed form,
   substituted into Info.plist (GIDClientID, CFBundleURLSchemes)

## pubspec assets
```yaml
flutter:
  assets:
    - .env
    - assets/quotes.json
```

---

## What this app is NOT
- No custom backend — Supabase only
- No Firebase
- No Apple Sign-In v1
- No conflict resolution beyond skip-existing on restore
- No offline-first guarantee (Hive cache is best-effort)
- No iPad layout v1
- No third-party animation packages — Flutter built-in only
- No profile tab in nav — settings accessed via home gear icon only


---

## 13. Money Flow Feature

A lightweight personal finance tracker integrated into the app.
Feature accent color: moneyAccent: Color(0xFF34D399) — emerald green.
Add moneyAccent to GlassTheme.

### Supabase schema

```sql
create table budget_settings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null unique,
  budget_type text not null default 'monthly', -- 'monthly' | 'daily'
  amount numeric(12,2) not null default 0,
  currency text not null default 'USD',
  updated_at timestamptz default now()
);

create table money_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  type text not null, -- 'spending' | 'income'
  amount numeric(12,2) not null,
  category text not null,
  note text,
  date date not null default current_date,
  sync_status text default 'synced',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table budget_settings enable row level security;
alter table money_entries enable row level security;
create policy "own" on budget_settings for all using (auth.uid()=user_id);
create policy "own" on money_entries for all using (auth.uid()=user_id);
```

### Data models (Dart)

BudgetSettings (Freezed):
- id: String
- userId: String
- budgetType: BudgetType (monthly | daily)
- amount: double
- currency: String
- updatedAt: DateTime

MoneyEntry (Freezed):
- id: String (UUID)
- userId: String
- type: EntryType (spending | income)
- amount: double
- category: String
- note: String?
- date: DateTime (date only)
- syncStatus: SyncStatus
- createdAt: DateTime
- updatedAt: DateTime

BudgetType enum: monthly, daily
EntryType enum: spending, income

Spending categories:
  Food, Transport, Shopping, Health, Entertainment,
  Bills, Education, Travel, Other

Income categories:
  Salary, Freelance, Investment, Gift, Other

### Money Flow Tab (/home/money)

Add to floating nav bar as 5th tab:
  index 4 Money: Icons.account_balance_wallet_outlined
  activeColor: moneyAccent Color(0xFF34D399) emerald green

Update shell route to 5 tabs:
  /home/today, /home/tasks, /home/habits, /home/journal, /home/money

MoneyTab layout (BlobBackground, CustomScrollView):

BUDGET CARD (GlassCard strong, top):
  Row:
    Column left:
      Text "Budget" 12px white45
      Text formatted amount + currency 28px bold white
      Text budget type "per month" or "per day" 12px white35
    Column right:
      CircularProgressIndicator style gauge:
        progress: spent / budget (capped at 1.0)
        color: moneyAccent if < 80%, amberAccent if 80–99%,
               red if >= 100%
        size: 64px
        center text: remaining % or "Over"
  below: Row 3 mini stats:
    "Spent" — total spending this period (red tinted)
    "Income" — total income this period (moneyAccent tinted)
    "Remaining" — budget - spent + income (white or red if negative)
  settings icon top-right → opens BudgetSettingsSheet

REMAINING BUDGET INDICATOR (between budget card and list):
  if remaining > 0:
    Text "You have [currency][amount] left" moneyAccent 14px
  if remaining <= 0:
    Text "Over budget by [currency][amount]" red 14px
  Text "as of today" white35 12px

PERIOD SELECTOR (glass pill toggle):
  Today | This Week | This Month | All
  selected pill: moneyAccent tinted
  filters the entry list below

ADD BUTTONS ROW:
  Row:
    TintedPill("+ Spending", Colors.redAccent) flex 1
      onTap → AddMoneySheet(defaultType: spending)
    SizedBox 8
    TintedPill("+ Income", moneyAccent) flex 1
      onTap → AddMoneySheet(defaultType: income)

ENTRY LIST (grouped by date, newest first):
  date header: Text "Today" / "Yesterday" / "Mon, Oct 26" white45 12px
  each entry GlassCard:
    Row:
      category icon circle (36px):
        spending: red tinted glass + category emoji
        income: moneyAccent tinted glass + category emoji
      Column flex:
        Text category 14px white85 bold
        Text note 12px white45 if exists
        Text date 11px white30
      Column right:
        Text amount:
          spending: "- [currency][amount]" red
          income: "+ [currency][amount]" moneyAccent
        unsynced dot if pending
    tap → MoneyEntryDetailSheet
    long press → sheet: Edit / Delete

RECAP SECTION (below list, collapsible):
  ExpansionTile "Recap" glass style:
    spending by category: horizontal bar chart (CustomPaint)
      each category bar: category name + amount + % of total spending
      bar color: red opacity proportional
    income vs spending summary:
      two rows: income total (moneyAccent) vs spending total (red)
      net: income - spending, color based on positive/negative
    top spending category highlighted
    AI advice button (bottom of the recap, only if any entry exists):
      TintedPill("✨ AI advice", aiAccent) → MoneyAdviceSheet (see AI Advice)

### AI Advice (MoneyAdviceSheet)

lib/features/money/presentation/money_advice_sheet.dart
Opened from the Recap section's "✨ AI advice" pill. Experimental, uses
the same Gemini setup as AI Lab (see AI Lab Feature GeminiService).

Data sent (money_advice_summary.dart — buildMoneyAdviceSummary):
  ALL money entries (all-time, not just the recap's month) + currency:
    total spending / income, spending and income per category (largest
    first), per-month spending / income, and the newest 200 individual
    entries (date, type, category, amount, note).
  Categories stay in their stored English names; numbers/dates are fixed
  format (not the app locale) so Gemini always reads the same shape.

Language: the prompt itself is the ARB string `moneyAdvicePrompt({data})`
  (app_en.arb / app_id.arb), read via currentL10n — so the prompt is in the
  user's app language and tells Gemini to reply in it (Bahasa: casual
  "kamu"). JSON key names stay English in both.

GeminiService.adviseOnMoney(String summary): Future<MoneyAdvice>
  text-only request, same 30s timeout + error classification as
  analyzeFood (throws FoodScanException with a localized message).
  Response JSON → MoneyAdvice (Freezed, transient, not stored —
  lib/features/money/domain/money_advice.dart):
    summary: String                 — 2–3 sentence overview
    spendingInsights: List<String>  — 2–4, where most spending goes
    savingTips: List<String>        — 3–5, how to save / optimize

Flow — requestMoneyAdvice (money_advice_flow.dart), same retry +
notification mechanism as the food scan (see AI Lab Food Scan Flow):
  0. no entries → SnackBar "Add some spending or income first...", stop
     already running (still retrying in the background) → SnackBar
       "Still working on your advice...", stop — one run at a time, since
       they'd share the same notification id
  1. show MoneyAdviceLoadingSheet (non-dismissible): title row
     Icon(auto_awesome_outlined, aiAccent) + "AI spending advice",
     CircularProgressIndicator aiAccent + "Looking at your spending..."
  2. show progress notification (id 4003, see Notification IDs below)
  3. GeminiService.adviseOnMoney via runWithRetry (food_scan_retry.dart,
     generic, shared with the food scan):
       busy → wait 1 minute and retry, up to 5 attempts total; each retry
         updates the notification "attempt N/5"
       on the first retry: dismiss the loading sheet — the notification
         carries progress from here
       any other error, or still busy after 5 attempts → final failure
  4. success: cancel the notification, show MoneyAdviceSheet(advice):
       title row, "Overview" summary, "Where your money goes" bullets
       (moneySpending), "How to save" bullets (moneyAccent), footer
       "⚠ Experimental AI advice... not financial advice." white30 11px
     final failure: cancel the notification; if the sheet was already
       dismissed for a retry, also show a failure notification (id 4003)
       with a "Retry" action — it and the body reopen /home/money (the user
       taps "AI advice" again); SnackBar with the classified message
  Holds the root NavigatorState / ScaffoldMessenger / ProviderContainer
  rather than the button's context, since retries can outlive it.

Notification ID: 4003 — money advice progress/failure. Own id + channels
  ("AI advice progress" / "AI advice result"), so it never replaces a
  running food scan's 4002. Payload 'money_advice' → /home/money.

### Add Money Sheet (AddMoneySheet)

lib/features/money/presentation/add_money_sheet.dart

title row:
  segmented toggle: [ Spending | Income ]
  default: spending (red tinted active) or income (moneyAccent active)
  can be passed via defaultType param

amount field:
  large centered TextField
  prefix: currency symbol 24px white45
  amount: 32px bold white, keyboard: numberWithOptions(decimal:true)
  autofocus: TRUE
  no border, hint "0.00"

category picker:
  Wrap of category chips (glass pills)
  selected: moneyAccent or red tint + border
  categories change based on spending/income toggle
  first category auto-selected on type change

note field:
  TextField hint "Add a note..." 14px white60 no border

date row:
  Icon calendar + formatted date (defaults today)
  tap → showDatePicker

save button:
  TintedPill("Save", moneyAccent) full width
  empty amount → ShakeWidget on amount field

edit mode: pre-fills all fields, title "Edit entry"

### Money Entry Detail Sheet

lib/features/money/presentation/money_detail_sheet.dart

shows: type badge, amount large, category, note, date
"⋯" more → Edit (AddMoneySheet pre-filled) / Delete confirm
no primary action button (read-only detail)

### Budget Settings Sheet

lib/features/money/presentation/budget_settings_sheet.dart

title: "Budget settings"

budget type toggle: [ Monthly | Daily ] glass segmented
amount field: large currency + amount input (autofocus)
currency selector: text button showing current currency
  tap → bottom picker with common currencies:
  USD, EUR, GBP, SGD, IDR, MYR, THB, JPY, AUD, CAD

TintedPill("Save settings", moneyAccent) full width
on save: upsert budget_settings in Supabase

### Home Screen — Money Flow integration

REMAINING BUDGET WIDGET (after streak row, before tasks):
  GlassCard compact (padding 12 16):
  Row:
    Column:
      Text "Remaining budget" 12px white45
      Text "[currency][amount]" 20px bold:
        moneyAccent if positive, red if negative or zero
      Text "of [budget] [per month/day]" 11px white30
    Spacer
    Column right:
      mini circular progress 48px same colors as MoneyTab gauge
      Text percentage 10px below

  tap → context.go('/home/money')
  only shown if budget has been configured (amount > 0)

### Write menu — Money Flow addition

Update write button bottom sheet and radial arc:

showModalBottomSheet write options (4 items now):
  📓 Write journal → AddJournalSheet
  ✅ Add task → AddTaskSheet
  💪 Add habit → AddHabitSheet
  💰 Add money → AddMoneySheet(defaultType: spending)

Radial arc (hold+drag) directions update:
  LEFT → AddJournalSheet
  UP-LEFT → AddTaskSheet
  UP-RIGHT → AddHabitSheet
  RIGHT → AddMoneySheet(defaultType: spending)

App shortcuts (quick_actions) — add:
  💰 Add Money → AddMoneySheet(defaultType: spending)

### Folder structure additions

```
lib/features/money/
  data/
    money_repository.dart
    supabase_money_datasource.dart
  domain/
    money_entry.dart
    budget_settings.dart
    budget_type.dart
    entry_type.dart
    money_advice.dart
  presentation/
    money_tab.dart
    add_money_sheet.dart
    money_detail_sheet.dart
    budget_settings_sheet.dart
    money_advice_sheet.dart     ← AI advice loading + result sheets
    money_advice_flow.dart      ← retry + notification orchestration
    money_advice_summary.dart   ← entries → prompt data
    widgets/
      budget_card.dart          ← gauge + stats
      entry_list.dart           ← grouped by date
      recap_section.dart        ← bar chart + summary
      remaining_budget_widget.dart ← home screen card
```

### GlassTheme additions

Add to glass_theme.dart:
  moneyAccent: Color(0xFF34D399)   emerald green
  moneySpending: Color(0xFFFC8181) soft red (spending)

### Notification IDs addition

- 4001 — monthly budget reset reminder (1st of month)
- 4003 — money AI advice progress/failure (see AI Advice)
  "New month, new budget. Your budget has reset."

### What Money Flow is NOT

- No bank integration or open banking
- No recurring transaction tracking in v1
- No multi-currency conversion (display only)
- No budget per category in v1
- No export to CSV in v1
- No shared/family budget in v1
- AI advice is not financial advice, and is never stored


---

## 14. AI Lab Feature (Experimental)

An experimental AI-powered section using Google Gemini Vision API.
Clearly marked as experimental throughout the UI.
Feature accent color: aiAccent: Color(0xFF818CF8) — indigo/violet.
Add aiAccent to GlassTheme.

### Gemini API setup

- Package: google_generative_ai (latest)
- Model: gemini-3.8-flash (fast, cheap, good vision — gemini-1.5-flash was
  retired and now 404s on every request; re-check ai.google.dev/gemini-api/docs/models
  if this one is later deprecated too)
- API key stored in .env as GEMINI_API_KEY
- Never hardcode the key anywhere
- Add GEMINI_API_KEY to .env and .gitignore

### Supabase schema

```sql
create table food_scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  food_name text,
  calories int,
  protein numeric(6,1),
  carbs numeric(6,1),
  fat numeric(6,1),
  fiber numeric(6,1),
  confidence text,
  note text,
  raw_response text,
  scanned_at timestamptz default now()
);

alter table food_scans enable row level security;

create policy "users own food scans"
  on food_scans for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
```

### Data models (Dart)

FoodAnalysis (Freezed, not stored — transient result):
- foodName: String
- calories: int
- protein: double
- carbs: double
- fat: double
- fiber: double
- confidence: String  ('high' | 'medium' | 'low')
- servingNote: String?
- healthNote: String?
- ingredients: List<String>

FoodScan (Freezed, stored in Supabase):
- id: String
- userId: String
- foodName: String?
- calories: int?
- protein: double?
- carbs: double?
- fat: double?
- fiber: double?
- confidence: String?
- note: String?
- scannedAt: DateTime

### GeminiService (shared/services/gemini_service.dart)

class GeminiService:
  late GenerativeModel _model
  init from dotenv GEMINI_API_KEY, model: 'gemini-3.8-flash'

  Future<FoodAnalysis?> analyzeFood(File compressedImage):
    bytes = await compressedImage.readAsBytes()
    prompt = TextPart with this exact text:
      "You are a nutrition expert. Analyze this food image carefully.
       Respond with a single JSON object only — no markdown, no explanation.
       Use this exact structure:
       {
         \"foodName\": \"name of the food or dish\",
         \"calories\": estimated_integer,
         \"protein\": grams_as_decimal,
         \"carbs\": grams_as_decimal,
         \"fat\": grams_as_decimal,
         \"fiber\": grams_as_decimal,
         \"confidence\": \"high\" or \"medium\" or \"low\",
         \"servingNote\": \"description of assumed serving size\",
         \"healthNote\": \"one sentence health insight\",
         \"ingredients\": [\"main ingredient 1\", \"main ingredient 2\"]
       }
       If the image is not food, respond with exactly: null"
    image = DataPart('image/jpeg', bytes)
    response = await _model.generateContent([Content.multi([prompt, image])])
    text = response.text?.trim()
    if text == null or text == 'null': return null
    try: return FoodAnalysis.fromJson(jsonDecode(text))
    catch: return null

  handle errors (GeminiService._classifyApiError):
    GenerativeAIException → classified into (FoodScanErrorType, message) —
    the SDK only ever exposes a raw message string, so the specific cause
    is read out of it:
      InvalidApiKey → apiError,
        "Invalid Gemini API key. Check GEMINI_API_KEY in .env."
      message contains 'UNAVAILABLE' or 'high demand' → busy,
        "Google's AI service is busy right now. Try again in a moment."
      message contains 'RESOURCE_EXHAUSTED' or 'quota' → busy,
        "You've hit the AI usage limit. Try again later."
      message contains 'NOT_FOUND' → apiError,
        "AI model unavailable. The app may need updating."
      message contains 'PERMISSION_DENIED' → apiError,
        "AI access denied. Check your API key's permissions."
      else → apiError, "AI service error. Try again later."
    timeout after 30 seconds → FoodScanErrorType.timeout
    SocketException (no connection) → FoodScanErrorType.networkError
    the raw exception is always debugPrint'd — the UI never shows it
    directly, only the classified message above

ImageCompressionService (shared/services/image_compression_service.dart):
  Future<File> compress(File original):
    use flutter_image_compress package
    output path: path_provider's getTemporaryDirectory()
    target: quality 75, minWidth 1024, minHeight 1024
    return compressed file
    if compressed > 4MB: reduce quality to 50 and retry

Add to pubspec.yaml:
  google_generative_ai: latest
  flutter_image_compress: latest
  path_provider: latest

### AI Lab Tab (/home/ai)

lib/features/ai/presentation/ai_tab.dart

Add to floating nav bar as 6th tab:
  index 5 AI: Icons.auto_awesome_outlined
  activeColor: aiAccent Color(0xFF818CF8) indigo

Update shell route to 6 tabs:
  /home/today, /home/tasks, /home/habits,
  /home/journal, /home/money, /home/ai

AITab layout (BlobBackground, SingleChildScrollView):

EXPERIMENTAL BANNER (top, prominent, always visible):
  GlassCard strong borderRadius 14:
    Row:
      Icon(Icons.science_outlined, aiAccent, 20px)
      SizedBox 10
      Column flex:
        Text "Experimental AI Features" 14px white85 bold
        Text "AI estimates may not be accurate. "
             "Use as a guide only, not medical advice."
             12px white45 lineHeight 1.5
    border: aiAccent.withOpacity(0.3) 0.5px
    background: aiAccent.withOpacity(0.06)

SizedBox 24

FOOD CALORIE CHECKER SECTION:
  Text "Food Calorie Checker" 16px white90 bold
  SizedBox 4
  Text "Take a photo of your food to get an AI-powered"
       "nutrition estimate." 13px white45
  SizedBox 16

  GlassCard strong:
    Column centered padding 24:
      Container 80x80 borderRadius 20:
        background: aiAccent.withOpacity(0.10)
        border: aiAccent.withOpacity(0.20)
        Icon(Icons.camera_alt_outlined, aiAccent, 36px)
      SizedBox 16
      Text "Scan your food" 16px white85 bold
      SizedBox 6
      Text "Point camera at a meal, snack, or ingredient"
           13px white45 textAlign center
      SizedBox 20
      TintedPill("📷 Check food calories", aiAccent,
        onTap: _openCamera)
      SizedBox 8
      TextButton "Choose from gallery" aiAccent 13px
        onTap: _pickFromGallery

  SizedBox 24

SCAN HISTORY SECTION:
  Text "Recent scans" 16px white90 bold
  SizedBox 12
  if no scans:
    GlassCard: Text "No scans yet" white35 centered 14px
  if has scans:
    list of FoodScanCard widgets (last 10 scans)
    each card GlassCard:
      Row: food emoji (🍽 default) + foodName 14px white80
           Spacer + calories bold aiAccent + "kcal" white45 12px
      Text servingNote 11px white35 if exists
      Text formatted date 11px white30

### Food Scan Flow

_openCamera():
  final picker = ImagePicker()
  final photo = await picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.rear,
    imageQuality: 85)
  if photo == null: return
  _analyzeImage(File(photo.path))

_pickFromGallery():
  final photo = await picker.pickImage(source: ImageSource.gallery)
  if photo == null: return
  _analyzeImage(File(photo.path))

_analyzeImage(File image) — auto-retries a busy Gemini response instead of
failing on the first one, since the shared Flash capacity 503s under load
often enough to be worth it:
  1. show FoodAnalyzingSheet (loading state), non-dismissible
  2. show/update a progress notification (id 4002, see Notification IDs
     addition below) — keeps tracking the scan even after the sheet is
     dismissed
  3. compress image via ImageCompressionService
     — a compression failure is NOT retried; treated as an immediate
       final failure (step 5)
  4. call GeminiService.analyzeFood(compressed) via runWithRetry
     (lib/features/ai/presentation/food_scan_retry.dart):
       - FoodScanErrorType.busy → wait 1 minute and retry, up to 5
         attempts total (1 initial + 4 retries); each retry updates the
         progress notification with an "attempt N/5" count
       - on the first retry: dismiss FoodAnalyzingSheet — the
         notification carries progress from here, freeing up the UI
       - any other error, or still busy after 5 attempts → final failure
         (step 5)
  5. on success:
       cancel the progress notification
       if analysis == null: show SnackBar "Couldn't identify food. Try a
         clearer photo."
       else: show FoodResultSheet(analysis) — onSave writes to
         food_scans and shows "Scan saved!"
     on final failure:
       cancel the progress notification
       if the sheet was already dismissed for a retry: also show a
         failure notification (id 4002, reused) with a "Retry" action —
         tapping it, or the notification body, reopens the AI tab; there
         is no way to safely resume the exact same photo across a
         killed-and-relaunched app, so "retry" just means letting the
         user scan again
       show SnackBar with the classified error message (see Error
         handling below)

### FoodAnalyzingSheet (loading bottom sheet)

lib/features/ai/presentation/food_analyzing_sheet.dart
showAppBottomSheet content:
  GlassCard strong:
    drag handle
    SizedBox 32
    Column centered:
      AnimatedBuilder on controller:
        Stack centered:
          CircularProgressIndicator aiAccent strokeWidth 2 size 64
          Icon(Icons.restaurant_outlined, white60, 28px) centered
      SizedBox 24
      Text "Analyzing your food..." 16px white85 bold
      SizedBox 8
      Text rotating tips (AnimatedSwitcher every 2s):
        "Identifying ingredients..."
        "Estimating portions..."
        "Calculating nutrition..."
        "Almost done..."
      SizedBox 32
    non-dismissible (isDismissible: false)
    dismissed programmatically (not by the user) as soon as a busy retry
    starts — see Food Scan Flow; a companion notification tracks
    progress from there

### FoodResultSheet (result bottom sheet)

lib/features/ai/presentation/food_result_sheet.dart
showAppBottomSheet content, isScrollControlled: true:

GlassCard strong:
  drag handle

  HEADER:
    Row:
      Column flex:
        Text analysis.foodName 22px bold white
        if analysis.servingNote:
          Text analysis.servingNote 12px white40
      confidence badge:
        Container padding 4 10 borderRadius 20:
          high: moneyAccent bg + "✓ High confidence"
          medium: amber bg + "~ Medium"
          low: red bg + "! Low confidence"

  SizedBox 16

  CALORIES (hero number):
    Container centered padding 20 borderRadius 16:
      background: aiAccent.withOpacity(0.10)
      border: aiAccent.withOpacity(0.20)
      Text analysis.calories.toString() 48px bold aiAccent
      Text "kcal" 16px aiAccent.withOpacity(0.7)
      Text "estimated" 11px white35

  SizedBox 16

  MACROS ROW (4 equal GlassCards):
    each card: macro value bold + macro name 10px white40
    Protein: white85
    Carbs: amber
    Fat: moneySpending (red)
    Fiber: moneyAccent (green)

  SizedBox 16

  if ingredients not empty:
    Text "Main ingredients" 13px white45
    SizedBox 6
    Wrap spacing 6:
      for each ingredient:
        Container padding 4 10 borderRadius 20
          glass style + Text 12px white70

  if healthNote:
    SizedBox 12
    GlassCard padding 12:
      Row: Icon(Icons.lightbulb_outline, amber, 16)
           SizedBox 8
           Text healthNote 13px white70 flex

  SizedBox 20

  DISCLAIMER:
    Text "⚠ AI estimates vary. Actual values depend on"
         "preparation, portion size, and ingredients."
         11px white30 textAlign center

  SizedBox 16

  Row:
    TextButton "Discard" white45 flex 1
      onTap: Navigator.pop
    SizedBox 8
    TintedPill("Save scan", aiAccent, flex 1)
      onTap: _saveScan → pop

  confidence == 'low': show extra warning above buttons:
    Text "⚠ Low confidence — photo may be unclear"
         12px red textAlign center

### Folder structure additions

```
lib/features/ai/
  data/
    food_scan_repository.dart
    supabase_food_scan_datasource.dart
  domain/
    food_analysis.dart
    food_scan.dart
  presentation/
    ai_tab.dart
    food_analyzing_sheet.dart
    food_result_sheet.dart
    food_scan_retry.dart        ← retry policy + notification helpers
    widgets/
      experimental_banner.dart
      food_scan_card.dart

lib/shared/services/
  gemini_service.dart
  image_compression_service.dart
```

### GlassTheme addition

Add to glass_theme.dart:
  aiAccent: Color(0xFF818CF8)  indigo/violet

### Nav bar update

6 tabs total:
  0 Home    white
  1 Tasks   taskAccent blue
  2 Habits  habitAccent purple
  3 Journal journalAccent yellow
  4 Money   moneyAccent green
  5 AI      aiAccent indigo

Island may need icon size reduced to 20px to fit 6 tabs comfortably.

### Error handling

FoodScanException class:
  message: String
  type: FoodScanErrorType
    (notFood, networkError, apiError, busy, timeout, unknown)
  busy is the one retryable type — see Food Scan Flow's runWithRetry and
  GeminiService's error classification above.

Show error as SnackBar on AITab — apiError, busy and unknown carry a
message GeminiService already tailored to the actual failure (busy
model, bad key, retired model, rate limit, ...); the rest use a fixed
message:
  notFood: "Couldn't identify food. Try a clearer photo."
  networkError: "No connection. Check your internet."
  timeout: "Request timed out. Try again."

### Notification IDs addition

- 4002 — food scan progress/failure (see Food Scan Flow):
    shown while analyzing/retrying — ongoing, silent, indeterminate
    progress bar, Importance.low (doesn't interrupt)
    replaced with a failure notification + "Retry" action if still busy
    after 5 attempts, or on any other final error once at least one
    retry has already happened; payload and action both reopen
    /home/ai

### What AI Lab is NOT

- Not a medical or dietary advice tool
- Not connected to a food database (pure AI estimation)
- Not calorie tracking over time in v1
- Not meal planning in v1
- No barcode scanning in v1
- Accuracy not guaranteed — experimental only