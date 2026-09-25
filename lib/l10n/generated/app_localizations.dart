import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mindful'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'view all'**
  String get commonViewAll;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @commonArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get commonArchive;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageSystemWithCurrent.
  ///
  /// In en, this message translates to:
  /// **'System default ({language})'**
  String settingsLanguageSystemWithCurrent(String language);

  /// No description provided for @languageNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// No description provided for @languageNameBahasa.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageNameBahasa;

  /// No description provided for @aiErrorNotFood.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t identify food. Try a clearer photo.'**
  String get aiErrorNotFood;

  /// No description provided for @aiErrorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet.'**
  String get aiErrorNoConnection;

  /// No description provided for @aiErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Try again.'**
  String get aiErrorTimeout;

  /// No description provided for @aiErrorCompressFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to compress image'**
  String get aiErrorCompressFailed;

  /// No description provided for @aiNotifAnalyzingBody.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your food…'**
  String get aiNotifAnalyzingBody;

  /// No description provided for @aiNotifRetryingBody.
  ///
  /// In en, this message translates to:
  /// **'Google\'s servers are busy — retrying (attempt {attempt}/{maxAttempts})…'**
  String aiNotifRetryingBody(int attempt, int maxAttempts);

  /// No description provided for @aiScanSaved.
  ///
  /// In en, this message translates to:
  /// **'Scan saved!'**
  String get aiScanSaved;

  /// No description provided for @aiMainIngredients.
  ///
  /// In en, this message translates to:
  /// **'Main ingredients'**
  String get aiMainIngredients;

  /// No description provided for @aiResultDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'⚠ AI estimates may vary based on portion size, preparation method, and ingredients.'**
  String get aiResultDisclaimer;

  /// No description provided for @aiLowConfidenceWarning.
  ///
  /// In en, this message translates to:
  /// **'Low confidence — try a clearer, closer photo.'**
  String get aiLowConfidenceWarning;

  /// No description provided for @aiDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get aiDismiss;

  /// No description provided for @aiDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get aiDiscard;

  /// No description provided for @aiSaveScan.
  ///
  /// In en, this message translates to:
  /// **'Save scan'**
  String get aiSaveScan;

  /// No description provided for @aiMacroProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get aiMacroProtein;

  /// No description provided for @aiMacroCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get aiMacroCarbs;

  /// No description provided for @aiMacroFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get aiMacroFat;

  /// No description provided for @aiMacroFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get aiMacroFiber;

  /// No description provided for @aiConfidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'✓ Confident'**
  String get aiConfidenceHigh;

  /// No description provided for @aiConfidenceLow.
  ///
  /// In en, this message translates to:
  /// **'! Uncertain'**
  String get aiConfidenceLow;

  /// No description provided for @aiConfidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'~ Estimate'**
  String get aiConfidenceMedium;

  /// No description provided for @aiCaloriesUnit.
  ///
  /// In en, this message translates to:
  /// **'calories'**
  String get aiCaloriesUnit;

  /// No description provided for @aiPerServing.
  ///
  /// In en, this message translates to:
  /// **'per serving'**
  String get aiPerServing;

  /// No description provided for @aiAnalyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your food...'**
  String get aiAnalyzingTitle;

  /// No description provided for @aiAnalyzingTipIngredients.
  ///
  /// In en, this message translates to:
  /// **'Identifying ingredients...'**
  String get aiAnalyzingTipIngredients;

  /// No description provided for @aiAnalyzingTipPortions.
  ///
  /// In en, this message translates to:
  /// **'Estimating portions...'**
  String get aiAnalyzingTipPortions;

  /// No description provided for @aiAnalyzingTipNutrition.
  ///
  /// In en, this message translates to:
  /// **'Calculating nutrition...'**
  String get aiAnalyzingTipNutrition;

  /// No description provided for @aiAnalyzingTipAlmostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost done...'**
  String get aiAnalyzingTipAlmostDone;

  /// No description provided for @aiExperimentalTitle.
  ///
  /// In en, this message translates to:
  /// **'Experimental AI Features'**
  String get aiExperimentalTitle;

  /// No description provided for @aiExperimentalBody.
  ///
  /// In en, this message translates to:
  /// **'AI estimates may not be accurate. Use as a guide only — not medical advice.'**
  String get aiExperimentalBody;

  /// No description provided for @aiFoodCheckerTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Calorie Checker'**
  String get aiFoodCheckerTitle;

  /// No description provided for @aiFoodCheckerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your food to get an AI-powered nutrition estimate.'**
  String get aiFoodCheckerSubtitle;

  /// No description provided for @aiScanYourFood.
  ///
  /// In en, this message translates to:
  /// **'Scan your food'**
  String get aiScanYourFood;

  /// No description provided for @aiScanYourFoodHint.
  ///
  /// In en, this message translates to:
  /// **'Point camera at a meal, snack or ingredient'**
  String get aiScanYourFoodHint;

  /// No description provided for @aiCheckFoodCalories.
  ///
  /// In en, this message translates to:
  /// **'📷  Check food calories'**
  String get aiCheckFoodCalories;

  /// No description provided for @aiChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get aiChooseFromGallery;

  /// No description provided for @aiUnknownFood.
  ///
  /// In en, this message translates to:
  /// **'Unknown food'**
  String get aiUnknownFood;

  /// No description provided for @aiKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get aiKcal;

  /// No description provided for @aiRecentScans.
  ///
  /// In en, this message translates to:
  /// **'Recent scans'**
  String get aiRecentScans;

  /// No description provided for @aiNoScansYet.
  ///
  /// In en, this message translates to:
  /// **'No scans yet. Try scanning your next meal!'**
  String get aiNoScansYet;

  /// No description provided for @aiLoadScansFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load scans'**
  String get aiLoadScansFailed;

  /// No description provided for @geminiErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get geminiErrorUnknown;

  /// No description provided for @geminiErrorInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid Gemini API key. Check GEMINI_API_KEY in .env.'**
  String get geminiErrorInvalidKey;

  /// No description provided for @geminiErrorBusy.
  ///
  /// In en, this message translates to:
  /// **'Google\'s AI service is busy right now. Try again in a moment.'**
  String get geminiErrorBusy;

  /// No description provided for @geminiErrorQuota.
  ///
  /// In en, this message translates to:
  /// **'You\'ve hit the AI usage limit. Try again later.'**
  String get geminiErrorQuota;

  /// No description provided for @geminiErrorModelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI model unavailable. The app may need updating.'**
  String get geminiErrorModelUnavailable;

  /// No description provided for @geminiErrorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'AI access denied. Check your API key\'s permissions.'**
  String get geminiErrorPermissionDenied;

  /// No description provided for @geminiErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'AI service error. Try again later.'**
  String get geminiErrorGeneric;

  /// No description provided for @notifBudgetResetTitle.
  ///
  /// In en, this message translates to:
  /// **'New month, new budget'**
  String get notifBudgetResetTitle;

  /// No description provided for @notifBudgetResetBody.
  ///
  /// In en, this message translates to:
  /// **'Your budget has reset.'**
  String get notifBudgetResetBody;

  /// No description provided for @notifBudgetChannelName.
  ///
  /// In en, this message translates to:
  /// **'Budget reminders'**
  String get notifBudgetChannelName;

  /// No description provided for @notifBudgetChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget reset reminder'**
  String get notifBudgetChannelDescription;

  /// No description provided for @notifTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Test notification'**
  String get notifTestTitle;

  /// No description provided for @notifTestBody.
  ///
  /// In en, this message translates to:
  /// **'If you see this, notification delivery works on this device.'**
  String get notifTestBody;

  /// No description provided for @notifDebugChannelName.
  ///
  /// In en, this message translates to:
  /// **'Debug test notifications'**
  String get notifDebugChannelName;

  /// No description provided for @notifDebugChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'A manually triggered test notification, from Settings'**
  String get notifDebugChannelDescription;

  /// No description provided for @notifJournalMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Good morning ☀️'**
  String get notifJournalMorningTitle;

  /// No description provided for @notifJournalMorningBody.
  ///
  /// In en, this message translates to:
  /// **'Time to write in your journal'**
  String get notifJournalMorningBody;

  /// No description provided for @notifJournalEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'How was your day? 🌙'**
  String get notifJournalEveningTitle;

  /// No description provided for @notifJournalEveningBody.
  ///
  /// In en, this message translates to:
  /// **'Write it down'**
  String get notifJournalEveningBody;

  /// No description provided for @notifJournalChannelName.
  ///
  /// In en, this message translates to:
  /// **'Journal reminders'**
  String get notifJournalChannelName;

  /// No description provided for @notifJournalChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily journaling reminders'**
  String get notifJournalChannelDescription;

  /// No description provided for @notifHabitBody.
  ///
  /// In en, this message translates to:
  /// **'Time for {habitName}'**
  String notifHabitBody(String habitName);

  /// No description provided for @notifHabitChannelName.
  ///
  /// In en, this message translates to:
  /// **'Habit reminders'**
  String get notifHabitChannelName;

  /// No description provided for @notifHabitChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders to complete your habits'**
  String get notifHabitChannelDescription;

  /// No description provided for @notifTaskChannelName.
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get notifTaskChannelName;

  /// No description provided for @notifTaskChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders for tasks with a due date'**
  String get notifTaskChannelDescription;

  /// No description provided for @notifTaskMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get notifTaskMarkDone;

  /// No description provided for @notifFoodScanProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your food…'**
  String get notifFoodScanProgressTitle;

  /// No description provided for @notifFoodScanProgressChannelName.
  ///
  /// In en, this message translates to:
  /// **'Food scan progress'**
  String get notifFoodScanProgressChannelName;

  /// No description provided for @notifFoodScanProgressChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Shows while a food photo is being analyzed'**
  String get notifFoodScanProgressChannelDescription;

  /// No description provided for @notifFoodScanFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Food scan failed'**
  String get notifFoodScanFailedTitle;

  /// No description provided for @notifFoodScanResultChannelName.
  ///
  /// In en, this message translates to:
  /// **'Food scan result'**
  String get notifFoodScanResultChannelName;

  /// No description provided for @notifFoodScanResultChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'A food scan that failed after retrying'**
  String get notifFoodScanResultChannelDescription;

  /// No description provided for @shortcutNewJournal.
  ///
  /// In en, this message translates to:
  /// **'New Journal'**
  String get shortcutNewJournal;

  /// No description provided for @shortcutNewTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get shortcutNewTask;

  /// No description provided for @shortcutNewHabit.
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get shortcutNewHabit;

  /// No description provided for @shortcutAddMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get shortcutAddMoney;

  /// No description provided for @shortcutScanFood.
  ///
  /// In en, this message translates to:
  /// **'Scan Food'**
  String get shortcutScanFood;

  /// No description provided for @widgetLabelTasks.
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get widgetLabelTasks;

  /// No description provided for @widgetLabelHabits.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get widgetLabelHabits;

  /// No description provided for @widgetLabelShowMe.
  ///
  /// In en, this message translates to:
  /// **'Show me:'**
  String get widgetLabelShowMe;

  /// No description provided for @widgetChooseTasks.
  ///
  /// In en, this message translates to:
  /// **'✅ Todo'**
  String get widgetChooseTasks;

  /// No description provided for @widgetChooseHabits.
  ///
  /// In en, this message translates to:
  /// **'💪 Routines'**
  String get widgetChooseHabits;

  /// No description provided for @widgetDoneCount.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} done'**
  String widgetDoneCount(int done, int total);

  /// No description provided for @widgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String widgetRemaining(int count);

  /// No description provided for @habitWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get habitWeekdayMon;

  /// No description provided for @habitWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get habitWeekdayTue;

  /// No description provided for @habitWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get habitWeekdayWed;

  /// No description provided for @habitWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get habitWeekdayThu;

  /// No description provided for @habitWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get habitWeekdayFri;

  /// No description provided for @habitWeekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get habitWeekdaySat;

  /// No description provided for @habitWeekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get habitWeekdaySun;

  /// No description provided for @habitRepeatOn.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get habitRepeatOn;

  /// No description provided for @habitCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get habitCurrentStreak;

  /// No description provided for @habitLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get habitLongestStreak;

  /// No description provided for @habitSavedLocallySyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Saved locally — sync failed: {error}'**
  String habitSavedLocallySyncFailed(String error);

  /// No description provided for @habitEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get habitEditTitle;

  /// No description provided for @habitBuildNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Build new habit'**
  String get habitBuildNewTitle;

  /// No description provided for @habitSectionIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get habitSectionIcon;

  /// No description provided for @habitSectionColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get habitSectionColor;

  /// No description provided for @habitSectionReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get habitSectionReminder;

  /// No description provided for @habitSectionCustomActions.
  ///
  /// In en, this message translates to:
  /// **'Custom actions'**
  String get habitSectionCustomActions;

  /// No description provided for @habitCustomActionsHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — e.g. Gym, Run, Walk'**
  String get habitCustomActionsHint;

  /// No description provided for @habitCustomActionsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for a single Done button'**
  String get habitCustomActionsEmptyHint;

  /// No description provided for @habitSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get habitSaveChanges;

  /// No description provided for @habitAddHabit.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get habitAddHabit;

  /// No description provided for @habitFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habitFallbackTitle;

  /// No description provided for @habitLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load habit: {error}'**
  String habitLoadError(String error);

  /// No description provided for @habitNameHint.
  ///
  /// In en, this message translates to:
  /// **'Habit name...'**
  String get habitNameHint;

  /// No description provided for @habitEmptyList.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get habitEmptyList;

  /// No description provided for @habitSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sync \"{name}\": {error}'**
  String habitSyncFailed(String name, String error);

  /// No description provided for @habitArchiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive habit?'**
  String get habitArchiveConfirmTitle;

  /// No description provided for @habitArchiveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be hidden from today\'s list.'**
  String habitArchiveConfirmBody(String name);

  /// No description provided for @habitDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete habit?'**
  String get habitDeleteConfirmTitle;

  /// No description provided for @habitDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" and its history will be removed.'**
  String habitDeleteConfirmBody(String name);

  /// No description provided for @habitTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get habitTabTitle;

  /// No description provided for @habitLoadListError.
  ///
  /// In en, this message translates to:
  /// **'Could not load habits: {error}'**
  String habitLoadListError(String error);

  /// No description provided for @habitAddAction.
  ///
  /// In en, this message translates to:
  /// **'+ Add action'**
  String get habitAddAction;

  /// No description provided for @taskGroupUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get taskGroupUpcoming;

  /// No description provided for @taskGroupNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get taskGroupNoDate;

  /// No description provided for @taskEmptyList.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get taskEmptyList;

  /// No description provided for @taskCompletedSection.
  ///
  /// In en, this message translates to:
  /// **'Completed ({count})'**
  String taskCompletedSection(int count);

  /// No description provided for @taskSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sync \"{name}\": {error}'**
  String taskSyncFailed(String name, String error);

  /// No description provided for @taskTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get taskTabTitle;

  /// No description provided for @taskAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get taskAddTask;

  /// No description provided for @taskLoadListError.
  ///
  /// In en, this message translates to:
  /// **'Could not load tasks: {error}'**
  String taskLoadListError(String error);

  /// No description provided for @taskAdded.
  ///
  /// In en, this message translates to:
  /// **'Task added'**
  String get taskAdded;

  /// No description provided for @taskUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get taskUndo;

  /// No description provided for @taskSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get taskSheetTitle;

  /// No description provided for @taskAddDueDate.
  ///
  /// In en, this message translates to:
  /// **'Add due date'**
  String get taskAddDueDate;

  /// No description provided for @taskAddReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get taskAddReminder;

  /// No description provided for @taskSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get taskSaveChanges;

  /// No description provided for @taskNameHint.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get taskNameHint;

  /// No description provided for @taskAddSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Add subtasks'**
  String get taskAddSubtasks;

  /// No description provided for @taskAddSubtask.
  ///
  /// In en, this message translates to:
  /// **'+ Add subtask'**
  String get taskAddSubtask;

  /// No description provided for @taskSubtaskHint.
  ///
  /// In en, this message translates to:
  /// **'Subtask...'**
  String get taskSubtaskHint;

  /// No description provided for @taskSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get taskSubtasks;

  /// No description provided for @taskLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load task: {error}'**
  String taskLoadError(String error);

  /// No description provided for @taskNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskNotFound;

  /// No description provided for @taskMarkAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get taskMarkAsDone;

  /// No description provided for @taskDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get taskDeleteConfirmTitle;

  /// No description provided for @taskDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed.'**
  String taskDeleteConfirmBody(String name);

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTooltip;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingMorningName.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String homeGreetingMorningName(String name);

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingAfternoonName.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String homeGreetingAfternoonName(String name);

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingEveningName.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String homeGreetingEveningName(String name);

  /// No description provided for @homeSectionTodayTasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Todo'**
  String get homeSectionTodayTasks;

  /// No description provided for @homeSectionHabits.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get homeSectionHabits;

  /// No description provided for @homeSectionJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get homeSectionJournal;

  /// No description provided for @homeJournalPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Write today\'s plan'**
  String get homeJournalPlanTitle;

  /// No description provided for @homeJournalPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Outline your goals for a focused day.'**
  String get homeJournalPlanSubtitle;

  /// No description provided for @homeJournalPlanAction.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get homeJournalPlanAction;

  /// No description provided for @homeJournalReflectTitle.
  ///
  /// In en, this message translates to:
  /// **'Review what happened'**
  String get homeJournalReflectTitle;

  /// No description provided for @homeJournalReflectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reflect on your day\'s accomplishments.'**
  String get homeJournalReflectSubtitle;

  /// No description provided for @homeJournalReflectAction.
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get homeJournalReflectAction;

  /// No description provided for @homeHabitsProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String homeHabitsProgress(int done, int total);

  /// No description provided for @homeStreakJournalLabel.
  ///
  /// In en, this message translates to:
  /// **'Journal streak'**
  String get homeStreakJournalLabel;

  /// No description provided for @homeStreakHabitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Habits today'**
  String get homeStreakHabitsLabel;

  /// No description provided for @homeStreakTasksLabel.
  ///
  /// In en, this message translates to:
  /// **'Tasks due'**
  String get homeStreakTasksLabel;

  /// No description provided for @homeTasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done today?'**
  String get homeTasksEmpty;

  /// No description provided for @homeAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get homeAddTask;

  /// No description provided for @homeSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sync \"{name}\": {error}'**
  String homeSyncFailed(String name, String error);

  /// No description provided for @homeHabitsAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done! 🎉'**
  String get homeHabitsAllDone;

  /// No description provided for @homeHabitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Build your first habit'**
  String get homeHabitsEmpty;

  /// No description provided for @homeHabitsStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get homeHabitsStart;

  /// No description provided for @homeUnsyncedBanner.
  ///
  /// In en, this message translates to:
  /// **'Some changes haven\'t synced yet'**
  String get homeUnsyncedBanner;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authSignInWithGoogle;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed: {error}'**
  String authSignInFailed(String error);

  /// No description provided for @journalTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTabTitle;

  /// No description provided for @journalLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load entries: {error}'**
  String journalLoadFailed(String error);

  /// No description provided for @journalSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search entries'**
  String get journalSearchHint;

  /// No description provided for @journalEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get journalEmpty;

  /// No description provided for @journalPhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get journalPhotoCamera;

  /// No description provided for @journalPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get journalPhotoGallery;

  /// No description provided for @journalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title...'**
  String get journalTitleHint;

  /// No description provided for @journalBodyHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind...'**
  String get journalBodyHint;

  /// No description provided for @journalDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get journalDeleteEntry;

  /// No description provided for @journalAddSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s going on'**
  String get journalAddSheetTitle;

  /// No description provided for @journalSaveEntry.
  ///
  /// In en, this message translates to:
  /// **'Save entry'**
  String get journalSaveEntry;

  /// No description provided for @journalDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get journalDeleteConfirmTitle;

  /// No description provided for @journalDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the entry and its photos from Supabase.'**
  String get journalDeleteConfirmBody;

  /// No description provided for @moneyAddEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s going on'**
  String get moneyAddEntryTitle;

  /// No description provided for @moneyEditEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get moneyEditEntryTitle;

  /// No description provided for @moneyCategoryHeading.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get moneyCategoryHeading;

  /// No description provided for @moneyNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get moneyNoteHint;

  /// No description provided for @moneySaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get moneySaveChanges;

  /// No description provided for @moneyTypeToggleSpending.
  ///
  /// In en, this message translates to:
  /// **'💸 Spending'**
  String get moneyTypeToggleSpending;

  /// No description provided for @moneyTypeToggleIncome.
  ///
  /// In en, this message translates to:
  /// **'💰 Income'**
  String get moneyTypeToggleIncome;

  /// No description provided for @moneyDateChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get moneyDateChange;

  /// No description provided for @moneyTypeSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get moneyTypeSpending;

  /// No description provided for @moneyTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get moneyTypeIncome;

  /// No description provided for @moneyBudgetMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get moneyBudgetMonthly;

  /// No description provided for @moneyBudgetDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get moneyBudgetDaily;

  /// No description provided for @moneyBudgetSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget settings'**
  String get moneyBudgetSettingsTitle;

  /// No description provided for @moneyMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get moneyMonthlyBudget;

  /// No description provided for @moneyDailyBudget.
  ///
  /// In en, this message translates to:
  /// **'Daily budget'**
  String get moneyDailyBudget;

  /// No description provided for @moneySaveMonthly.
  ///
  /// In en, this message translates to:
  /// **'Save monthly'**
  String get moneySaveMonthly;

  /// No description provided for @moneySaveDaily.
  ///
  /// In en, this message translates to:
  /// **'Save daily'**
  String get moneySaveDaily;

  /// No description provided for @moneyDeleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get moneyDeleteEntryTitle;

  /// No description provided for @moneyDeleteEntryBody.
  ///
  /// In en, this message translates to:
  /// **'\"{category}\" will be removed.'**
  String moneyDeleteEntryBody(String category);

  /// No description provided for @moneyTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Cashflow'**
  String get moneyTabTitle;

  /// No description provided for @moneyAddSpending.
  ///
  /// In en, this message translates to:
  /// **'+ Spending'**
  String get moneyAddSpending;

  /// No description provided for @moneyAddIncome.
  ///
  /// In en, this message translates to:
  /// **'+ Income'**
  String get moneyAddIncome;

  /// No description provided for @moneyEmptyBudgetPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set your budget to get started'**
  String get moneyEmptyBudgetPrompt;

  /// No description provided for @moneySetBudget.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get moneySetBudget;

  /// No description provided for @moneySetMonthly.
  ///
  /// In en, this message translates to:
  /// **'Set Monthly'**
  String get moneySetMonthly;

  /// No description provided for @moneySetDaily.
  ///
  /// In en, this message translates to:
  /// **'Set Daily'**
  String get moneySetDaily;

  /// No description provided for @moneyBudgetOf.
  ///
  /// In en, this message translates to:
  /// **'of {currency} {amount}'**
  String moneyBudgetOf(String currency, String amount);

  /// No description provided for @moneyGaugeOver.
  ///
  /// In en, this message translates to:
  /// **'Over'**
  String get moneyGaugeOver;

  /// No description provided for @moneyAmountLeft.
  ///
  /// In en, this message translates to:
  /// **'{currency} {amount} left'**
  String moneyAmountLeft(String currency, String amount);

  /// No description provided for @moneyPeriodThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get moneyPeriodThisWeek;

  /// No description provided for @moneyPeriodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get moneyPeriodThisMonth;

  /// No description provided for @moneyPeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get moneyPeriodAll;

  /// No description provided for @moneyNoEntriesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No entries in this period'**
  String get moneyNoEntriesInPeriod;

  /// No description provided for @moneyRecapTitle.
  ///
  /// In en, this message translates to:
  /// **'Recap'**
  String get moneyRecapTitle;

  /// No description provided for @moneyRecapNoSpending.
  ///
  /// In en, this message translates to:
  /// **'No spending yet this period'**
  String get moneyRecapNoSpending;

  /// No description provided for @moneyRecapNet.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get moneyRecapNet;

  /// No description provided for @moneyRecapTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category: {emoji} {category}'**
  String moneyRecapTopCategory(String emoji, String category);

  /// No description provided for @moneyMonthlyRemaining.
  ///
  /// In en, this message translates to:
  /// **'Monthly remaining'**
  String get moneyMonthlyRemaining;

  /// No description provided for @moneyDailyRemaining.
  ///
  /// In en, this message translates to:
  /// **'Daily remaining'**
  String get moneyDailyRemaining;

  /// No description provided for @moneyCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get moneyCategoryFood;

  /// No description provided for @moneyCategoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get moneyCategoryTransport;

  /// No description provided for @moneyCategoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get moneyCategoryShopping;

  /// No description provided for @moneyCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get moneyCategoryHealth;

  /// No description provided for @moneyCategoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get moneyCategoryEntertainment;

  /// No description provided for @moneyCategoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get moneyCategoryBills;

  /// No description provided for @moneyCategoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get moneyCategoryEducation;

  /// No description provided for @moneyCategoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get moneyCategoryTravel;

  /// No description provided for @moneyCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get moneyCategoryOther;

  /// No description provided for @moneyCategorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get moneyCategorySalary;

  /// No description provided for @moneyCategoryFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get moneyCategoryFreelance;

  /// No description provided for @moneyCategoryInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get moneyCategoryInvestment;

  /// No description provided for @moneyCategoryGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get moneyCategoryGift;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSignedInFallback.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get settingsSignedInFallback;

  /// No description provided for @settingsSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String settingsSignedInAs(String name);

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsMorningReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning journal reminder'**
  String get settingsMorningReminderTitle;

  /// No description provided for @settingsMorningReminderTime.
  ///
  /// In en, this message translates to:
  /// **'8:00 AM'**
  String get settingsMorningReminderTime;

  /// No description provided for @settingsEveningReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening journal reminder'**
  String get settingsEveningReminderTitle;

  /// No description provided for @settingsEveningReminderTime.
  ///
  /// In en, this message translates to:
  /// **'10:00 PM'**
  String get settingsEveningReminderTime;

  /// No description provided for @settingsRemindersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load reminders: {error}'**
  String settingsRemindersLoadError(String error);

  /// No description provided for @settingsDriveConnectError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect Drive: {error}'**
  String settingsDriveConnectError(String error);

  /// No description provided for @settingsDriveDisconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Drive?'**
  String get settingsDriveDisconnectTitle;

  /// No description provided for @settingsDriveDisconnectBody.
  ///
  /// In en, this message translates to:
  /// **'Backups already saved to Drive are left as-is. You can reconnect and back up again at any time.'**
  String get settingsDriveDisconnectBody;

  /// No description provided for @settingsDriveDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get settingsDriveDisconnect;

  /// No description provided for @settingsBackupComplete.
  ///
  /// In en, this message translates to:
  /// **'Backup complete'**
  String get settingsBackupComplete;

  /// No description provided for @settingsBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String settingsBackupFailed(String error);

  /// No description provided for @settingsDriveBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Drive backup'**
  String get settingsDriveBackupTitle;

  /// No description provided for @settingsDriveStatusLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load Drive status: {error}'**
  String settingsDriveStatusLoadError(String error);

  /// No description provided for @settingsConnectDrive.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Drive'**
  String get settingsConnectDrive;

  /// No description provided for @settingsNoBackupsYet.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get settingsNoBackupsYet;

  /// No description provided for @settingsLastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String settingsLastBackup(String date);

  /// No description provided for @settingsPendingRecords.
  ///
  /// In en, this message translates to:
  /// **'{count} record(s) not yet backed up'**
  String settingsPendingRecords(int count);

  /// No description provided for @settingsBackUpNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get settingsBackUpNow;

  /// No description provided for @settingsDisconnectDrive.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Drive'**
  String get settingsDisconnectDrive;

  /// No description provided for @settingsAutoBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-backup monthly'**
  String get settingsAutoBackupTitle;

  /// No description provided for @settingsAutoBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Runs silently on the 1st of each month'**
  String get settingsAutoBackupSubtitle;

  /// No description provided for @settingsListBackupsError.
  ///
  /// In en, this message translates to:
  /// **'Could not list backups: {error}'**
  String settingsListBackupsError(String error);

  /// No description provided for @settingsNoBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'No backups found on Drive'**
  String get settingsNoBackupsFound;

  /// No description provided for @settingsReadBackupError.
  ///
  /// In en, this message translates to:
  /// **'Could not read backup: {error}'**
  String settingsReadBackupError(String error);

  /// No description provided for @settingsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import {month} backup?'**
  String settingsImportTitle(String month);

  /// No description provided for @settingsImportBody.
  ///
  /// In en, this message translates to:
  /// **'{journals} journals, {habits} habits, {logs} logs, {tasks} tasks.\n\nThis will add data from the selected backup. Existing data will not be deleted or overwritten.'**
  String settingsImportBody(int journals, int habits, int logs, int tasks);

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsImport;

  /// No description provided for @settingsImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get settingsImporting;

  /// No description provided for @settingsImportCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get settingsImportCompleteTitle;

  /// No description provided for @settingsImportCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Added {journals} journals, {habits} habits, {logs} logs, {tasks} tasks, {money} money entries.\nSkipped {skipped} already-existing record(s).'**
  String settingsImportCompleteBody(
    int journals,
    int habits,
    int logs,
    int tasks,
    int money,
    int skipped,
  );

  /// No description provided for @settingsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String settingsImportFailed(String error);

  /// No description provided for @settingsDriveRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Drive restore'**
  String get settingsDriveRestoreTitle;

  /// No description provided for @settingsImportFromDrive.
  ///
  /// In en, this message translates to:
  /// **'Import from Drive'**
  String get settingsImportFromDrive;

  /// No description provided for @settingsDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settingsDebugTitle;

  /// No description provided for @settingsDebugTestScheduled.
  ///
  /// In en, this message translates to:
  /// **'Test notification scheduled for {time}. Leave the app — you don\'t need to keep it open.'**
  String settingsDebugTestScheduled(String time);

  /// No description provided for @settingsDebugTestError.
  ///
  /// In en, this message translates to:
  /// **'Could not schedule test notification: {error}'**
  String settingsDebugTestError(String error);

  /// No description provided for @settingsDebugScheduling.
  ///
  /// In en, this message translates to:
  /// **'Scheduling…'**
  String get settingsDebugScheduling;

  /// No description provided for @settingsDebugScheduleTest.
  ///
  /// In en, this message translates to:
  /// **'Schedule test notification (5 min)'**
  String get settingsDebugScheduleTest;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get navHabits;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get navMoney;

  /// No description provided for @navAi.
  ///
  /// In en, this message translates to:
  /// **'AI Lab'**
  String get navAi;

  /// No description provided for @writeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get writeButtonLabel;

  /// No description provided for @writeNewJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'New journal entry'**
  String get writeNewJournalEntry;

  /// No description provided for @writeNewTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get writeNewTask;

  /// No description provided for @writeNewHabit.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get writeNewHabit;

  /// No description provided for @writeNewMoneyEntry.
  ///
  /// In en, this message translates to:
  /// **'New money entry'**
  String get writeNewMoneyEntry;

  /// No description provided for @sharedUnsyncedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get sharedUnsyncedLabel;

  /// No description provided for @moneyAdviceButton.
  ///
  /// In en, this message translates to:
  /// **'✨ AI advice'**
  String get moneyAdviceButton;

  /// No description provided for @moneyAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'AI spending advice'**
  String get moneyAdviceTitle;

  /// No description provided for @moneyAdviceLoading.
  ///
  /// In en, this message translates to:
  /// **'Looking at your spending...'**
  String get moneyAdviceLoading;

  /// No description provided for @moneyAdviceSummary.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get moneyAdviceSummary;

  /// No description provided for @moneyAdviceInsights.
  ///
  /// In en, this message translates to:
  /// **'Where your money goes'**
  String get moneyAdviceInsights;

  /// No description provided for @moneyAdviceTips.
  ///
  /// In en, this message translates to:
  /// **'How to save'**
  String get moneyAdviceTips;

  /// No description provided for @moneyAdviceNoEntries.
  ///
  /// In en, this message translates to:
  /// **'Add some spending or income first to get advice.'**
  String get moneyAdviceNoEntries;

  /// No description provided for @moneyAdviceUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the AI\'s advice. Try again.'**
  String get moneyAdviceUnreadable;

  /// No description provided for @moneyAdviceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'⚠ Experimental AI advice. Use as a guide only, not financial advice.'**
  String get moneyAdviceDisclaimer;

  /// Gemini prompt (not shown to the user). Written in the app language so Gemini replies in it. {data} is the user's money summary.
  ///
  /// In en, this message translates to:
  /// **'You are a friendly personal finance advisor. Below is a summary of the user\'s recorded spending and income.\n\n{data}\n\nAnalyze where most of their spending comes from, and how they can save and optimize it.\nReply in English.\nRespond with a single JSON object only — no markdown, no explanation, no code blocks — with exactly these keys:\n\"summary\": a string of two or three sentences on the overall picture,\n\"spendingInsights\": an array of 2 to 4 strings, each about one top spending category, with its amount and share of total spending,\n\"savingTips\": an array of 3 to 5 strings, each a concrete, actionable tip to save or optimize spending, specific to this data.'**
  String moneyAdvicePrompt(String data);

  /// No description provided for @notifMoneyAdviceProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing your spending advice…'**
  String get notifMoneyAdviceProgressTitle;

  /// No description provided for @notifMoneyAdviceProgressChannelName.
  ///
  /// In en, this message translates to:
  /// **'AI advice progress'**
  String get notifMoneyAdviceProgressChannelName;

  /// No description provided for @notifMoneyAdviceProgressChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Shows while AI is working on your spending advice'**
  String get notifMoneyAdviceProgressChannelDescription;

  /// No description provided for @notifMoneyAdviceFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending advice failed'**
  String get notifMoneyAdviceFailedTitle;

  /// No description provided for @notifMoneyAdviceResultChannelName.
  ///
  /// In en, this message translates to:
  /// **'AI advice result'**
  String get notifMoneyAdviceResultChannelName;

  /// No description provided for @notifMoneyAdviceResultChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Spending advice that failed after retrying'**
  String get notifMoneyAdviceResultChannelDescription;

  /// No description provided for @moneyAdviceInProgress.
  ///
  /// In en, this message translates to:
  /// **'Still working on your advice — you\'ll get a notification if it fails.'**
  String get moneyAdviceInProgress;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
