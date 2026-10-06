# Mindful App

A personal productivity app for daily journaling, habit tracking, and task
management. Frosted glass dark theme throughout. Google Sign-In auth.
Supabase primary database. Google Drive optional backup.

---

## Auth

- Sign in with Google (OAuth2) via google_sign_in
- Exchange Google ID token for Supabase session
- Only Supabase session maintained after login
- Drive OAuth in Settings only, never at login
- Sign-out (AuthNotifier.signOut) drops everything that belonged to the
  account, so the next account on the device starts clean:
    task/habit reminders cancelled + their ids freed
      (NotificationService.forgetAllItemReminders)
    every account Hive box cleared (AuthNotifier.userDataBoxNames: journal,
      habits, habit logs, tasks, money entries, budget settings, breathing
      sessions) — add any new account box there
    SyncService recreated, so its 5-minute throttle can't skip the next
      account's first sync
    home/lock screen widgets redrawn from the empty cache
  Device preferences (language, background, breathing sounds, journal
  reminder toggles) are kept. Unsynced pending writes are dropped.

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
- Text-to-speech: flutter_tts (breathing voice guide)
- Audio playback: audioplayers (breathing ambience loops)
- Screen wake lock: wakelock_plus (during a breathing session)

---

## Theme — Frosted Glass Dark

### Background
Color(0xFF0A1628) deep navy, full screen on all screens.
Optional custom photo from Settings (see Custom background below).

### Blob background (shared/widgets/blob_background.dart)
Every main screen uses BlobBackground widget — Stack with:
  layer 0: IgnorePointer — 3 positioned blurred circles:
    blob 1: 200×200 Color(0xFF14E6AA) opacity 0.18 blur 60, top:-40 right:-30
    blob 2: 160×160 Color(0xFF378ADD) opacity 0.18 blur 60, bottom:200 left:-40
    blob 3: 120×120 Color(0xFF7C6AF7) opacity 0.12 blur 60, top:280 right:20
  layer 1: child content
With a custom background set, an extra bottom layer goes under the blobs
(see Custom background).

### Custom background (Settings → Background)
The user can replace the plain background with a photo from their
gallery; the current glass theme is applied on top of it, unchanged:
  BlobBackground stack, bottom → top:
    photo — Image.file, BoxFit.cover, full screen, IgnorePointer
    scrim — GlassTheme.background at opacity 0.55
      (customBackgroundScrimOpacity), so white text and the 6%/8% glass
      cards stay readable on bright or busy photos
    the 3 blobs, then the screen content (GlassCards blur the photo
      through BackdropFilter like any other background)
  Applies wherever BlobBackground is used (all main tabs, journal editor,
    monthly recap); plain-Material screens like Settings stay as they are.
  Missing/unreadable file → falls back to the default background quietly.

Plumbing:
  CustomBackgroundRepository (settings/data/custom_background_repository.dart)
    pick → copy into <app documents>/backgrounds/bg_<timestamp>.<ext>,
    deleting the previous copy; persists only the FILE NAME in
    flutter_secure_storage `custom_background_file` — the iOS container
    path changes across updates, so an absolute path would stop resolving.
    Fresh file name per pick so the image cache never serves the old one.
  CustomBackgroundController (@Riverpod keepAlive,
    settings/presentation/custom_background_controller.dart):
    Future<String?> absolute path; pickFromGallery() (image_picker,
    max 2160px, quality 88 — returns false on cancel), reset().
  App (app.dart) watches it and wraps the router in AppBackgroundScope
    (shared/widgets/app_background_scope.dart, an InheritedWidget) via
    MaterialApp.builder; BlobBackground reads AppBackgroundScope.imagePathOf
    — an InheritedWidget so BlobBackground still works with no
    ProviderScope (widget tests) and defaults to no photo.
  Not part of Drive backup — it's a device-local preference.

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
checkbox fills, card highlights.

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
Uses BackdropFilter.grouped (also GlassIconButton, ExperimentalBanner);
BlobBackground wraps its content in a BackdropGroup, so all glass on a
screen shares one backdrop read (cheaper than one read per card).
Android overscroll: MaterialApp.scrollBehavior = GlassScrollBehavior
(shared/widgets/glass_scroll_behavior.dart) — glow instead of the M3
stretch. The stretch wraps the scroll view in a filtered Transform while
pulling past an edge, and BackdropFilters inside it can't see the
background, so every card went see-through until release.

### TintedPill widget (shared/widgets/tinted_pill.dart)
params: label:String, color:Color, onTap:VoidCallback?, icon:IconData?
background: color.withOpacity(0.18)
border: 0.5px color.withOpacity(0.25)
text: color, 13px, weight 600, borderRadius 20
optional leading icon 16px in color; label + icon centered when the pill
  is given a tight width (full-width primary actions)

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

### Keeping screens in sync after a write
Every screen showing a feature's data watches that feature's one list
provider, and every write goes through (or invalidates) it — so adding,
editing, completing or deleting anything updates Home, its tab, its
detail view and the home/lock screen widgets at once:
  tasks:    TaskTabController.save / complete / delete — reloads the list
            + taskByIdProvider(id) + widgets. Sheets never write to
            TaskRepository directly.
  routines: HabitTabController (log/unlog/archive/restore/delete) or
            ref.invalidate(habitTabControllerProvider) after a save;
            habitByIdProvider and archivedHabitsProvider watch it, so the
            detail screen follows.
  money:    invalidate moneyEntriesProvider (whole family) +
            remainingBudgetProvider; budget saves also monthly/daily
            budget + budgetCurrency.
  journal:  JournalEntries controller (create/update/delete).

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
  type text not null default 'review',  -- 'review' | 'plan' | 'gratitude'
  sync_status text default 'synced',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
-- existing projects: alter table journal_entries
--   add column type text not null default 'review';
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

Custom pagination indicator: 4 flat icons (trending_up, menu_book,
  calendar_month, checklist)
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

LoginScreen (BlobBackground + RepaintBoundary):
  top-right LoginLanguageButton (auth/presentation/widgets/): glass pill
    Icons.language + the language on screen ("English" / "Bahasa Indonesia"); tap →
    the same language sheet as Settings (shared/widgets/language_picker.dart
    — pickAppLanguage), switches + persists instantly
  "Mindful" title + tagline, then LoginFeatureCarousel
  (auth/presentation/widgets/) — a swipeable feature tour, one slide per
  feature in its tab accent, each a flat outlined Material icon (no
  emoji — they render inconsistently across platforms):
    journal menu_book_outlined, tasks & routines checklist_rounded,
    money account_balance_wallet_outlined, breathing air_rounded,
    AI food check restaurant_outlined, monthly recap
    calendar_month_outlined
    slide (LoginFeatureSlide): 48px icon in the accent, on an
      accent-tinted 104px badge that breathes (idle controller
      2400ms, repeat reverse) inside an orbit ring with 3 accent dots
      (CustomPainter), title + body; badge/title/body parallax, shrink and
      fade with the PageController's page mid-swipe
    page indicator: dots, active 20px wide in the current slide's accent
    auto-advances every 4s (wraps to the first), paused while dragging,
    countdown restarts after a swipe
    MediaQuery.disableAnimations → no idle motion, no auto-advance
  "Sign in with Google" button full width at the bottom (only sign-in
  option) — a full-width TintedPill (writeAccent, login icon) like every
  other primary action; a small writeAccent spinner while signing in.
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

BE MINDFUL SECTION (BeMindfulSection — be_mindful_section.dart), above
  Today's Todo — a step-by-step tour of every feature for new users:
  no title — starts with a short intro to the app (13px textSecondary,
    line height 1.5)
  GlassCard of PromptRows (0.5px white7 dividers) — the next 2 steps not
    tried yet, in this order; a step disappears once tried and the next
    one takes its place:
    1. eco_outlined habitAccent "Build your first routine" [Build] → AddHabitSheet
         done: any (non-archived) routine
    2. account_balance_wallet_outlined moneyAccent "Mindful with spending" [Record] → AddMoneySheet
         (Spending) — done: any spending entry (income doesn't count)
    3. checklist_rounded taskAccent "Mindful with your time" [Add] → AddTaskSheet
         done: any task
    4. restaurant_outlined aiAccent "Mindful with the food you eat" [Scan] → /home/ai
         done: any food scan (recentScansProvider)
    5. air_rounded exerciseAccent "Mindful breathing" [Breathe] →
         pickBreathingExercise (BreathingPickerSheet → session)
         done: any breathing session
    6. menu_book_outlined journalAccent "Mindful with your thoughts" [Write] →
         AddJournalSheet — done: any journal entry
    7. track_changes_rounded moneyAccent "Mindful with your budget" [Set] →
         BudgetSettingsSheet — done: a monthly or daily budget > 0
  Ordering is pure (home/domain/be_mindful_steps.dart —
  beMindfulProgress): a step still loading holds back the ones after it
  (no rows jumping around); a step whose data failed to load (e.g. food
  scans offline — Supabase only) is skipped. Nothing is persisted —
  "tried" is read from the data itself. The whole section (with its 24px
  gap) is hidden once every step is done.

TODAY'S TODO SECTION (TodayTodoCard — today_todo_card.dart):
  header: "Today's Todo" 16px white90 + "view all" 13px white35 → /home/tasks
  one GlassCard, tasks first then routines:
    up to 3 incomplete tasks due today/overdue (TodayTaskRow: checkbox
      taskAccent + name + due chip; tap → TaskDetailSheet)
    0.5px white7 divider (only when both halves have rows)
    today's routines not logged yet (TodayRoutineRow: icon, name, action
      pills / "Done"). The icon is always in the routine's own color; the
      pills are plain glass (RoutinePill,
      habits/presentation/routine_pill.dart). Tap a pill → log it, and the
      row leaves the card.
    Done items (completed tasks, logged routines) are never shown on Home —
      only on the Tasks & Routines tab, where they can be undone.
    empty: dashed-border "What needs to be done today?" white25; once
      every routine is logged and no task is due: celebration_outlined icon
      + "All done!" instead
    bottom Wrap (right-aligned, wraps on narrow screens):
      TintedPill("Add todo", taskAccent) → AddTaskSheet
      TintedPill("Add routine", habitAccent) → AddHabitSheet
  Tasks and routines load independently (TaskTabController /
  HabitTabController); a spinner only while both are loading.

MINDFULNESS SECTION (MindfulnessSection — mindfulness_section.dart):
  header: "Mindfulness" + "view all" → /home/journal (Mindfulness tab)
    (SectionHeader — shared/widgets/section_header.dart: 16px bold title
    + optional muted 13px text action on the right; also used by the Mindfulness
    tab's sections)
  GlassCard three rows, 0.5px white7 dividers (rows 1–2 are
  JournalPromptRows — journal/presentation/journal_prompt_rows.dart,
  PromptRow + PromptRowDivider — shared with the Mindfulness tab's empty
  "today" state):
    row 1: edit_note_rounded (journalAccent square) "Write today's plan" /
           "Outline your goals..." + TintedPill("Start", journalAccent)
           → AddJournalSheet(initialType: plan)
    row 2: nightlight_outlined (habitAccent square) "Review today" /
           "Reflect on your day..." + TintedPill("Reflect", taskAccent)
           → AddJournalSheet(initialType: review)
    row 3: air_rounded (exerciseAccent square) "Breathing exercise" /
           "Slow down with a guided breath." +
           TintedPill("Breathe", exerciseAccent) → BreathingPickerSheet
           (exercise/presentation/breathing_picker_sheet.dart: the 5
           exercises with step summaries; pick one → push
           /exercise/breathing/<name>)

UNSYNCED BANNER (AnimatedSwitcher, only when pending > 24h):
  subtle glass strip: "Some data hasn't synced. Tap to retry."
  tap → sync_service.retryPending()

MONTHLY RECAP BANNER (below the unsynced banner, above the remaining
  budget card — see Monthly Recap): last 3 days of a month through the 3rd of the next.

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
    Row _NavItem widgets (equal flex, one per tab — see Nav bar update)

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
    index 0 Home:              homeAccent    Color(0xFFFFFFFF) white
    index 1 Tasks & Routines:  taskAccent    Color(0xFF60A5FA) blue
    index 2 Mindfulness:       journalAccent Color(0xFFFCD34D) yellow
    (+ Money, AI — see Money Flow / AI Lab)
  inactive icon: Colors.white.withOpacity(0.28)
  active dot: AnimatedContainer width 16, height 4, borderRadius 2,
              color = tab accent color
  inactive dot: width 4, transparent

Tab icons (outline style):
  Home:             Icons.home_outlined
  Tasks & Routines: Icons.checklist_outlined
  Mindfulness:      Icons.menu_book_outlined

Shell Scaffold body: Stack [ child, Positioned bottom:0 FloatingNavBar ]
All tab screens: add bottom padding ≥ 88px so content clears the nav.

Write button tap → showModalBottomSheet (glass):
  ListTile (each with its tab's nav icon + accent) "Write journal" →
    AddJournalSheet(), "Add task" → AddTaskSheet(), "Add habit" →
    AddHabitSheet()

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
    JournalTypeSelector (same chips as AddJournalSheet, pre-set to the entry's type)
    title TextField (optional, 20px white, no border)
    body TextField (required, autofocus:TRUE, 16px white80,
                    no border, maxLines:null)
    photo strip (horizontal, 80×80 thumbnails + add button)
    SizedBox(200) breathing room

  _MoodRow (sticky, outside scroll):
    GlassCard padding 8 12 margin 12 4 borderRadius 14
    5 mood icon buttons (moodIcon: sentiment_satisfied_alt / neutral /
    dissatisfied / mood_bad / very_satisfied, semantics label = mood name)
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
  JournalTypeSelector (journal_type_selector.dart): chips
    Today review (nightlight_outlined) / Plan (edit_note_rounded) /
    Gratitude (volunteer_activism_outlined), icon + label, selected = journalAccent tint;
    always one selected — initialType param, default review
  body TextField autofocus:TRUE, 4+ lines, no border, white80,
    hint follows the type ("How did today go?" / "What do you want to get
    done today?" / "What are you grateful for today?")
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
  icon grid (20 presets, stored as emoji, drawn via HabitIcon; selected: habitAccent border + corner dot)
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
Shows date, mood icon, type badge (icon + label, journalAccent), title,
full body (scrollable).
Photo thumbnails horizontal scroll → tap for full screen.
"⋯" more → Edit (push /journal/:id/edit) / Delete (confirm).

---

### 7. Mindfulness Tab (/home/journal)

Journal and Exercise share ONE tab — JournalTab
(lib/features/journal/presentation/journal_tab.dart), titled
"Mindfulness" (nav semantics label too). There is no separate exercise
tab; /home/exercise just redirects here.

Journal types (JournalType enum, journal_entry.dart — stored in
`journal_entries.type`): review ("Today review", default), plan,
gratitude. Rows without a value / unknown values read as review.

BlobBackground + RepaintBoundary, ListView, bottom padding 88:
  "Mindfulness" title
  TODAY'S JOURNAL (JournalTodaySection, journal_today_section.dart):
    SectionHeader: "Today's journal" (journalAccent) + "view all" right →
      push /journal/history
    horizontal ListView (132px tall) of today's entries, newest first —
      JournalTodayCard (200 wide GlassCard): type badge, mood, first
      3 lines of the body, time written, unsynced dot; tap →
      JournalDetailSheet. Trailing "+ Write" card → AddJournalSheet.
    empty: the same rows as home's Mindfulness card — GlassCard of
      JournalPromptRows: "Write today's plan" (→ AddJournalSheet plan) /
      "Review today" (→ AddJournalSheet review)
  BREATHING (BreathingSection, exercise/presentation/widgets/
    breathing_section.dart — see Exercise):
    SectionHeader: "Breathing exercise" (exerciseAccent) + "History"
      right → push /exercise/activity (stats + full calendar)
    one GlassCard of BreathingExerciseRows (0.5px white7 dividers): the
      first 3 exercises, then a "Show all (N more)" row (N = the rest,
      currently 2) that expands the card to every exercise
      (AnimatedSize); expanded it reads "Show less" and collapses again

JournalHistoryScreen (/journal/history — full page, outside the shell):
  AppBar back + "Journal history"; CustomScrollView:
    JournalSearchField (glass input)
    JournalCalendarCard — shared MonthCalendarHeader/MonthCalendarGrid
      (shared/widgets/month_calendar.dart, also used by the exercise
      calendar): Mon first, can't page past this month, days with entries
      filled journalAccent (30% alpha, +15% per extra entry, max 75%),
      today ringed
    entries grouped by day ("Mon, Feb 2" headers), newest first:
      no day selected → the shown month; tap a day → only that day
      (tap again to clear); "No entries this month" / "Feb 2: no entries"
    a search query hides the calendar and searches every month
      (title + body, case-insensitive), headers then include the year
  Grouping/filtering is pure (journal/domain/journal_grouping.dart).
  GlassCard per entry: type badge, date, mood icon, first line, photo
  thumbnail, unsynced dot. Tap → JournalDetailSheet.

---

### 8. Tasks & Routines (/home/tasks)

Tasks and routines (habits) share ONE tab — PlanTab
(lib/features/plan/presentation/plan_tab.dart). There is no separate
habits tab and no /home/habits route any more. Home screen sections and
the home/lock screen widgets still show tasks and routines separately
(see Home Screen and the widgets section) — both "view all" links and the
widgets' routines link (`mindful://home/habits`) land on this tab.

Header: "Tasks & Routines" title + glass "+" button → small sheet:
  "Add task" → AddTaskSheet, "Add habit" → AddHabitSheet

Body (one ListView, bottom padding 88):
  ROUTINES section (first — they repeat every day):
    "Routines" group label + GlassCard of today's active habit rows
    (RoutineSection, habit_tab_list.dart); empty: IntroCard eco_outlined
      habitAccent "Routines repeat every day" + a short why (streaks,
      reminders) + TintedPill("Add routine") → AddHabitSheet
    each row: icon (always in the routine's color), name, action pills —
      the same RoutinePill as home's TodayRoutineRow (logged one tinted in
      the routine's own color — routineColorOf, habit_icon.dart)
    tapping the already-selected action (or "Done") undoes today's log
    tap row → HabitDetailScreen; long press → sheet: Edit / Archive / Delete
    "Archived (N)" next to the label (only when N > 0) → ArchivedHabitsSheet
      (archived_habits_sheet.dart): each archived habit with
      TintedPill("Restore") + delete; tap row → its HabitDetailScreen.
      Archive = hidden from today's list/widgets/recap + reminder cancelled,
      history kept; Restore reschedules the reminder.
    Delete removes the habit's habit_logs rows first, then the habit —
      habit_logs.habit_id has no `on delete cascade`, so deleting a habit
      with any log used to fail on the foreign key. Supabase first, then
      Hive (habit + its logs), so a failed delete changes nothing and shows
      a SnackBar.
  TASK sections (TaskSections, task_tab_list.dart):
    grouped Today / Upcoming / No date / Completed (collapsed)
    empty: "Todo" label + IntroCard checklist_rounded taskAccent "Clear your head, one
      task at a time" + a short why (due dates, reminders, subtasks, home
      screen) + TintedPill("Add task") → AddTaskSheet
    glass rows: checkbox (taskAccent fill when checked) + name + due chip
    tap row → TaskDetailSheet
    long press → sheet: Edit / Convert to routine / Delete
  Each half loads on its own (HabitTabController / TaskTabController) —
  one failing or loading never hides the other.

Convert task → routine:
  From the task row's long-press sheet, or TaskDetailSheet's "⋯" menu
  (pops with TaskDetailResult; showTaskDetailSheet opens the follow-up).
  Opens AddHabitSheet(fromTask: task):
    title "Convert to routine", hint "\"<name>\" will be removed from
      your tasks once this routine is saved."
    pre-fills: name; if the task had a reminder → reminder on, at that
      time of day, on the default days (Mon–Fri)
    due date and subtasks are not carried over (a routine has neither)
    button TintedPill("Save routine", habitAccent)
  On save: habit saved + reminder scheduled, THEN the task is deleted
    (forgetTaskReminder + TaskRepository.delete). A failed Supabase delete
    only shows a SnackBar — the routine is already saved by then.
  Closing the sheet without saving keeps the task untouched.

HabitDetailScreen (/habits/:id — full page, GlassPageScaffold so it
  follows the app/custom background):
  monthly calendar, habitAccent dots, streak count, swipe months.
  Habit with actions: each logged day shows the action's label (tiny
    tinted tag in the habit color) instead of a dot, and below the
    calendar a GlassCard "Actions this month" lists every action with how
    many times it was done + a bar relative to the most-done one (actions
    at 0 included; plain "Done" / "Removed action" rows only if present).
    Counting is pure (habits/domain/habit_action_summary.dart).
  Tap a day (any day up to today; future days aren't tappable) →
    HabitDayLogSheet (habit_day_log_sheet.dart): date title, "Logged as"
    + the current action ("Done" / "Not done" / "Removed action") and the
    log's note, then "Change to" chips in the habit color — "Not done",
    then each action (plain "Done" for a habit without actions; a
    plain-done or removed-action log keeps its chip so it shows
    selected) — and TintedPill("Save") at the bottom. Save with a change →
    HabitDetailController.setDayLog: saves the log (same id + note, new
    action) or deletes it for "Not done", updates the calendar in place,
    refreshes today's routine list + home widgets. A failed Supabase
    delete → SnackBar. Missed past days can be logged the same way.

AddHabitSheet / edit: uses bottom sheet (see Add Sheets above).

Notifications:
  habits: per-habit, habitAccent action buttons, fires on selected days.
  tasks: per-task at reminderAt, "Mark done" action button (taskAccent).

---

### 10. Settings (/settings — accessed from home top-right gear icon)

Opened via settings gear button top-right of HomeScreen.
NOT in bottom nav.

Language: "System default (<device language>)" / English / Bahasa Indonesia
  picker (see Localization). Default follows the device language.
Background (background_section.dart): row with a 40×40 thumbnail of the
  current photo (or wallpaper icon) + "Default" / "Custom photo"; tap →
  sheet: "Choose from gallery", "Reset to default" (only when custom).
  SnackBar "Background updated" / error. See Custom background.
Drive Backup: connect/disconnect, last backup date, pending count,
  back up now, auto-backup toggle.
Drive Restore (Drive connected): import from Drive, month picker,
  preview, warning dialog, skip-existing import.
Notifications: journal 8am toggle, journal 10pm toggle.
Monthly recap (monthly_recap_section.dart — see Monthly Recap):
  "Revisit a monthly recap" → month picker sheet → recap slideshow.
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
  New Journal Entry → opens AddJournalSheet
  New Task → opens AddTaskSheet
  New Habit → opens AddHabitSheet

---

### 11b. iOS App Intents — Back Tap / Shortcuts / Siri

iOS doesn't let apps detect Back Tap directly; Settings > Accessibility >
Touch > Back Tap can only run a system action or a Shortcut. So the app
exposes an App Intent, and the user binds it to Double/Triple Tap.

ios/Runner/AppDelegate.swift (iOS 16+):
  AddSpendingIntent — "Add spending", openAppWhenRun
  MindfulShortcuts (AppShortcutsProvider) — lists it in Shortcuts with no
    user setup; Siri phrases "Add/Log spending in Mindful"
  AppActionBridge — MethodChannel `mindful/app_actions`:
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
  Mindful section of the Shortcuts app first).

Intent titles/phrases are native (English only), like the home widgets'
labels — out of scope for the Dart ARB files.

---

### 12. Home and Lock Screen Widgets (home_widget)

widget_service.dart updates on every app open and after any write.
Tasks and routines stay separate on the widgets (unlike the in-app
Tasks & Routines tab); `mindful://home/tasks` and `mindful://home/habits`
both open that one tab, `mindful://open-habit` opens it then pushes
/habits/:id.

Both platforms show the same two home screen widgets (Android is the
reference; iOS mirrors its layout, colors and tap rules):

Medium 4×2 (MindfulMediumWidget): two columns —
  Routines: "Routines" (white60 12) + "X/Y done" (habitAccent 12), then a
    row per routine (habit row below)
  0.5px white10 divider
  Todo: "Todo" + "X/Y done" (taskAccent), a row per task due today/overdue
    (name + check glyph — taskAccent filled when done, white30 ring when
    not; tap → `mindful://open-task?taskId=…` → TaskDetailSheet)
  The Todo column + divider are hidden when no task is due, so routines
  fill the width. Pencil circle button bottom-right (white10 fill, white15
  border) → `mindful://open-write-sheet` (write options sheet).
Small 2×2 (MindfulSmallWidget): chooser on first add — "Show me:" +
  "Todo" (checklist icon) / "Routines" (self_improvement icon) pills; the
  pick is saved as `smallWidgetMode`
  (shared by every small widget; widget_service.dart keeps it and
  defaults it to 'tasks' once the app has written data). Then: bold title
  + accent "X/Y", the list (same rows as medium), "N remaining" footer
  (white35 11).
Habit (routine) rows: 30px habitAccent-tinted icon square (8 radius) +
  name (white 14), then one of:
    (icon, its square, pills and check all in the routine's own color —
    shapes are white-at-alpha drawables recolored with setColorFilter,
    since RemoteViews can't tint a background before API 31; iOS does the
    same in WidgetRows.swift. habitAccent when the color won't parse.
    Lock screen widgets stay monochrome — iOS tints them itself.)
    done → filled check, tap → undo today's log
      (`mindful://unlog-habit?habitId=…`) — same for habits with actions
    has actions → up to 2 action pills (routine-color text on 10% tint,
      15% border, radius 10), tap → log that action
      (`mindful://log-habit?habitId=…&action_label=…`)
    no actions → empty circle, tap → log plain "done"
      (`mindful://log-habit?habitId=…`)
  Tapping the rest of an actionless row opens /habits/:id
  (`mindful://open-habit`).
Copy (labels, "X/Y done", "N remaining", chooser) is pushed in the app
  language by widget_service.dart (`label*` keys, ARB widget*).

Android: those `mindful://` taps open the app, which logs/navigates in
  navigateFromWidgetUri (sheet_navigation.dart). Lists scroll.

iOS (ios/MindfulWidgets/ — the MindfulWidgetsExtension target's synced
folder: every .swift file in it is compiled, nothing outside it is; iOS 17+):
  Files: MindfulWidgets.swift (medium, small, circular count, bundle),
    WidgetRows.swift (RoutineRow / TaskRow / ActionPill — the Android row
    layouts), WidgetTheme.swift (colors.xml values + GlassWidgetBackground
    = widget_glass_background.xml: base, teal/blue glows, frost, sheen,
    hairline; opaque base, since iOS widgets can't show the wallpaper),
    RoutineStore.swift (shared data + tap queue), RoutineIntents.swift,
    RoutineLockScreenWidget.swift.
  App Group `group.com.guswira.mindful.widget` — main() calls
    HomeWidget.setAppGroupId on iOS (without it every iOS saveWidgetData
    fails); both targets' entitlements list the group. Kinds match
    WidgetProviderNames.iOS*: MindfulMediumWidget, MindfulSmallWidget,
    MindfulLockScreenWidget, MindfulRoutineLockScreenWidget.
  Differences from Android (platform limits):
    routine controls are interactive Button(intent:)s — they log in place
      without opening the app (LogRoutineIntent / UnlogRoutineIntent),
      same outcome as Android's log-habit / unlog-habit
    no scrolling: medium shows 3 rows per column, small 2
    1 action pill instead of 2 in a half-width column (small widget, or
      medium next to Todo) so the name stays readable; 2 when routines
      have the full medium width
    small widgets can't route per-row links: tap → widgetURL
      `mindful://home/tasks` / `home/habits`; the chooser pills are a
      ChooseSmallWidgetModeIntent
    links carry a `homeWidget` query item — home_widget only forwards URLs
      that have one; the `mindful` scheme is registered in Runner/Info.plist
    counts are recomputed from the routines ("X/Y done" from the
      `labelDoneCountFormat` / `labelRemainingFormat` templates), since a
      tap changes them before the app rewrites the labels

iOS routines lock screen widget (RoutineLockScreenWidget.swift, no
  Android counterpart — Android has no lock screen widgets):
  Same row rules as above, monochrome lock screen style.
  Edit Widget → pick a routine (SelectRoutineIntent, options = today's
    routines), or leave it empty.
  Rectangular, routine picked: "<icon> <name>" + its control (check /
    circle); not done with actions → up to 2 action pills underneath;
    done via an action → that action's name underneath.
  Rectangular, nothing picked (or the picked routine was deleted/archived):
    "Routines X/Y" + the first 2 routines, not-done first, each with its
    control; "All done" / "No routines yet".
  Circular: the picked routine (else the next not-done one) — its icon in a
    ring, tap → plain "done" / undo.
  Taps outside a button → `mindful://home/habits`.
  Circular count gauge (MindfulLockScreenWidget): routines X/Y.

How an iOS routine tap reaches the data — the extension can't reach
  Hive/Supabase:
  RoutineStore flips the routine in the shared `habits` JSON (+ habitsDone)
  so every widget redraws right away, and appends {habitId, date
  yyyy-MM-dd, actionLabel|null, undo} to `pendingHabitLogs`. Actions are
  matched by label (`habits` rows carry completedActionLabel).
  The app replays the queue (widget_habit_log_sync.dart —
  listenForWidgetHabitLogs, iOS only) once signed in and on every resume:
  clears it first, then HabitTabController.logAction / unlog with
  `on: date`, so a tap at 23:59 still lands on that day. Unknown habits
  are skipped; an unknown action label logs plain "done".
  Midnight: `habitsDate` (stamped by widget_service.dart) older than today
  reads as nothing done, and timelines reload at midnight.
Android widget background (res/drawable/widget_glass_background.xml):
  the GlassCard look rebuilt as a layer-list, since RemoteViews can't blur
  the wallpaper — 70% GlassTheme.background base, teal (top-right) and
  blue (bottom-left) radial glows like BlobBackground, 6% white frost
  (cardColor), top sheen, 0.5dp 12% white hairline (cardBorder), 18dp
  radius. Colors in res/values/colors.xml (widget_glass_*).

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
/home              → HomeScreen shell (FloatingNavBar, 5 tabs)
  /home/today      → HomeTab  (default)
  /home/tasks      → PlanTab  (tasks + routines)
  /home/journal    → JournalTab  (Mindfulness: journal + breathing)
  /home/money      → MoneyTab
  /home/ai         → AITab
/journal/history   → JournalHistoryScreen (calendar + by-date list, full page)
/journal/:id/edit  → JournalEditorScreen  (edit only, full page)
/habits/:id        → HabitDetailScreen    (calendar, full page)
/settings          → SettingsScreen
/recap/:month      → MonthlyRecapScreen  (slideshow, full page; month = yyyy-MM)
/exercise/activity → ExerciseActivityScreen (stats + calendar, full page)
/exercise/breathing/:exercise → BreathingSessionScreen (full page;
                     exercise = BreathingExercise.name, unknown → equal)
```

REMOVED routes (replaced by bottom sheets):
  /journal/new, /journal/:id, /habits/new, /habits/:id/edit,
  /tasks/new, /tasks/:id, /tasks/:id/edit
REMOVED: /home/habits (merged into /home/tasks — see Tasks & Routines)
REMOVED: /home/exercise shell tab (merged into /home/journal — kept only as
  a redirect to /home/journal)

Redirects:
  unauthenticated → /login (except /onboarding)
  authenticated on /login or /splash → /home/today

---

## UI conventions

- No emoji in the UI — flat Material icons (outlined / rounded), tinted
  with the feature accent. Emoji render differently per platform and
  can't be tinted. Copy strings carry no emoji either (notification
  titles, widget labels, disclaimers); where an app screen showed one, a
  small icon sits next to the text instead. The one exception is data:
  A routine's icon, action chips/pills and logged/check state use its own
  user-picked color (`habits.color`, routineColorOf), not habitAccent —
  habitAccent is only the fallback and the Routines section accent.
  Routine icons are still stored as their preset emoji (`habits.icon`,
  Drive backups, the widgets' `habits` JSON) and every surface maps the
  20 presets to a flat icon, ignoring U+FE0F; a non-preset emoji is
  drawn as-is:
    app      HabitIcon (habits/presentation/habit_icon.dart) — Material
             icon in the routine's color
    Android  RoutineIcons.kt → res/drawable/ic_routine_*.xml (the same
             Material icons, copied from the SDK's icon library),
             tinted with the routine's color via setColorFilter
    iOS      RoutineIcon.swift → matching SF Symbols (routine color on the
             home widget, monochrome on the lock screen; the Edit Widget
             picker shows the symbol too)
  Keep the three maps in sync when adding a preset. Icon maps: moodIcon / journalTypeIcon (journal_labels.dart),
  categoryIcon (money_labels.dart).
- Floating island nav bar — 5 tabs, NO profile tab, NO labels
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
- Full-page screens outside the shell (habit detail, journal editor,
  journal history, exercise activity) use GlassPageScaffold
  (shared/widgets/glass_page_scaffold.dart): transparent AppBar
  (no scrolled-under tint) with extendBodyBehindAppBar over BlobBackground,
  body in SafeArea — so the bar shows the blobs/custom photo instead of a
  plain dark strip
- Unsynced dot: small subtle, never disruptive
- Write button long press: radial arc overlay for quick access
- Full-page exceptions to "detail views are sheets": habit calendar, the
  monthly recap slideshow, a breathing session, the journal history and
  the exercise activity calendar
- ShakeWidget on empty required field submit attempt
- Empty feature lists use IntroCard (shared/widgets/intro_card.dart) — a
  brief introduction to the feature + the action that starts it — never a
  bare "No X yet" line (routines, tasks, budget, money entries)

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
│   │   ├── domain/be_mindful_steps.dart ← tour step order (pure)
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       └── widgets/
│   │           ├── greeting_header.dart    ← includes settings gear
│           ├── be_mindful_section.dart ← feature tour, 2 steps at a time
│   │           ├── quote_widget.dart
│   │   │           ├── today_todo_card.dart     ← tasks + routines + add buttons
│   │           ├── today_task_row.dart
│   │           ├── today_routine_row.dart
│   │           └── mindfulness_section.dart ← plan / review / breathing
│   ├── journal/
│   │   ├── data/
│   │   │   ├── journal_repository.dart
│   │   │   └── supabase_journal_datasource.dart
│   │   ├── domain/
│   │   │   ├── journal_entry.dart          ← + JournalType
│   │   │   └── journal_grouping.dart       ← by-day/month/search (pure)
│   │   └── presentation/
│   │       ├── journal_tab.dart            ← Mindfulness tab
│   │       ├── journal_today_section.dart  ← today strip / prompts + view all
│   │       ├── journal_prompt_rows.dart    ← plan / review rows (home + tab)
│   │       ├── journal_history_screen.dart ← full page calendar + list
│   │       ├── journal_calendar_card.dart
│   │       ├── journal_type_selector.dart
│   │       ├── journal_labels.dart         ← JournalType → copy
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
│   │       ├── habit_tab.dart          ← HabitTabController (today's habits)
│   │       ├── habit_tab_list.dart     ← RoutineSection (used by PlanTab)
│   │       ├── habit_detail_screen.dart    ← full page calendar
│   │       ├── habit_action_summary_card.dart ← per-action monthly counts
│   │       ├── habit_day_log_sheet.dart    ← tap a calendar day: view/change
│   │       ├── archived_habits_sheet.dart  ← "Archived (N)" link + sheet
│   │       ├── habit_manage_actions.dart   ← archive/restore/delete flows
│   │       ├── widget_habit_log_sync.dart  ← replays iOS lock screen taps
│   │       └── add_habit_sheet.dart        ← bottom sheet add + edit
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── task_repository.dart
│   │   │   └── supabase_task_datasource.dart
│   │   ├── domain/
│   │   │   ├── task.dart
│   │   │   └── task_checkbox.dart
│   │   └── presentation/
│   │       ├── task_tab.dart           ← TaskTabController
│   │       ├── task_tab_list.dart      ← TaskSections (used by PlanTab)
│   │       ├── task_detail_sheet.dart      ← bottom sheet
│   │       └── add_task_sheet.dart         ← bottom sheet
│   ├── plan/
│   │   └── presentation/
│   │       └── plan_tab.dart           ← Tasks & Routines tab
│   ├── recap/                          ← Monthly Recap (see section 15)
│   ├── exercise/                       ← Exercise / breathing (see section 16)
│   └── settings/
│       ├── data/custom_background_repository.dart
│       └── presentation/
│           ├── settings_screen.dart
│           ├── background_section.dart
│           ├── custom_background_controller.dart
│           └── monthly_recap_section.dart
└── shared/
    ├── widgets/
    │   ├── glass_card.dart
    │   ├── blob_background.dart     ← + custom photo + scrim layer
    │   ├── app_background_scope.dart ← custom photo path for BlobBackground
    │   ├── tinted_pill.dart
    │   ├── intro_card.dart       ← empty state: icon + title + why + action
    │   ├── section_header.dart   ← title + "view all"-style action
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

## App + notification icons ("Ripple Horizon" pack)
Colors: background #1E3B3F, sun #D9824F, ripples #A9C7B5, horizon #F1E9D8.
- iOS: assets/icon/app_icon.png (full-bleed 1024, no alpha) →
  `dart run flutter_launcher_icons` (config in pubspec, ios only).
- Android launcher: hand-made from the pack, committed directly —
  mipmap-*/ic_launcher(.png|_round.png|_foreground.png),
  mipmap-anydpi-v26/ic_launcher(_round).xml (adaptive: background
  @color/ic_launcher_background, themed-icon monochrome
  @drawable/ic_launcher_monochrome vector). flutter_launcher_icons has
  `android: false` so it never overwrites them. Manifest sets icon +
  roundIcon.
- Notification small (status bar): `@drawable/ic_stat_notification` —
  white-on-transparent sunrise silhouette (pack's ic_stat_notify PNGs),
  set once in AndroidInitializationSettings, tinted `color:` #D9824F
  (`notification_accent`) on every AndroidNotificationDetails.
  Never `@mipmap/ic_launcher`: Android draws small icons from alpha only,
  so the opaque launcher icon shows as a solid white blob.
- Notification large: `@drawable-nodpi/ic_notification_large` — the app
  icon at 256px, on every AndroidNotificationDetails.
- Both notification icons listed in res/raw/keep.xml so release resource
  shrinking keeps them (the plugin looks them up by name).
- Web: web/favicon.png + web/icons/Icon-*.png from the pack.

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
    - assets/ambience/
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

Add to floating nav bar as 4th tab:
  index 3 Money: Icons.account_balance_wallet_outlined
  activeColor: moneyAccent Color(0xFF34D399) emerald green

Shell route tabs:
  /home/today, /home/tasks, /home/journal, /home/money

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
  no budget set (neither monthly nor daily): IntroCard track_changes_rounded moneyAccent
    "Set a budget" + a short why + TintedPill("Set budget") →
    BudgetSettingsSheet, in place of the gauges

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

ADD BUTTONS ROW (hidden until the first entry exists — the empty state's
  "Record your spending" intro already offers adding one):
  Row:
    TintedPill("+ Spending", Colors.redAccent) flex 1
      onTap → AddMoneySheet(defaultType: spending)
    SizedBox 8
    TintedPill("+ Income", moneyAccent) flex 1
      onTap → AddMoneySheet(defaultType: income)

ENTRY LIST (grouped by date, newest first):
  no entries at all: IntroCard account_balance_wallet_outlined moneyAccent "Record your spending" +
    a short why + TintedPill("Record spending") → AddMoneySheet
    (Spending), in place of the period pills + list
  income but no spending yet: the same IntroCard above the pills + list
  date header: Text "Today" / "Yesterday" / "Mon, Oct 26" white45 12px
  each entry GlassCard:
    Row:
      category icon circle (36px):
        spending: red tinted glass + categoryIcon
        income: moneyAccent tinted glass + categoryIcon
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
      TintedPill("AI advice", aiAccent, icon: auto_awesome_outlined) → MoneyAdviceSheet (see AI Advice)

### AI Advice (MoneyAdviceSheet)

lib/features/money/presentation/money_advice_sheet.dart
Opened from the Recap section's "AI advice" pill. Experimental, uses
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
       info_outline icon + "Experimental AI advice... not financial advice."
       white30 11px
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
  amount: 36px bold white, whole numbers grouped with dots (4.000.000)
  autofocus: TRUE
  no border, hint "0"
  system keyboard suppressed (TextInputType.none) — typed via the in-sheet
    AmountKeypad (amount_keypad.dart) at the bottom of the sheet instead:
    1–9 / 000 0 ⌫ (long-press ⌫ clears), max 10 digits. Neither iOS nor
    Android lets an app add a "000" key to the system keyboard.
    Shown only while the amount field is focused; the note field gets the
    normal system keyboard.

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

REMAINING BUDGET WIDGET (after the recap banner, before Be mindful):
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
  Write journal → AddJournalSheet
  Add task → AddTaskSheet
  Add habit → AddHabitSheet
  Add money → AddMoneySheet(defaultType: spending)

Radial arc (hold+drag) directions update:
  LEFT → AddJournalSheet
  UP-LEFT → AddTaskSheet
  UP-RIGHT → AddHabitSheet
  RIGHT → AddMoneySheet(defaultType: spending)

App shortcuts (quick_actions) — add:
  Add Money → AddMoneySheet(defaultType: spending)

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

Add to floating nav bar as 5th tab:
  index 4 AI: Icons.auto_awesome_outlined
  activeColor: aiAccent Color(0xFF818CF8) indigo

Shell route tabs (5):
  /home/today, /home/tasks, /home/journal, /home/money, /home/ai

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
      TintedPill("Check food calories", aiAccent, icon: photo_camera_outlined,
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
      Row: restaurant_outlined icon (aiAccent) + foodName 14px white80
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
          high: moneyAccent bg + check_circle_outline + "Confident"
          (medium: help_outline "Estimate", low: error_outline "Uncertain")
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
    info_outline icon + Text "AI estimates vary. Actual values depend on"
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
    Text "Low confidence — photo may be unclear"
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

5 tabs total:
  0 Home                white
  1 Tasks & Routines    taskAccent blue   (routine rows inside keep habitAccent)
  2 Mindfulness         journalAccent yellow (exercise half keeps exerciseAccent)
  3 Money               moneyAccent green
  4 AI                  aiAccent indigo

Icon size 20px.

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


---

## 15. Monthly Recap

A story-style look back at one month — routines, tasks, cashflow and AI
usage — where every slide ends on a line that motivates the user to keep
going. Transient: computed on demand from the existing data, never stored.

### Entry points

Home banner (MonthlyRecapHomeBanner, recap/presentation/widgets/
monthly_recap_banner.dart), shown under the unsynced banner:
  window (recap/domain/recap_window.dart — recapMonthForBanner):
    last 3 days of a month → that month, "<Month> is almost over — see
      your recap"
    1st–3rd of a month → the previous month, "Your <Month> recap is
      ready"
    any other day → hidden
  always shown every day of the window — no dismiss button, no "seen"
    state, no Settings toggle; it can be opened as often as the user likes
  strong GlassCard, gradient icon (writeAccent → aiAccent), title +
    "Routines, tasks, cashflow and AI at a glance", chevron
  tap → opens the slideshow

Settings → "Revisit a monthly recap" (any time): opens a month picker
  sheet — this month "(so far)" + the 11 months before it, newest first
  (recapRevisitableMonths) — and tapping one opens its slideshow.

### Data (MonthlyRecap — recap/domain/monthly_recap.dart)

monthlyRecapProvider(month) gathers, buildMonthlyRecap (pure, unit
tested) computes. For a month still in progress only days up to today
count, and the copy says "so far".

  RoutineRecap: active (non-archived) habits, check-ins vs possible
    check-ins (one per habit per day since it was created), completion %,
    perfect days (every existing habit done), longest single-habit
    streak, top routine. Logs come from HabitRepository.logsInMonth
    (Supabase fetch merged into Hive, cache fallback offline).
  TaskRecap: completed (completed tasks with updated_at in the month —
    tasks have no completion timestamp), added (created_at in the month),
    still open (unfinished, due by month end / today), done rate.
  CashflowRecap: spending, income, net, % of monthly budget (if set),
    no-spend days, top spending category — from the Hive money cache, in
    the budget currency.
  AiRecap: food scans in the month, total + average kcal, most-scanned
    food — FoodScanRepository.getScansInMonth (Supabase only, 10s
    timeout); null when unreachable → the AI slide says it couldn't load.
  Money AI advice isn't stored, so it isn't counted.

Each section has a RecapTone (great / good / starting / empty) that picks
its motivation line — a quiet month gets encouragement, never a scolding:
  routines / tasks: ≥ 80% great, ≥ 50% good, else starting; nothing to
    count → empty
  cashflow: under budget (or no budget and net ≥ 0) great, net ≥ 0 good,
    else starting; no entries → empty
  AI: ≥ 10 scans great, ≥ 4 good, ≥ 1 starting, 0 empty

### MonthlyRecapScreen (/recap/:month)

Full page, BlobBackground + RepaintBoundary. 6 slides (recap_slides.dart):
  1. Intro — writeAccent, "Your <Month>" (or "so far"), year
  2. Routines — habitAccent, hero: check-ins
  3. Tasks — taskAccent, hero: tasks completed
  4. Cashflow — moneyAccent, hero: amount spent
  5. AI Lab — aiAccent, hero: food scans
  6. Outro — writeAccent, "Keep going!", TintedPill("Done") closes

Slide layout (RecapSlide): icon badge (34px icon in the accent on an
  accent-tinted 72px square) +
  uppercase section label (accent), hero value (48px bold white, counts up
  from 0 over 1.2s) + label, Wrap of small GlassCard stat chips (value in
  accent), strong GlassCard with the motivation line.

Playback (RecapSlideshow): story-style segment progress bars at the top +
  close (×); auto-advance every 7s, tap right ⅔ → next, left ⅓ → back,
  swipe between slides, hold to pause; "Tap to continue" hint (hidden on
  the last slide). Slides scroll vertically if they don't fit.
  MediaQuery.disableAnimations → no auto-advance and no count-up.

Copy: all in the ARB files (`recap*`, `settingsRecap*`).

### Folder structure

```
lib/features/recap/
  domain/
    monthly_recap.dart          ← MonthlyRecap + section recaps + RecapTone
    monthly_recap_builder.dart  ← buildMonthlyRecap (pure)
    recap_window.dart           ← banner window, revisit months, yyyy-MM keys
  presentation/
    monthly_recap_providers.dart ← monthlyRecap, monthlyRecapBannerMonth
    monthly_recap_screen.dart    ← route screen + openMonthlyRecap()
    recap_slide_data.dart
    recap_slides.dart            ← MonthlyRecap → slides + motivation
    widgets/
      monthly_recap_banner.dart  ← home banner
      recap_slideshow.dart       ← playback, tap/swipe/hold
      recap_progress_bars.dart
      recap_slide.dart
      recap_hero.dart            ← count-up hero number
```

### What Monthly Recap is NOT

- Not stored or synced — recomputed each time it's opened
- No notification for it in v1 (banner + Settings only)
- No persisted recap preferences — nothing in SettingsRepository
- No sharing/export of the slides in v1


---

## 16. Exercise

Calm practice, starting with guided breathing — the lower half of the
Mindfulness tab (see section 7). Feature accent:
exerciseAccent: Color(0xFFF9A8D4) — soft pink (in GlassTheme).

### Nav + routes

No nav tab of its own — BreathingSection sits on the Mindfulness
tab (/home/journal). Activity: /exercise/activity → ExerciseActivityScreen.
Session: /exercise/breathing/:exercise → BreathingSessionScreen (full page,
outside the shell — the nav bar is hidden during a session).

### Exercises (BreathingExercise enum — domain/breathing_exercise.dart)

Stored as its JsonValue in Supabase; `name` is the route segment.
  equal           'equal'      Equal Breathing     Inhale 4 · Release 4
  box             'box'        Box Breathing       Inhale 4 · Hold 4 · Release 4 · Hold 4
  fourSevenEight  '4_7_8'      4-7-8 Breathing     Inhale 4 · Hold 7 · Release 8
  holdTest        'hold_test'  Breath Holding Test Inhale 5 · Hold (until the user
                                                   taps Release) · Release 5 ·
                                                   Breathe normally 20
  custom          'custom'     Customize           user counts (below)

Steps (BreathPhaseType): inhale, hold (full), exhale ("Release"),
holdEmpty (box's 4th side, shown "Hold"), rest ("Breathe normally").
BreathingPattern (domain/breathing_pattern.dart) = ordered BreathPhases;
`seconds: null` = open-ended (hold test).

Customize: inhale/exhale 1–20s, hold/hold-after 0–20s (0 skips the step).
Defaults 4 / 2 / 6 / 0. Edited in CustomPatternSheet (− / + steppers per
step, "One cycle: Ns", TintedPill("Save pattern")), opened from the edit
icon on the Customize tile.

### Breathing section (on /home/journal) + activity screen

BreathingSection (widgets/breathing_section.dart), under today's journal:
  SectionHeader "Breathing exercise" (exerciseAccent) + "History" right →
    push /exercise/activity
  one GlassCard listing the first 3 exercises (collapsedCount) +
    "Show all (N more)" / "Show less" toggle row — rows are
    BreathingExerciseRow: icon square (exerciseAccent), name, step
    summary ("Inhale 4s · Hold 7s · Release 8s", exerciseAccent),
    TintedPill("Breathe", exerciseAccent) like home's Mindfulness card
    (Customize: an edit icon → CustomPatternSheet before the pill).
    Tap row → push /exercise/breathing/<name>.

ExerciseActivityScreen (/exercise/activity — full page, outside the shell):
  AppBar back + "Exercise activity", BlobBackground + RepaintBoundary:
    ExerciseStatsRow — 3 GlassCards: Sessions (all-time), Time spent
      ("45s" / "12m" / "1h 5m"), Day streak (consecutive days ending today,
      or yesterday so it doesn't read 0 before today's session).
    ExerciseCalendarCard — month grid (Mon first, shared MonthCalendarGrid),
      prev/next (can't go past this month); each day circle tinted
      exerciseAccent by time spent (25% → 75% alpha at 10+ min), today
      ringed in accent. Tap a day → "Oct 2: 2 sessions · 6m" below the
      grid; tap again (or no selection) → "This month: N sessions · T".

### BreathingSessionScreen

BlobBackground + RepaintBoundary, SafeArea, Column:
  SessionTopBar: glass back button, exercise name + step summary, glass
    music-note button → SoundSettingsSheet.
  BreathingCircle (Expanded): CustomPaint disc that grows over the inhale,
    stays full on hold, shrinks over the release (easeInOut), min 55% of
    full; thin ring around it with the current step's progress arc
    (exerciseAccent); a ripple ring expands + fades from the disc on every
    step change (2.4s), a thicker/brighter one when a cycle completes.
    Center: step word ("Inhale" / "Hold" / "Release" / "Breathe
    normally") + seconds left (count UP during an open-ended hold);
    "Tap Start when you're ready" before starting, "Paused" while paused.
  SessionStatsRow: Time elapsed (mm:ss), Cycles, + Best hold for the hold
    test.
  SessionControls (bottom, primary actions): Start → [Pause | Finish];
    during the hold test's open-ended hold Pause becomes Release; paused →
    [Resume | Finish].
  MediaQuery.disableAnimations → no ripples (the disc still sizes, since
    it carries the timing).

Behavior:
  BreathingEngine (domain/breathing_engine.dart) — pure, clock-free state
    machine (tick(delta) / release()), unit tested. A cycle = one lap of
    the pattern.
  BreathingSessionController (ChangeNotifier) ticks it from a Ticker every
    frame while running; each step change → ripple + voice.
  Leaving by any route (back button, system back, Finish) ends + saves the
    session (PopScope); the app being hidden pauses it.
  Screen kept awake while running (wakelock_plus via KeepScreenOn).
  Save (BreathingSessionSaver): sessions under 10s aren't saved
    ("Too short to save…"); otherwise SnackBar "Session saved · 3m ·
    12 cycles". The screen pops first; the saver holds the
    ProviderContainer + ScaffoldMessenger since Supabase may be slow.

### Voice guide + ambience (SoundSettingsSheet)

Opened from the session's music-note button; every change applies live to
the running session and persists (sliders persist on release only):
  Voice guide Switch + volume slider — flutter_tts speaks each step word
    (the same ARB copy as the circle) in the app language (en-US / id-ID),
    rate 0.45; the previous word is cut off, never queued. On iOS the TTS
    uses a shared playback session with mixWithOthers so it plays over
    the ambience. Android 11+ needs the TTS_SERVICE <queries> entry
    (AndroidManifest.xml).
  Ambience chips Off / Rain / Ocean / Wind / Calm drone + volume slider —
    audioplayers loops assets/ambience/<track>.wav (ReleaseMode.loop,
    mixWithOthers focus); pauses with the session, stops on finish.
    Tracks are synthesized 20s seamless loops (22.05kHz mono WAV — not
    AAC/MP3, whose encoder padding leaves an audible gap on every loop).
  Voice/ambience failures are logged and the session continues silently.

BreathingPreferences (Freezed, domain/breathing_preferences.dart):
  voiceEnabled (true), voiceVolume (0.8), ambience (rain),
  ambienceVolume (0.5), custom: CustomBreathing.
  Device-local (flutter_secure_storage `breathing_preferences`, one JSON
  value via BreathingPreferencesRepository) — not synced, not in Drive
  backup. BreathingPreferencesController (@Riverpod keepAlive):
  preview() (in memory) / save() (persist).

### Supabase schema

```sql
create table breathing_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  exercise text not null,          -- BreathingExercise JsonValue
  started_at timestamptz not null,
  duration_seconds int not null,
  cycles int not null default 0,
  best_hold_seconds int,           -- hold test only
  sync_status text default 'synced',
  created_at timestamptz default now()
);
alter table breathing_sessions enable row level security;
create policy "own" on breathing_sessions for all using (auth.uid()=user_id);
```

BreathingSession (Freezed, snake_case JSON). Times stored UTC; grouped by
local day for the stats/calendar.
BreathingSessionRepository: Hive box `breathing_sessions`, optimistic
  (Hive first; a failed Supabase upsert → syncStatus pending). Wired into
  SyncService: retryPendingSessions() + refresh() on open; refresh keeps
  pending rows so it can never drop an unsynced session. Upsert (not
  insert) so a retry of a write that actually landed doesn't fail on the
  duplicate id.

### Folder structure

```
assets/ambience/  rain.wav  ocean.wav  wind.wav  drone.wav

lib/features/exercise/
  data/
    breathing_session_repository.dart   ← Hive + Supabase sessions
    supabase_breathing_datasource.dart
    breathing_preferences_repository.dart
    breathing_voice.dart                ← flutter_tts wrapper
    ambience_player.dart                ← audioplayers loop wrapper
    keep_screen_on.dart                 ← wakelock_plus wrapper
  domain/
    breathing_exercise.dart
    breathing_pattern.dart              ← phases + presets
    breathing_engine.dart               ← pure session state machine
    breathing_session.dart
    breathing_preferences.dart          ← + AmbienceTrack, CustomBreathing
    exercise_stats.dart                 ← totals, streak, per-day
  presentation/
    exercise_activity_screen.dart       ← /exercise/activity
    exercise_providers.dart             ← sessions, stats, preferences
    breathing_session_screen.dart
    breathing_session_controller.dart   ← Ticker + voice + ambience
    breathing_session_saver.dart
    breathing_labels.dart               ← enum → copy, duration format
    sound_settings_sheet.dart
    custom_pattern_sheet.dart
    widgets/
      breathing_section.dart            ← on the Mindfulness tab
      breathing_exercise_row.dart       ← list row
      breathing_circle.dart / breathing_circle_painter.dart
      session_top_bar.dart / session_stats_row.dart / session_controls.dart
      exercise_stats_row.dart
      exercise_calendar_card.dart / exercise_calendar_grid.dart
```

Copy: all in the ARB files (`exercise*`, `breathing*`, `sound*`,
`ambience*`, `customPattern*`); journal side: `journal*`.

### What Exercise is NOT (v1)

- Breathing only — no workouts, yoga or step tracking yet
- No reminders/notifications for practice
- Not in the Monthly Recap or the home screen (yet)
- No custom ambience upload — bundled tracks only
- Sessions aren't part of Drive backup/restore
- No background playback — a session pauses when the app is hidden
