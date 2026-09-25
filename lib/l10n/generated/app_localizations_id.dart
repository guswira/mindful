// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Mindful';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get commonEdit => 'Ubah';

  @override
  String get commonSave => 'Simpan';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonDone => 'Selesai';

  @override
  String get commonViewAll => 'lihat semua';

  @override
  String get commonToday => 'Hari ini';

  @override
  String get commonYesterday => 'Kemarin';

  @override
  String get commonArchive => 'Arsipkan';

  @override
  String get settingsLanguageTitle => 'Bahasa';

  @override
  String get settingsLanguageSystem => 'Ikuti perangkat';

  @override
  String settingsLanguageSystemWithCurrent(String language) {
    return 'Ikuti perangkat ($language)';
  }

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameBahasa => 'Bahasa Indonesia';

  @override
  String get aiErrorNotFood =>
      'Makanan tidak dikenali. Coba foto yang lebih jelas.';

  @override
  String get aiErrorNoConnection => 'Tidak ada koneksi. Cek internet kamu.';

  @override
  String get aiErrorTimeout => 'Waktu permintaan habis. Coba lagi.';

  @override
  String get aiErrorCompressFailed => 'Gagal mengompres gambar';

  @override
  String get aiNotifAnalyzingBody => 'Menganalisis makananmu…';

  @override
  String aiNotifRetryingBody(int attempt, int maxAttempts) {
    return 'Server Google lagi sibuk — mencoba lagi (percobaan $attempt/$maxAttempts)…';
  }

  @override
  String get aiScanSaved => 'Hasil pindai disimpan!';

  @override
  String get aiMainIngredients => 'Bahan utama';

  @override
  String get aiResultDisclaimer =>
      '⚠ Perkiraan AI bisa berbeda tergantung ukuran porsi, cara memasak, dan bahannya.';

  @override
  String get aiLowConfidenceWarning =>
      'Keyakinan rendah — coba foto yang lebih jelas dan dekat.';

  @override
  String get aiDismiss => 'Tutup';

  @override
  String get aiDiscard => 'Buang';

  @override
  String get aiSaveScan => 'Simpan hasil pindai';

  @override
  String get aiMacroProtein => 'Protein';

  @override
  String get aiMacroCarbs => 'Karbo';

  @override
  String get aiMacroFat => 'Lemak';

  @override
  String get aiMacroFiber => 'Serat';

  @override
  String get aiConfidenceHigh => '✓ Yakin';

  @override
  String get aiConfidenceLow => '! Kurang yakin';

  @override
  String get aiConfidenceMedium => '~ Perkiraan';

  @override
  String get aiCaloriesUnit => 'kalori';

  @override
  String get aiPerServing => 'per porsi';

  @override
  String get aiAnalyzingTitle => 'Menganalisis makananmu...';

  @override
  String get aiAnalyzingTipIngredients => 'Mengenali bahan...';

  @override
  String get aiAnalyzingTipPortions => 'Memperkirakan porsi...';

  @override
  String get aiAnalyzingTipNutrition => 'Menghitung nutrisi...';

  @override
  String get aiAnalyzingTipAlmostDone => 'Hampir selesai...';

  @override
  String get aiExperimentalTitle => 'Fitur AI Eksperimental';

  @override
  String get aiExperimentalBody =>
      'Perkiraan AI belum tentu akurat. Gunakan sebagai panduan saja — bukan saran medis.';

  @override
  String get aiFoodCheckerTitle => 'Cek Kalori Makanan';

  @override
  String get aiFoodCheckerSubtitle =>
      'Foto makananmu untuk dapat perkiraan nutrisi dari AI.';

  @override
  String get aiScanYourFood => 'Pindai makananmu';

  @override
  String get aiScanYourFoodHint =>
      'Arahkan kamera ke makanan, camilan, atau bahan';

  @override
  String get aiCheckFoodCalories => '📷  Cek kalori makanan';

  @override
  String get aiChooseFromGallery => 'Pilih dari galeri';

  @override
  String get aiUnknownFood => 'Makanan tak dikenal';

  @override
  String get aiKcal => 'kkal';

  @override
  String get aiRecentScans => 'Pindaian terbaru';

  @override
  String get aiNoScansYet =>
      'Belum ada pindaian. Coba pindai makananmu berikutnya!';

  @override
  String get aiLoadScansFailed => 'Gagal memuat pindaian';

  @override
  String get geminiErrorUnknown => 'Ada yang salah. Coba lagi.';

  @override
  String get geminiErrorInvalidKey =>
      'Kunci API Gemini tidak valid. Cek GEMINI_API_KEY di .env.';

  @override
  String get geminiErrorBusy =>
      'Layanan AI Google lagi sibuk. Coba lagi sebentar lagi.';

  @override
  String get geminiErrorQuota =>
      'Kamu sudah mencapai batas pemakaian AI. Coba lagi nanti.';

  @override
  String get geminiErrorModelUnavailable =>
      'Model AI tidak tersedia. Aplikasinya mungkin perlu diperbarui.';

  @override
  String get geminiErrorPermissionDenied =>
      'Akses AI ditolak. Cek izin kunci API kamu.';

  @override
  String get geminiErrorGeneric => 'Layanan AI bermasalah. Coba lagi nanti.';

  @override
  String get notifBudgetResetTitle => 'Bulan baru, anggaran baru';

  @override
  String get notifBudgetResetBody => 'Anggaranmu sudah direset.';

  @override
  String get notifBudgetChannelName => 'Pengingat anggaran';

  @override
  String get notifBudgetChannelDescription =>
      'Pengingat reset anggaran bulanan';

  @override
  String get notifTestTitle => 'Notifikasi uji';

  @override
  String get notifTestBody =>
      'Kalau kamu lihat ini, notifikasi berfungsi di perangkat ini.';

  @override
  String get notifDebugChannelName => 'Notifikasi uji debug';

  @override
  String get notifDebugChannelDescription =>
      'Notifikasi uji yang dipicu manual dari Pengaturan';

  @override
  String get notifJournalMorningTitle => 'Selamat pagi ☀️';

  @override
  String get notifJournalMorningBody => 'Waktunya menulis jurnal';

  @override
  String get notifJournalEveningTitle => 'Gimana harimu? 🌙';

  @override
  String get notifJournalEveningBody => 'Tulis, yuk';

  @override
  String get notifJournalChannelName => 'Pengingat jurnal';

  @override
  String get notifJournalChannelDescription =>
      'Pengingat harian untuk menulis jurnal';

  @override
  String notifHabitBody(String habitName) {
    return 'Waktunya $habitName';
  }

  @override
  String get notifHabitChannelName => 'Pengingat kebiasaan';

  @override
  String get notifHabitChannelDescription =>
      'Pengingat untuk menjalankan kebiasaanmu';

  @override
  String get notifTaskChannelName => 'Pengingat tugas';

  @override
  String get notifTaskChannelDescription =>
      'Pengingat untuk tugas yang punya tenggat';

  @override
  String get notifTaskMarkDone => 'Tandai selesai';

  @override
  String get notifFoodScanProgressTitle => 'Menganalisis makananmu…';

  @override
  String get notifFoodScanProgressChannelName => 'Progres pindai makanan';

  @override
  String get notifFoodScanProgressChannelDescription =>
      'Muncul saat foto makanan sedang dianalisis';

  @override
  String get notifFoodScanFailedTitle => 'Pindai makanan gagal';

  @override
  String get notifFoodScanResultChannelName => 'Hasil pindai makanan';

  @override
  String get notifFoodScanResultChannelDescription =>
      'Pindai makanan yang gagal setelah dicoba ulang';

  @override
  String get shortcutNewJournal => 'Jurnal Baru';

  @override
  String get shortcutNewTask => 'Tugas Baru';

  @override
  String get shortcutNewHabit => 'Kebiasaan Baru';

  @override
  String get shortcutAddMoney => 'Catat Keuangan';

  @override
  String get shortcutScanFood => 'Pindai Makanan';

  @override
  String get widgetLabelTasks => 'Tugas';

  @override
  String get widgetLabelHabits => 'Rutinitas';

  @override
  String get widgetLabelShowMe => 'Tampilkan:';

  @override
  String get widgetChooseTasks => '✅ Tugas';

  @override
  String get widgetChooseHabits => '💪 Rutinitas';

  @override
  String widgetDoneCount(int done, int total) {
    return '$done/$total selesai';
  }

  @override
  String widgetRemaining(int count) {
    return '$count tersisa';
  }

  @override
  String get habitWeekdayMon => 'Sen';

  @override
  String get habitWeekdayTue => 'Sel';

  @override
  String get habitWeekdayWed => 'Rab';

  @override
  String get habitWeekdayThu => 'Kam';

  @override
  String get habitWeekdayFri => 'Jum';

  @override
  String get habitWeekdaySat => 'Sab';

  @override
  String get habitWeekdaySun => 'Min';

  @override
  String get habitRepeatOn => 'Ulangi setiap';

  @override
  String get habitCurrentStreak => 'Runtutan saat ini';

  @override
  String get habitLongestStreak => 'Runtutan terpanjang';

  @override
  String habitSavedLocallySyncFailed(String error) {
    return 'Tersimpan di perangkat — gagal sinkron: $error';
  }

  @override
  String get habitEditTitle => 'Ubah kebiasaan';

  @override
  String get habitBuildNewTitle => 'Bangun kebiasaan baru';

  @override
  String get habitSectionIcon => 'Ikon';

  @override
  String get habitSectionColor => 'Warna';

  @override
  String get habitSectionReminder => 'Pengingat';

  @override
  String get habitSectionCustomActions => 'Aksi kustom';

  @override
  String get habitCustomActionsHint => 'Opsional — mis. Gym, Lari, Jalan kaki';

  @override
  String get habitCustomActionsEmptyHint =>
      'Kosongkan untuk satu tombol Selesai saja';

  @override
  String get habitSaveChanges => 'Simpan perubahan';

  @override
  String get habitAddHabit => 'Tambah kebiasaan';

  @override
  String get habitFallbackTitle => 'Kebiasaan';

  @override
  String habitLoadError(String error) {
    return 'Gagal memuat kebiasaan: $error';
  }

  @override
  String get habitNameHint => 'Nama kebiasaan...';

  @override
  String get habitEmptyList => 'Belum ada kebiasaan';

  @override
  String habitSyncFailed(String name, String error) {
    return 'Gagal menyinkronkan \"$name\": $error';
  }

  @override
  String get habitArchiveConfirmTitle => 'Arsipkan kebiasaan?';

  @override
  String habitArchiveConfirmBody(String name) {
    return '\"$name\" akan disembunyikan dari daftar hari ini.';
  }

  @override
  String get habitDeleteConfirmTitle => 'Hapus kebiasaan?';

  @override
  String habitDeleteConfirmBody(String name) {
    return '\"$name\" dan riwayatnya akan dihapus.';
  }

  @override
  String get habitTabTitle => 'Rutinitas';

  @override
  String habitLoadListError(String error) {
    return 'Gagal memuat kebiasaan: $error';
  }

  @override
  String get habitAddAction => '+ Tambah aksi';

  @override
  String get taskGroupUpcoming => 'Mendatang';

  @override
  String get taskGroupNoDate => 'Tanpa tanggal';

  @override
  String get taskEmptyList => 'Belum ada tugas';

  @override
  String taskCompletedSection(int count) {
    return 'Selesai ($count)';
  }

  @override
  String taskSyncFailed(String name, String error) {
    return 'Gagal menyinkronkan \"$name\": $error';
  }

  @override
  String get taskTabTitle => 'Tugas';

  @override
  String get taskAddTask => 'Tambah tugas';

  @override
  String taskLoadListError(String error) {
    return 'Gagal memuat tugas: $error';
  }

  @override
  String get taskAdded => 'Tugas ditambahkan';

  @override
  String get taskUndo => 'Urungkan';

  @override
  String get taskSheetTitle => 'Mau mengerjakan apa';

  @override
  String get taskAddDueDate => 'Tambah tenggat';

  @override
  String get taskAddReminder => 'Tambah pengingat';

  @override
  String get taskSaveChanges => 'Simpan perubahan';

  @override
  String get taskNameHint => 'Apa yang perlu dikerjakan?';

  @override
  String get taskAddSubtasks => 'Tambah subtugas';

  @override
  String get taskAddSubtask => '+ Tambah subtugas';

  @override
  String get taskSubtaskHint => 'Subtugas...';

  @override
  String get taskSubtasks => 'Subtugas';

  @override
  String taskLoadError(String error) {
    return 'Gagal memuat tugas: $error';
  }

  @override
  String get taskNotFound => 'Tugas tidak ditemukan';

  @override
  String get taskMarkAsDone => 'Tandai selesai';

  @override
  String get taskDeleteConfirmTitle => 'Hapus tugas';

  @override
  String taskDeleteConfirmBody(String name) {
    return '\"$name\" akan dihapus.';
  }

  @override
  String get homeSettingsTooltip => 'Pengaturan';

  @override
  String get homeGreetingMorning => 'Selamat pagi';

  @override
  String homeGreetingMorningName(String name) {
    return 'Selamat pagi, $name';
  }

  @override
  String get homeGreetingAfternoon => 'Selamat siang';

  @override
  String homeGreetingAfternoonName(String name) {
    return 'Selamat siang, $name';
  }

  @override
  String get homeGreetingEvening => 'Selamat malam';

  @override
  String homeGreetingEveningName(String name) {
    return 'Selamat malam, $name';
  }

  @override
  String get homeSectionTodayTasks => 'Tugas hari ini';

  @override
  String get homeSectionHabits => 'Rutinitas';

  @override
  String get homeSectionJournal => 'Jurnal';

  @override
  String get homeJournalPlanTitle => 'Tulis rencana hari ini';

  @override
  String get homeJournalPlanSubtitle =>
      'Susun tujuanmu biar harimu lebih fokus.';

  @override
  String get homeJournalPlanAction => 'Mulai';

  @override
  String get homeJournalReflectTitle => 'Tinjau apa yang terjadi';

  @override
  String get homeJournalReflectSubtitle => 'Renungkan pencapaianmu hari ini.';

  @override
  String get homeJournalReflectAction => 'Renungkan';

  @override
  String homeHabitsProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get homeStreakJournalLabel => 'Runtutan jurnal';

  @override
  String get homeStreakHabitsLabel => 'Kebiasaan hari ini';

  @override
  String get homeStreakTasksLabel => 'Tugas jatuh tempo';

  @override
  String get homeTasksEmpty => 'Apa yang perlu dikerjakan hari ini?';

  @override
  String get homeAddTask => 'Tambah tugas';

  @override
  String homeSyncFailed(String name, String error) {
    return 'Gagal menyinkronkan \"$name\": $error';
  }

  @override
  String get homeHabitsAllDone => 'Semua beres! 🎉';

  @override
  String get homeHabitsEmpty => 'Bangun kebiasaan pertamamu';

  @override
  String get homeHabitsStart => 'Mulai';

  @override
  String get homeUnsyncedBanner => 'Beberapa perubahan belum tersinkron';

  @override
  String get authSignInWithGoogle => 'Masuk dengan Google';

  @override
  String authSignInFailed(String error) {
    return 'Gagal masuk: $error';
  }

  @override
  String get journalTabTitle => 'Jurnal';

  @override
  String journalLoadFailed(String error) {
    return 'Gagal memuat catatan: $error';
  }

  @override
  String get journalSearchHint => 'Cari catatan';

  @override
  String get journalEmpty => 'Belum ada catatan';

  @override
  String get journalPhotoCamera => 'Kamera';

  @override
  String get journalPhotoGallery => 'Galeri';

  @override
  String get journalTitleHint => 'Judul...';

  @override
  String get journalBodyHint => 'Apa yang kamu pikirkan...';

  @override
  String get journalDeleteEntry => 'Hapus catatan';

  @override
  String get journalAddSheetTitle => 'Ada cerita apa';

  @override
  String get journalSaveEntry => 'Simpan catatan';

  @override
  String get journalDeleteConfirmTitle => 'Hapus catatan?';

  @override
  String get journalDeleteConfirmBody =>
      'Catatan ini beserta fotonya akan dihapus dari Supabase.';

  @override
  String get moneyAddEntryTitle => 'Ada transaksi apa';

  @override
  String get moneyEditEntryTitle => 'Ubah catatan';

  @override
  String get moneyCategoryHeading => 'Kategori';

  @override
  String get moneyNoteHint => 'Tambah catatan...';

  @override
  String get moneySaveChanges => 'Simpan perubahan';

  @override
  String get moneyTypeToggleSpending => '💸 Pengeluaran';

  @override
  String get moneyTypeToggleIncome => '💰 Pemasukan';

  @override
  String get moneyDateChange => 'Ganti';

  @override
  String get moneyTypeSpending => 'Pengeluaran';

  @override
  String get moneyTypeIncome => 'Pemasukan';

  @override
  String get moneyBudgetMonthly => 'Bulanan';

  @override
  String get moneyBudgetDaily => 'Harian';

  @override
  String get moneyBudgetSettingsTitle => 'Pengaturan anggaran';

  @override
  String get moneyMonthlyBudget => 'Anggaran bulanan';

  @override
  String get moneyDailyBudget => 'Anggaran harian';

  @override
  String get moneySaveMonthly => 'Simpan bulanan';

  @override
  String get moneySaveDaily => 'Simpan harian';

  @override
  String get moneyDeleteEntryTitle => 'Hapus catatan';

  @override
  String moneyDeleteEntryBody(String category) {
    return '\"$category\" akan dihapus.';
  }

  @override
  String get moneyTabTitle => 'Arus kas';

  @override
  String get moneyAddSpending => '+ Pengeluaran';

  @override
  String get moneyAddIncome => '+ Pemasukan';

  @override
  String get moneyEmptyBudgetPrompt => 'Atur anggaranmu untuk mulai';

  @override
  String get moneySetBudget => 'Atur anggaran';

  @override
  String get moneySetMonthly => 'Atur bulanan';

  @override
  String get moneySetDaily => 'Atur harian';

  @override
  String moneyBudgetOf(String currency, String amount) {
    return 'dari $currency $amount';
  }

  @override
  String get moneyGaugeOver => 'Lewat';

  @override
  String moneyAmountLeft(String currency, String amount) {
    return 'Sisa $currency $amount';
  }

  @override
  String get moneyPeriodThisWeek => 'Minggu ini';

  @override
  String get moneyPeriodThisMonth => 'Bulan ini';

  @override
  String get moneyPeriodAll => 'Semua';

  @override
  String get moneyNoEntriesInPeriod => 'Belum ada catatan di periode ini';

  @override
  String get moneyRecapTitle => 'Rekap';

  @override
  String get moneyRecapNoSpending => 'Belum ada pengeluaran di periode ini';

  @override
  String get moneyRecapNet => 'Bersih';

  @override
  String moneyRecapTopCategory(String emoji, String category) {
    return 'Kategori teratas: $emoji $category';
  }

  @override
  String get moneyMonthlyRemaining => 'Sisa bulanan';

  @override
  String get moneyDailyRemaining => 'Sisa harian';

  @override
  String get moneyCategoryFood => 'Makanan';

  @override
  String get moneyCategoryTransport => 'Transportasi';

  @override
  String get moneyCategoryShopping => 'Belanja';

  @override
  String get moneyCategoryHealth => 'Kesehatan';

  @override
  String get moneyCategoryEntertainment => 'Hiburan';

  @override
  String get moneyCategoryBills => 'Tagihan';

  @override
  String get moneyCategoryEducation => 'Pendidikan';

  @override
  String get moneyCategoryTravel => 'Perjalanan';

  @override
  String get moneyCategoryOther => 'Lainnya';

  @override
  String get moneyCategorySalary => 'Gaji';

  @override
  String get moneyCategoryFreelance => 'Pekerjaan lepas';

  @override
  String get moneyCategoryInvestment => 'Investasi';

  @override
  String get moneyCategoryGift => 'Hadiah';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsSignedInFallback => 'Sudah masuk';

  @override
  String settingsSignedInAs(String name) {
    return 'Masuk sebagai $name';
  }

  @override
  String get settingsSignOut => 'Keluar';

  @override
  String get settingsMorningReminderTitle => 'Pengingat jurnal pagi';

  @override
  String get settingsMorningReminderTime => '08.00';

  @override
  String get settingsEveningReminderTitle => 'Pengingat jurnal malam';

  @override
  String get settingsEveningReminderTime => '22.00';

  @override
  String settingsRemindersLoadError(String error) {
    return 'Gagal memuat pengingat: $error';
  }

  @override
  String settingsDriveConnectError(String error) {
    return 'Gagal menghubungkan Drive: $error';
  }

  @override
  String get settingsDriveDisconnectTitle => 'Putuskan Drive?';

  @override
  String get settingsDriveDisconnectBody =>
      'Cadangan yang sudah tersimpan di Drive tetap aman. Kamu bisa menghubungkan dan mencadangkan lagi kapan saja.';

  @override
  String get settingsDriveDisconnect => 'Putuskan';

  @override
  String get settingsBackupComplete => 'Pencadangan selesai';

  @override
  String settingsBackupFailed(String error) {
    return 'Pencadangan gagal: $error';
  }

  @override
  String get settingsDriveBackupTitle => 'Cadangan Drive';

  @override
  String settingsDriveStatusLoadError(String error) {
    return 'Gagal memuat status Drive: $error';
  }

  @override
  String get settingsConnectDrive => 'Hubungkan Google Drive';

  @override
  String get settingsNoBackupsYet => 'Belum ada cadangan';

  @override
  String settingsLastBackup(String date) {
    return 'Cadangan terakhir: $date';
  }

  @override
  String settingsPendingRecords(int count) {
    return '$count data belum dicadangkan';
  }

  @override
  String get settingsBackUpNow => 'Cadangkan sekarang';

  @override
  String get settingsDisconnectDrive => 'Putuskan Drive';

  @override
  String get settingsAutoBackupTitle => 'Cadangkan otomatis tiap bulan';

  @override
  String get settingsAutoBackupSubtitle =>
      'Berjalan diam-diam setiap tanggal 1';

  @override
  String settingsListBackupsError(String error) {
    return 'Gagal memuat daftar cadangan: $error';
  }

  @override
  String get settingsNoBackupsFound => 'Tidak ada cadangan di Drive';

  @override
  String settingsReadBackupError(String error) {
    return 'Gagal membaca cadangan: $error';
  }

  @override
  String settingsImportTitle(String month) {
    return 'Impor cadangan $month?';
  }

  @override
  String settingsImportBody(int journals, int habits, int logs, int tasks) {
    return '$journals jurnal, $habits kebiasaan, $logs log, $tasks tugas.\n\nData dari cadangan ini akan ditambahkan. Data yang sudah ada tidak akan dihapus atau ditimpa.';
  }

  @override
  String get settingsImport => 'Impor';

  @override
  String get settingsImporting => 'Mengimpor…';

  @override
  String get settingsImportCompleteTitle => 'Impor selesai';

  @override
  String settingsImportCompleteBody(
    int journals,
    int habits,
    int logs,
    int tasks,
    int money,
    int skipped,
  ) {
    return 'Ditambahkan $journals jurnal, $habits kebiasaan, $logs log, $tasks tugas, $money catatan keuangan.\n$skipped data yang sudah ada dilewati.';
  }

  @override
  String settingsImportFailed(String error) {
    return 'Impor gagal: $error';
  }

  @override
  String get settingsDriveRestoreTitle => 'Pulihkan dari Drive';

  @override
  String get settingsImportFromDrive => 'Impor dari Drive';

  @override
  String get settingsDebugTitle => 'Debug';

  @override
  String settingsDebugTestScheduled(String time) {
    return 'Notifikasi uji dijadwalkan pukul $time. Tinggalkan aplikasinya — tidak perlu tetap dibuka.';
  }

  @override
  String settingsDebugTestError(String error) {
    return 'Gagal menjadwalkan notifikasi uji: $error';
  }

  @override
  String get settingsDebugScheduling => 'Menjadwalkan…';

  @override
  String get settingsDebugScheduleTest => 'Jadwalkan notifikasi uji (5 menit)';

  @override
  String get navHome => 'Beranda';

  @override
  String get navTasks => 'Tugas';

  @override
  String get navHabits => 'Kebiasaan';

  @override
  String get navJournal => 'Jurnal';

  @override
  String get navMoney => 'Keuangan';

  @override
  String get navAi => 'Lab AI';

  @override
  String get writeButtonLabel => 'Tulis';

  @override
  String get writeNewJournalEntry => 'Catatan jurnal baru';

  @override
  String get writeNewTask => 'Tugas baru';

  @override
  String get writeNewHabit => 'Kebiasaan baru';

  @override
  String get writeNewMoneyEntry => 'Catatan keuangan baru';

  @override
  String get sharedUnsyncedLabel => 'Belum tersinkron';

  @override
  String get moneyAdviceButton => '✨ Saran AI';

  @override
  String get moneyAdviceTitle => 'Saran pengeluaran AI';

  @override
  String get moneyAdviceLoading => 'Lagi melihat pengeluaranmu...';

  @override
  String get moneyAdviceSummary => 'Gambaran umum';

  @override
  String get moneyAdviceInsights => 'Ke mana uangmu pergi';

  @override
  String get moneyAdviceTips => 'Cara berhemat';

  @override
  String get moneyAdviceNoEntries =>
      'Catat pengeluaran atau pemasukan dulu untuk dapat saran.';

  @override
  String get moneyAdviceUnreadable =>
      'Saran dari AI nggak bisa dibaca. Coba lagi.';

  @override
  String get moneyAdviceDisclaimer =>
      '⚠ Saran AI eksperimental. Pakai sebagai panduan saja, bukan nasihat keuangan.';

  @override
  String moneyAdvicePrompt(String data) {
    return 'Kamu adalah penasihat keuangan pribadi yang ramah. Berikut ringkasan pengeluaran dan pemasukan yang dicatat pengguna.\n\n$data\n\nAnalisis dari mana sebagian besar pengeluarannya berasal, dan bagaimana ia bisa berhemat dan mengoptimalkannya.\nBalas dalam Bahasa Indonesia dengan gaya santai (sapa pengguna dengan \"kamu\").\nBalas hanya dengan satu objek JSON — tanpa markdown, tanpa penjelasan, tanpa blok kode — dengan key persis berikut (nama key tetap dalam bahasa Inggris):\n\"summary\": string berisi dua atau tiga kalimat tentang gambaran keseluruhan,\n\"spendingInsights\": array berisi 2 sampai 4 string, masing-masing tentang satu kategori pengeluaran terbesar, dengan jumlah dan porsinya dari total pengeluaran,\n\"savingTips\": array berisi 3 sampai 5 string, masing-masing tips konkret yang bisa langsung dilakukan untuk berhemat atau mengoptimalkan pengeluaran, spesifik untuk data ini.';
  }

  @override
  String get notifMoneyAdviceProgressTitle =>
      'Lagi menyiapkan saran pengeluaranmu…';

  @override
  String get notifMoneyAdviceProgressChannelName => 'Progres saran AI';

  @override
  String get notifMoneyAdviceProgressChannelDescription =>
      'Muncul saat AI sedang menyiapkan saran pengeluaranmu';

  @override
  String get notifMoneyAdviceFailedTitle => 'Saran pengeluaran gagal';

  @override
  String get notifMoneyAdviceResultChannelName => 'Hasil saran AI';

  @override
  String get notifMoneyAdviceResultChannelDescription =>
      'Saran pengeluaran yang gagal setelah dicoba ulang';

  @override
  String get moneyAdviceInProgress =>
      'Saranmu masih diproses — kamu akan dapat notifikasi kalau gagal.';
}
