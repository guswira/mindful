/// Supabase table and storage bucket names. See SPEC.md Supabase schema.
class SupabaseConstants {
  const SupabaseConstants._();

  static const String journalEntriesTable = 'journal_entries';
  static const String habitsTable = 'habits';
  static const String habitLogsTable = 'habit_logs';
  static const String tasksTable = 'tasks';
  static const String moneyEntriesTable = 'money_entries';
  static const String budgetSettingsTable = 'budget_settings';
  static const String foodScansTable = 'food_scans';
  static const String photosBucket = 'photos';
}
