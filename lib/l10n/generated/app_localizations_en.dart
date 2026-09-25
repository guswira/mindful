// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MindFull';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonDone => 'Done';

  @override
  String get commonViewAll => 'view all';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get commonArchive => 'Archive';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String settingsLanguageSystemWithCurrent(String language) {
    return 'System default ($language)';
  }

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameBahasa => 'Bahasa Indonesia';

  @override
  String get aiErrorNotFood => 'Couldn\'t identify food. Try a clearer photo.';

  @override
  String get aiErrorNoConnection => 'No connection. Check your internet.';

  @override
  String get aiErrorTimeout => 'Request timed out. Try again.';

  @override
  String get aiErrorCompressFailed => 'Failed to compress image';

  @override
  String get aiNotifAnalyzingBody => 'Analyzing your food…';

  @override
  String aiNotifRetryingBody(int attempt, int maxAttempts) {
    return 'Google\'s servers are busy — retrying (attempt $attempt/$maxAttempts)…';
  }

  @override
  String get aiScanSaved => 'Scan saved!';

  @override
  String get aiMainIngredients => 'Main ingredients';

  @override
  String get aiResultDisclaimer =>
      '⚠ AI estimates may vary based on portion size, preparation method, and ingredients.';

  @override
  String get aiLowConfidenceWarning =>
      'Low confidence — try a clearer, closer photo.';

  @override
  String get aiDismiss => 'Dismiss';

  @override
  String get aiDiscard => 'Discard';

  @override
  String get aiSaveScan => 'Save scan';

  @override
  String get aiMacroProtein => 'Protein';

  @override
  String get aiMacroCarbs => 'Carbs';

  @override
  String get aiMacroFat => 'Fat';

  @override
  String get aiMacroFiber => 'Fiber';

  @override
  String get aiConfidenceHigh => '✓ Confident';

  @override
  String get aiConfidenceLow => '! Uncertain';

  @override
  String get aiConfidenceMedium => '~ Estimate';

  @override
  String get aiCaloriesUnit => 'calories';

  @override
  String get aiPerServing => 'per serving';

  @override
  String get aiAnalyzingTitle => 'Analyzing your food...';

  @override
  String get aiAnalyzingTipIngredients => 'Identifying ingredients...';

  @override
  String get aiAnalyzingTipPortions => 'Estimating portions...';

  @override
  String get aiAnalyzingTipNutrition => 'Calculating nutrition...';

  @override
  String get aiAnalyzingTipAlmostDone => 'Almost done...';

  @override
  String get aiExperimentalTitle => 'Experimental AI Features';

  @override
  String get aiExperimentalBody =>
      'AI estimates may not be accurate. Use as a guide only — not medical advice.';

  @override
  String get aiFoodCheckerTitle => 'Food Calorie Checker';

  @override
  String get aiFoodCheckerSubtitle =>
      'Take a photo of your food to get an AI-powered nutrition estimate.';

  @override
  String get aiScanYourFood => 'Scan your food';

  @override
  String get aiScanYourFoodHint =>
      'Point camera at a meal, snack or ingredient';

  @override
  String get aiCheckFoodCalories => '📷  Check food calories';

  @override
  String get aiChooseFromGallery => 'Choose from gallery';

  @override
  String get aiUnknownFood => 'Unknown food';

  @override
  String get aiKcal => 'kcal';

  @override
  String get aiRecentScans => 'Recent scans';

  @override
  String get aiNoScansYet => 'No scans yet. Try scanning your next meal!';

  @override
  String get aiLoadScansFailed => 'Couldn\'t load scans';

  @override
  String get geminiErrorUnknown => 'Something went wrong. Try again.';

  @override
  String get geminiErrorInvalidKey =>
      'Invalid Gemini API key. Check GEMINI_API_KEY in .env.';

  @override
  String get geminiErrorBusy =>
      'Google\'s AI service is busy right now. Try again in a moment.';

  @override
  String get geminiErrorQuota =>
      'You\'ve hit the AI usage limit. Try again later.';

  @override
  String get geminiErrorModelUnavailable =>
      'AI model unavailable. The app may need updating.';

  @override
  String get geminiErrorPermissionDenied =>
      'AI access denied. Check your API key\'s permissions.';

  @override
  String get geminiErrorGeneric => 'AI service error. Try again later.';

  @override
  String get notifBudgetResetTitle => 'New month, new budget';

  @override
  String get notifBudgetResetBody => 'Your budget has reset.';

  @override
  String get notifBudgetChannelName => 'Budget reminders';

  @override
  String get notifBudgetChannelDescription => 'Monthly budget reset reminder';

  @override
  String get notifTestTitle => 'Test notification';

  @override
  String get notifTestBody =>
      'If you see this, notification delivery works on this device.';

  @override
  String get notifDebugChannelName => 'Debug test notifications';

  @override
  String get notifDebugChannelDescription =>
      'A manually triggered test notification, from Settings';

  @override
  String get notifJournalMorningTitle => 'Good morning ☀️';

  @override
  String get notifJournalMorningBody => 'Time to write in your journal';

  @override
  String get notifJournalEveningTitle => 'How was your day? 🌙';

  @override
  String get notifJournalEveningBody => 'Write it down';

  @override
  String get notifJournalChannelName => 'Journal reminders';

  @override
  String get notifJournalChannelDescription => 'Daily journaling reminders';

  @override
  String notifHabitBody(String habitName) {
    return 'Time for $habitName';
  }

  @override
  String get notifHabitChannelName => 'Habit reminders';

  @override
  String get notifHabitChannelDescription =>
      'Reminders to complete your habits';

  @override
  String get notifTaskChannelName => 'Task reminders';

  @override
  String get notifTaskChannelDescription =>
      'Reminders for tasks with a due date';

  @override
  String get notifTaskMarkDone => 'Mark done';

  @override
  String get notifFoodScanProgressTitle => 'Analyzing your food…';

  @override
  String get notifFoodScanProgressChannelName => 'Food scan progress';

  @override
  String get notifFoodScanProgressChannelDescription =>
      'Shows while a food photo is being analyzed';

  @override
  String get notifFoodScanFailedTitle => 'Food scan failed';

  @override
  String get notifFoodScanResultChannelName => 'Food scan result';

  @override
  String get notifFoodScanResultChannelDescription =>
      'A food scan that failed after retrying';

  @override
  String get shortcutNewJournal => 'New Journal';

  @override
  String get shortcutNewTask => 'New Task';

  @override
  String get shortcutNewHabit => 'New Habit';

  @override
  String get shortcutAddMoney => 'Add Money';

  @override
  String get shortcutScanFood => 'Scan Food';

  @override
  String get widgetLabelTasks => 'Todo';

  @override
  String get widgetLabelHabits => 'Routines';

  @override
  String get widgetLabelShowMe => 'Show me:';

  @override
  String get widgetChooseTasks => '✅ Todo';

  @override
  String get widgetChooseHabits => '💪 Routines';

  @override
  String widgetDoneCount(int done, int total) {
    return '$done/$total done';
  }

  @override
  String widgetRemaining(int count) {
    return '$count remaining';
  }

  @override
  String get habitWeekdayMon => 'Mon';

  @override
  String get habitWeekdayTue => 'Tue';

  @override
  String get habitWeekdayWed => 'Wed';

  @override
  String get habitWeekdayThu => 'Thu';

  @override
  String get habitWeekdayFri => 'Fri';

  @override
  String get habitWeekdaySat => 'Sat';

  @override
  String get habitWeekdaySun => 'Sun';

  @override
  String get habitRepeatOn => 'Repeat on';

  @override
  String get habitCurrentStreak => 'Current streak';

  @override
  String get habitLongestStreak => 'Longest streak';

  @override
  String habitSavedLocallySyncFailed(String error) {
    return 'Saved locally — sync failed: $error';
  }

  @override
  String get habitEditTitle => 'Edit habit';

  @override
  String get habitBuildNewTitle => 'Build new habit';

  @override
  String get habitSectionIcon => 'Icon';

  @override
  String get habitSectionColor => 'Color';

  @override
  String get habitSectionReminder => 'Reminder';

  @override
  String get habitSectionCustomActions => 'Custom actions';

  @override
  String get habitCustomActionsHint => 'Optional — e.g. Gym, Run, Walk';

  @override
  String get habitCustomActionsEmptyHint =>
      'Leave empty for a single Done button';

  @override
  String get habitSaveChanges => 'Save changes';

  @override
  String get habitAddHabit => 'Add habit';

  @override
  String get habitFallbackTitle => 'Habit';

  @override
  String habitLoadError(String error) {
    return 'Could not load habit: $error';
  }

  @override
  String get habitNameHint => 'Habit name...';

  @override
  String get habitEmptyList => 'No habits yet';

  @override
  String habitSyncFailed(String name, String error) {
    return 'Could not sync \"$name\": $error';
  }

  @override
  String get habitArchiveConfirmTitle => 'Archive habit?';

  @override
  String habitArchiveConfirmBody(String name) {
    return '\"$name\" will be hidden from today\'s list.';
  }

  @override
  String get habitDeleteConfirmTitle => 'Delete habit?';

  @override
  String habitDeleteConfirmBody(String name) {
    return '\"$name\" and its history will be removed.';
  }

  @override
  String get habitTabTitle => 'Routines';

  @override
  String habitLoadListError(String error) {
    return 'Could not load habits: $error';
  }

  @override
  String get habitAddAction => '+ Add action';

  @override
  String get taskGroupUpcoming => 'Upcoming';

  @override
  String get taskGroupNoDate => 'No date';

  @override
  String get taskEmptyList => 'No tasks yet';

  @override
  String taskCompletedSection(int count) {
    return 'Completed ($count)';
  }

  @override
  String taskSyncFailed(String name, String error) {
    return 'Could not sync \"$name\": $error';
  }

  @override
  String get taskTabTitle => 'Todo';

  @override
  String get taskAddTask => 'Add task';

  @override
  String taskLoadListError(String error) {
    return 'Could not load tasks: $error';
  }

  @override
  String get taskAdded => 'Task added';

  @override
  String get taskUndo => 'Undo';

  @override
  String get taskSheetTitle => 'What to do';

  @override
  String get taskAddDueDate => 'Add due date';

  @override
  String get taskAddReminder => 'Add reminder';

  @override
  String get taskSaveChanges => 'Save changes';

  @override
  String get taskNameHint => 'What needs to be done?';

  @override
  String get taskAddSubtasks => 'Add subtasks';

  @override
  String get taskAddSubtask => '+ Add subtask';

  @override
  String get taskSubtaskHint => 'Subtask...';

  @override
  String get taskSubtasks => 'Subtasks';

  @override
  String taskLoadError(String error) {
    return 'Could not load task: $error';
  }

  @override
  String get taskNotFound => 'Task not found';

  @override
  String get taskMarkAsDone => 'Mark as done';

  @override
  String get taskDeleteConfirmTitle => 'Delete task';

  @override
  String taskDeleteConfirmBody(String name) {
    return '\"$name\" will be removed.';
  }

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String homeGreetingMorningName(String name) {
    return 'Good morning, $name';
  }

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String homeGreetingAfternoonName(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String homeGreetingEveningName(String name) {
    return 'Good evening, $name';
  }

  @override
  String get homeSectionTodayTasks => 'Today\'s Todo';

  @override
  String get homeSectionHabits => 'Routines';

  @override
  String get homeSectionJournal => 'Journal';

  @override
  String get homeJournalPlanTitle => 'Write today\'s plan';

  @override
  String get homeJournalPlanSubtitle => 'Outline your goals for a focused day.';

  @override
  String get homeJournalPlanAction => 'Start';

  @override
  String get homeJournalReflectTitle => 'Review what happened';

  @override
  String get homeJournalReflectSubtitle =>
      'Reflect on your day\'s accomplishments.';

  @override
  String get homeJournalReflectAction => 'Reflect';

  @override
  String homeHabitsProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get homeStreakJournalLabel => 'Journal streak';

  @override
  String get homeStreakHabitsLabel => 'Habits today';

  @override
  String get homeStreakTasksLabel => 'Tasks due';

  @override
  String get homeTasksEmpty => 'What needs to be done today?';

  @override
  String get homeAddTask => 'Add task';

  @override
  String homeSyncFailed(String name, String error) {
    return 'Could not sync \"$name\": $error';
  }

  @override
  String get homeHabitsAllDone => 'All done! 🎉';

  @override
  String get homeHabitsEmpty => 'Build your first habit';

  @override
  String get homeHabitsStart => 'Start';

  @override
  String get homeUnsyncedBanner => 'Some changes haven\'t synced yet';

  @override
  String get authSignInWithGoogle => 'Sign in with Google';

  @override
  String authSignInFailed(String error) {
    return 'Sign in failed: $error';
  }

  @override
  String get journalTabTitle => 'Journal';

  @override
  String journalLoadFailed(String error) {
    return 'Couldn\'t load entries: $error';
  }

  @override
  String get journalSearchHint => 'Search entries';

  @override
  String get journalEmpty => 'No entries yet';

  @override
  String get journalPhotoCamera => 'Camera';

  @override
  String get journalPhotoGallery => 'Gallery';

  @override
  String get journalTitleHint => 'Title...';

  @override
  String get journalBodyHint => 'What\'s on your mind...';

  @override
  String get journalDeleteEntry => 'Delete entry';

  @override
  String get journalAddSheetTitle => 'What\'s going on';

  @override
  String get journalSaveEntry => 'Save entry';

  @override
  String get journalDeleteConfirmTitle => 'Delete entry?';

  @override
  String get journalDeleteConfirmBody =>
      'This removes the entry and its photos from Supabase.';

  @override
  String get moneyAddEntryTitle => 'What\'s going on';

  @override
  String get moneyEditEntryTitle => 'Edit entry';

  @override
  String get moneyCategoryHeading => 'Category';

  @override
  String get moneyNoteHint => 'Add a note...';

  @override
  String get moneySaveChanges => 'Save changes';

  @override
  String get moneyTypeToggleSpending => '💸 Spending';

  @override
  String get moneyTypeToggleIncome => '💰 Income';

  @override
  String get moneyDateChange => 'Change';

  @override
  String get moneyTypeSpending => 'Spending';

  @override
  String get moneyTypeIncome => 'Income';

  @override
  String get moneyBudgetMonthly => 'Monthly';

  @override
  String get moneyBudgetDaily => 'Daily';

  @override
  String get moneyBudgetSettingsTitle => 'Budget settings';

  @override
  String get moneyMonthlyBudget => 'Monthly budget';

  @override
  String get moneyDailyBudget => 'Daily budget';

  @override
  String get moneySaveMonthly => 'Save monthly';

  @override
  String get moneySaveDaily => 'Save daily';

  @override
  String get moneyDeleteEntryTitle => 'Delete entry';

  @override
  String moneyDeleteEntryBody(String category) {
    return '\"$category\" will be removed.';
  }

  @override
  String get moneyTabTitle => 'Cashflow';

  @override
  String get moneyAddSpending => '+ Spending';

  @override
  String get moneyAddIncome => '+ Income';

  @override
  String get moneyEmptyBudgetPrompt => 'Set your budget to get started';

  @override
  String get moneySetBudget => 'Set budget';

  @override
  String get moneySetMonthly => 'Set Monthly';

  @override
  String get moneySetDaily => 'Set Daily';

  @override
  String moneyBudgetOf(String currency, String amount) {
    return 'of $currency $amount';
  }

  @override
  String get moneyGaugeOver => 'Over';

  @override
  String moneyAmountLeft(String currency, String amount) {
    return '$currency $amount left';
  }

  @override
  String get moneyPeriodThisWeek => 'This Week';

  @override
  String get moneyPeriodThisMonth => 'This Month';

  @override
  String get moneyPeriodAll => 'All';

  @override
  String get moneyNoEntriesInPeriod => 'No entries in this period';

  @override
  String get moneyRecapTitle => 'Recap';

  @override
  String get moneyRecapNoSpending => 'No spending yet this period';

  @override
  String get moneyRecapNet => 'Net';

  @override
  String moneyRecapTopCategory(String emoji, String category) {
    return 'Top category: $emoji $category';
  }

  @override
  String get moneyMonthlyRemaining => 'Monthly remaining';

  @override
  String get moneyDailyRemaining => 'Daily remaining';

  @override
  String get moneyCategoryFood => 'Food';

  @override
  String get moneyCategoryTransport => 'Transport';

  @override
  String get moneyCategoryShopping => 'Shopping';

  @override
  String get moneyCategoryHealth => 'Health';

  @override
  String get moneyCategoryEntertainment => 'Entertainment';

  @override
  String get moneyCategoryBills => 'Bills';

  @override
  String get moneyCategoryEducation => 'Education';

  @override
  String get moneyCategoryTravel => 'Travel';

  @override
  String get moneyCategoryOther => 'Other';

  @override
  String get moneyCategorySalary => 'Salary';

  @override
  String get moneyCategoryFreelance => 'Freelance';

  @override
  String get moneyCategoryInvestment => 'Investment';

  @override
  String get moneyCategoryGift => 'Gift';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSignedInFallback => 'Signed in';

  @override
  String settingsSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsMorningReminderTitle => 'Morning journal reminder';

  @override
  String get settingsMorningReminderTime => '8:00 AM';

  @override
  String get settingsEveningReminderTitle => 'Evening journal reminder';

  @override
  String get settingsEveningReminderTime => '10:00 PM';

  @override
  String settingsRemindersLoadError(String error) {
    return 'Couldn\'t load reminders: $error';
  }

  @override
  String settingsDriveConnectError(String error) {
    return 'Could not connect Drive: $error';
  }

  @override
  String get settingsDriveDisconnectTitle => 'Disconnect Drive?';

  @override
  String get settingsDriveDisconnectBody =>
      'Backups already saved to Drive are left as-is. You can reconnect and back up again at any time.';

  @override
  String get settingsDriveDisconnect => 'Disconnect';

  @override
  String get settingsBackupComplete => 'Backup complete';

  @override
  String settingsBackupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get settingsDriveBackupTitle => 'Drive backup';

  @override
  String settingsDriveStatusLoadError(String error) {
    return 'Couldn\'t load Drive status: $error';
  }

  @override
  String get settingsConnectDrive => 'Connect Google Drive';

  @override
  String get settingsNoBackupsYet => 'No backups yet';

  @override
  String settingsLastBackup(String date) {
    return 'Last backup: $date';
  }

  @override
  String settingsPendingRecords(int count) {
    return '$count record(s) not yet backed up';
  }

  @override
  String get settingsBackUpNow => 'Back up now';

  @override
  String get settingsDisconnectDrive => 'Disconnect Drive';

  @override
  String get settingsAutoBackupTitle => 'Auto-backup monthly';

  @override
  String get settingsAutoBackupSubtitle =>
      'Runs silently on the 1st of each month';

  @override
  String settingsListBackupsError(String error) {
    return 'Could not list backups: $error';
  }

  @override
  String get settingsNoBackupsFound => 'No backups found on Drive';

  @override
  String settingsReadBackupError(String error) {
    return 'Could not read backup: $error';
  }

  @override
  String settingsImportTitle(String month) {
    return 'Import $month backup?';
  }

  @override
  String settingsImportBody(int journals, int habits, int logs, int tasks) {
    return '$journals journals, $habits habits, $logs logs, $tasks tasks.\n\nThis will add data from the selected backup. Existing data will not be deleted or overwritten.';
  }

  @override
  String get settingsImport => 'Import';

  @override
  String get settingsImporting => 'Importing…';

  @override
  String get settingsImportCompleteTitle => 'Import complete';

  @override
  String settingsImportCompleteBody(
    int journals,
    int habits,
    int logs,
    int tasks,
    int money,
    int skipped,
  ) {
    return 'Added $journals journals, $habits habits, $logs logs, $tasks tasks, $money money entries.\nSkipped $skipped already-existing record(s).';
  }

  @override
  String settingsImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get settingsDriveRestoreTitle => 'Drive restore';

  @override
  String get settingsImportFromDrive => 'Import from Drive';

  @override
  String get settingsDebugTitle => 'Debug';

  @override
  String settingsDebugTestScheduled(String time) {
    return 'Test notification scheduled for $time. Leave the app — you don\'t need to keep it open.';
  }

  @override
  String settingsDebugTestError(String error) {
    return 'Could not schedule test notification: $error';
  }

  @override
  String get settingsDebugScheduling => 'Scheduling…';

  @override
  String get settingsDebugScheduleTest => 'Schedule test notification (5 min)';

  @override
  String get navHome => 'Home';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navHabits => 'Habits';

  @override
  String get navJournal => 'Journal';

  @override
  String get navMoney => 'Money';

  @override
  String get navAi => 'AI Lab';

  @override
  String get writeButtonLabel => 'Write';

  @override
  String get writeNewJournalEntry => 'New journal entry';

  @override
  String get writeNewTask => 'New task';

  @override
  String get writeNewHabit => 'New habit';

  @override
  String get writeNewMoneyEntry => 'New money entry';

  @override
  String get sharedUnsyncedLabel => 'Not synced yet';

  @override
  String get moneyAdviceButton => '✨ AI advice';

  @override
  String get moneyAdviceTitle => 'AI spending advice';

  @override
  String get moneyAdviceLoading => 'Looking at your spending...';

  @override
  String get moneyAdviceSummary => 'Overview';

  @override
  String get moneyAdviceInsights => 'Where your money goes';

  @override
  String get moneyAdviceTips => 'How to save';

  @override
  String get moneyAdviceNoEntries =>
      'Add some spending or income first to get advice.';

  @override
  String get moneyAdviceUnreadable =>
      'Couldn\'t read the AI\'s advice. Try again.';

  @override
  String get moneyAdviceDisclaimer =>
      '⚠ Experimental AI advice. Use as a guide only, not financial advice.';

  @override
  String moneyAdvicePrompt(String data) {
    return 'You are a friendly personal finance advisor. Below is a summary of the user\'s recorded spending and income.\n\n$data\n\nAnalyze where most of their spending comes from, and how they can save and optimize it.\nReply in English.\nRespond with a single JSON object only — no markdown, no explanation, no code blocks — with exactly these keys:\n\"summary\": a string of two or three sentences on the overall picture,\n\"spendingInsights\": an array of 2 to 4 strings, each about one top spending category, with its amount and share of total spending,\n\"savingTips\": an array of 3 to 5 strings, each a concrete, actionable tip to save or optimize spending, specific to this data.';
  }

  @override
  String get notifMoneyAdviceProgressTitle => 'Preparing your spending advice…';

  @override
  String get notifMoneyAdviceProgressChannelName => 'AI advice progress';

  @override
  String get notifMoneyAdviceProgressChannelDescription =>
      'Shows while AI is working on your spending advice';

  @override
  String get notifMoneyAdviceFailedTitle => 'Spending advice failed';

  @override
  String get notifMoneyAdviceResultChannelName => 'AI advice result';

  @override
  String get notifMoneyAdviceResultChannelDescription =>
      'Spending advice that failed after retrying';

  @override
  String get moneyAdviceInProgress =>
      'Still working on your advice — you\'ll get a notification if it fails.';
}
