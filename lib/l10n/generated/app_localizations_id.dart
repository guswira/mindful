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
      'Perkiraan AI bisa berbeda tergantung ukuran porsi, cara memasak, dan bahannya.';

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
  String get aiConfidenceHigh => 'Yakin';

  @override
  String get aiConfidenceLow => 'Kurang yakin';

  @override
  String get aiConfidenceMedium => 'Perkiraan';

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
  String get aiCheckFoodCalories => 'Cek kalori makanan';

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
  String get notifJournalMorningTitle => 'Selamat pagi';

  @override
  String get notifJournalMorningBody => 'Waktunya menulis jurnal';

  @override
  String get notifJournalEveningTitle => 'Gimana harimu?';

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
  String get widgetChooseTasks => 'Tugas';

  @override
  String get widgetChooseHabits => 'Rutinitas';

  @override
  String get widgetRoutineDone => 'Selesai';

  @override
  String get widgetRoutinesAllDone => 'Semua beres';

  @override
  String get widgetNoRoutines => 'Belum ada rutinitas';

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
  String get habitIntroTitle => 'Rutinitas berulang tiap hari';

  @override
  String get habitIntroBody =>
      'Pilih kebiasaan kecil — jalan kaki, minum air, membaca — dan centang tiap hari. Mindful mencatat runtutanmu dan bisa mengingatkan di hari yang kamu pilih.';

  @override
  String get habitIntroAction => 'Tambah rutinitas';

  @override
  String habitSyncFailed(String name, String error) {
    return 'Gagal menyinkronkan \"$name\": $error';
  }

  @override
  String get habitArchiveConfirmTitle => 'Arsipkan kebiasaan?';

  @override
  String habitArchiveConfirmBody(String name) {
    return '\"$name\" akan disembunyikan dari daftar hari ini. Kamu bisa menemukannya di Diarsipkan, di bagian Rutinitas.';
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
  String get planTabTitle => 'Tugas & Rutinitas';

  @override
  String get planAdd => 'Tambah tugas atau kebiasaan';

  @override
  String get taskConvertToRoutine => 'Jadikan rutinitas';

  @override
  String get habitConvertTitle => 'Jadikan rutinitas';

  @override
  String habitConvertHint(String name) {
    return '\"$name\" akan dihapus dari tugas setelah rutinitas ini disimpan.';
  }

  @override
  String get habitConvertSave => 'Simpan rutinitas';

  @override
  String habitArchivedLink(int count) {
    return 'Diarsipkan ($count)';
  }

  @override
  String get habitArchivedTitle => 'Rutinitas diarsipkan';

  @override
  String get habitArchivedHint =>
      'Disembunyikan dari daftar hari ini, riwayatnya tetap disimpan. Pulihkan untuk melacaknya lagi.';

  @override
  String get habitArchivedEmpty => 'Belum ada rutinitas yang diarsipkan';

  @override
  String get habitRestore => 'Pulihkan';

  @override
  String get habitActionSummaryTitle => 'Aksi bulan ini';

  @override
  String habitActionSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kali',
    );
    return '$_temp0';
  }

  @override
  String get habitDayLoggedAs => 'Tercatat sebagai';

  @override
  String get habitDayChangeTo => 'Ubah ke';

  @override
  String get habitDayNotDone => 'Belum dilakukan';

  @override
  String get habitActionRemoved => 'Aksi yang dihapus';

  @override
  String get taskGroupUpcoming => 'Mendatang';

  @override
  String get taskGroupNoDate => 'Tanpa tanggal';

  @override
  String get taskIntroTitle => 'Kosongkan pikiran, satu tugas sekaligus';

  @override
  String get taskIntroBody =>
      'Catat yang perlu dikerjakan, beri tenggat atau pengingat, dan pecah pekerjaan besar jadi subtugas. Tugas hari ini juga muncul di beranda.';

  @override
  String get taskIntroAction => 'Tambah tugas';

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
  String get homeJournalPlanTitle => 'Tulis rencana hari ini';

  @override
  String get homeJournalPlanSubtitle =>
      'Susun tujuanmu biar harimu lebih fokus.';

  @override
  String get homeJournalPlanAction => 'Mulai';

  @override
  String get homeJournalReflectTitle => 'Tinjau hari ini';

  @override
  String get homeJournalReflectSubtitle => 'Renungkan pencapaianmu hari ini.';

  @override
  String get homeJournalReflectAction => 'Renungkan';

  @override
  String get homeTasksEmpty => 'Apa yang perlu dikerjakan hari ini?';

  @override
  String homeSyncFailed(String name, String error) {
    return 'Gagal menyinkronkan \"$name\": $error';
  }

  @override
  String get homeHabitsAllDone => 'Semua beres!';

  @override
  String get homeBeMindfulIntro =>
      'Mindful membantumu melambat dan hidup lebih terarah — rutinitas, tugas, keuangan, makanan, pernapasan, dan jurnal, semua di satu tempat yang tenang. Coba satu per satu:';

  @override
  String get homeBuildFirstRoutine => 'Bangun kebiasaan pertamamu';

  @override
  String get homeBuildFirstRoutineSubtitle =>
      'Kebiasaan kecil tiap hari lama-lama jadi besar.';

  @override
  String get homeBuildFirstRoutineAction => 'Bangun';

  @override
  String get homeMindfulSpendingTitle => 'Bijak dalam pengeluaran';

  @override
  String get homeMindfulSpendingSubtitle =>
      'Catat pengeluaranmu biar tahu ke mana uangmu pergi.';

  @override
  String get homeMindfulSpendingAction => 'Catat';

  @override
  String get homeMindfulTaskTitle => 'Bijak mengatur waktu';

  @override
  String get homeMindfulTaskSubtitle =>
      'Tambah tugas biar nggak ada yang terlewat hari ini.';

  @override
  String get homeMindfulTaskAction => 'Tambah';

  @override
  String get homeMindfulFoodTitle => 'Sadar dengan makananmu';

  @override
  String get homeMindfulFoodSubtitle =>
      'Foto makananmu dan biar AI memperkirakan gizinya.';

  @override
  String get homeMindfulFoodAction => 'Pindai';

  @override
  String get homeMindfulBreathingStepTitle => 'Bernapas dengan sadar';

  @override
  String get homeMindfulBreathingStepSubtitle =>
      'Luangkan semenit untuk latihan napas terpandu.';

  @override
  String get homeMindfulBreathingStepAction => 'Bernapas';

  @override
  String get homeMindfulJournalTitle => 'Sadar dengan pikiranmu';

  @override
  String get homeMindfulJournalSubtitle => 'Tulis entri jurnal pertamamu.';

  @override
  String get homeMindfulJournalAction => 'Tulis';

  @override
  String get homeMindfulBudgetTitle => 'Bijak dengan anggaran';

  @override
  String get homeMindfulBudgetSubtitle =>
      'Atur anggaran dan lihat sisanya tiap hari.';

  @override
  String get homeMindfulBudgetAction => 'Atur';

  @override
  String get homeUnsyncedBanner => 'Beberapa perubahan belum tersinkron';

  @override
  String get authSignInWithGoogle => 'Masuk dengan Google';

  @override
  String authSignInFailed(String error) {
    return 'Gagal masuk: $error';
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
  String get moneyTypeToggleSpending => 'Pengeluaran';

  @override
  String get moneyTypeToggleIncome => 'Pemasukan';

  @override
  String get moneyKeypadBackspace => 'Hapus';

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
  String get moneyBudgetIntroTitle => 'Atur anggaran';

  @override
  String get moneyBudgetIntroBody =>
      'Pilih jumlah bulanan atau harian. Mindful menunjukkan sisanya saat kamu belanja, jadi kamu tahu posisimu sebelum bulan berakhir.';

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
  String get moneySpendingIntroTitle => 'Catat pengeluaranmu';

  @override
  String get moneySpendingIntroBody =>
      'Catat pengeluaran dan pemasukan dalam beberapa ketukan. Mindful mengelompokkannya per hari dan kategori, jadi kamu tahu ke mana uangmu pergi.';

  @override
  String get moneySpendingIntroAction => 'Catat pengeluaran';

  @override
  String get moneyRecapTitle => 'Rekap';

  @override
  String get moneyRecapNoSpending => 'Belum ada pengeluaran di periode ini';

  @override
  String get moneyRecapNet => 'Bersih';

  @override
  String moneyRecapTopCategory(String category) {
    return 'Kategori teratas: $category';
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
  String get navTasks => 'Tugas & Rutinitas';

  @override
  String get navJournal => 'Mindfulness';

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
  String get moneyAdviceButton => 'Saran AI';

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
      'Saran AI eksperimental. Pakai sebagai panduan saja, bukan nasihat keuangan.';

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

  @override
  String recapBannerTitle(String month) {
    return 'Rekap $month kamu sudah siap';
  }

  @override
  String recapBannerTitleSoFar(String month) {
    return '$month hampir selesai — lihat rekapmu';
  }

  @override
  String get recapBannerSubtitle =>
      'Rutinitas, tugas, keuangan, dan AI sekilas';

  @override
  String get recapClose => 'Tutup rekap';

  @override
  String get recapLoadError => 'Gagal memuat rekapmu. Coba lagi nanti.';

  @override
  String get recapDone => 'Selesai';

  @override
  String recapIntroTitle(String month) {
    return '$month kamu';
  }

  @override
  String recapIntroSoFarTitle(String month) {
    return '$month kamu sejauh ini';
  }

  @override
  String get recapIntroLabel => 'rekap bulanan';

  @override
  String get recapIntroMotivation =>
      'Setiap langkah kecil yang kamu ambil bulan ini berarti. Yuk, kita lihat lagi bareng-bareng.';

  @override
  String get recapTapHint => 'Ketuk untuk lanjut';

  @override
  String get recapRoutinesTitle => 'Rutinitas';

  @override
  String get recapRoutinesHeroLabel => 'check-in rutinitas';

  @override
  String get recapStatCompletion => 'Penyelesaian';

  @override
  String get recapStatPerfectDays => 'Hari sempurna';

  @override
  String get recapStatLongestStreak => 'Runtutan terpanjang';

  @override
  String get recapStatTopRoutine => 'Rutinitas teratas';

  @override
  String recapPercent(int percent) {
    return '$percent%';
  }

  @override
  String recapDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari',
    );
    return '$_temp0';
  }

  @override
  String get recapRoutinesGreat =>
      'Konsistensimu luar biasa! Kamu lagi membangun kebiasaan yang awet — terus jaga runtutannya.';

  @override
  String get recapRoutinesGood =>
      'Bulan yang mantap! Kamu lebih sering hadir daripada absen. Sedikit dorongan lagi, bulan depan bisa jadi yang terbaik.';

  @override
  String get recapRoutinesStarting =>
      'Setiap check-in itu berarti. Pilih satu rutinitas buat difokuskan dan lihat dia tumbuh.';

  @override
  String get recapRoutinesEmpty =>
      'Belum ada rutinitas. Mulai satu kebiasaan kecil bulan depan — dua menit sehari sudah cukup.';

  @override
  String get recapTasksTitle => 'Tugas';

  @override
  String get recapTasksHeroLabel => 'tugas selesai';

  @override
  String get recapStatAdded => 'Ditambahkan';

  @override
  String get recapStatStillOpen => 'Belum selesai';

  @override
  String get recapTasksGreat =>
      'Daftar tugasmu kamu libas habis! Pertahankan semangat ini.';

  @override
  String get recapTasksGood =>
      'Progres yang keren — sebagian besar sudah beres. Terus jaga ritmenya.';

  @override
  String get recapTasksStarting =>
      'Ada tugas yang terlewat, dan itu nggak apa-apa. Mulai bulan depan dengan satu hal per hari aja.';

  @override
  String get recapTasksEmpty =>
      'Daftar baru menantimu. Tulis satu hal yang mau kamu selesaikan bulan depan.';

  @override
  String get recapMoneyTitle => 'Keuangan';

  @override
  String get recapMoneyHeroLabel => 'pengeluaran';

  @override
  String get recapStatIncome => 'Pemasukan';

  @override
  String get recapStatNet => 'Selisih';

  @override
  String get recapStatNoSpendDays => 'Hari tanpa belanja';

  @override
  String get recapStatTopCategory => 'Pengeluaran terbesar';

  @override
  String get recapStatBudgetUsed => 'Anggaran terpakai';

  @override
  String get recapMoneyGreat =>
      'Keren — pengeluaranmu tetap terkendali. Dirimu di masa depan pasti berterima kasih!';

  @override
  String get recapMoneyGood =>
      'Pemasukanmu lebih besar dari pengeluaran. Terus catat, tabungannya pasti ikut naik.';

  @override
  String get recapMoneyStarting =>
      'Pengeluaran bulan ini agak kebablasan. Sadar itu langkah pertama — dan kamu sudah mencatatnya.';

  @override
  String get recapMoneyEmpty =>
      'Belum ada catatan. Coba catat setiap pengeluaran bulan depan — hasilnya bikin melek.';

  @override
  String get recapAiTitle => 'Lab AI';

  @override
  String get recapAiHeroLabel => 'pindaian makanan';

  @override
  String get recapStatAvgCalories => 'Rata-rata per pindaian';

  @override
  String get recapStatTotalCalories => 'Total';

  @override
  String get recapStatTopFood => 'Paling sering dipindai';

  @override
  String recapKcal(int count) {
    return '$count kkal';
  }

  @override
  String get recapAiGreat =>
      'Kamu pemakan yang mindful! Tahu apa yang ada di piringmu itu kekuatan super.';

  @override
  String get recapAiGood =>
      'Rasa ingin tahumu keren! Terus pindai buat kenal lebih jauh apa yang jadi bahan bakarmu.';

  @override
  String get recapAiStarting =>
      'Awal yang bagus. Coba pindai satu makanan sehari buat lihat polanya.';

  @override
  String get recapAiEmpty =>
      'Belum coba Lab AI? Foto makananmu berikutnya dan lihat isinya.';

  @override
  String get recapAiUnavailable =>
      'Gagal memuat pindaian AI-mu — cek koneksimu lalu buka rekapnya lagi.';

  @override
  String get recapOutroTitle => 'Terus melangkah!';

  @override
  String get recapOutroLabel => 'kamu pasti bisa';

  @override
  String recapOutroBody(String month) {
    return 'Langkah kecil setiap hari jadi perubahan besar. Semoga $month jadi lebih baik lagi.';
  }

  @override
  String get recapOutroSoFarBody =>
      'Bulan ini masih ada sisa waktu — tutup dengan kuat, satu langkah kecil tiap kali.';

  @override
  String get settingsRecapRevisit => 'Lihat lagi rekap bulanan';

  @override
  String get settingsRecapRevisitSubtitle =>
      'Putar ulang rekap 12 bulan terakhir';

  @override
  String get settingsRecapPickerTitle => 'Pilih bulan';

  @override
  String settingsRecapSoFar(String month) {
    return '$month (sejauh ini)';
  }

  @override
  String get settingsBackgroundTitle => 'Latar belakang';

  @override
  String get settingsBackgroundDefault => 'Bawaan';

  @override
  String get settingsBackgroundCustom => 'Foto pilihanmu';

  @override
  String get settingsBackgroundChoose => 'Pilih dari galeri';

  @override
  String get settingsBackgroundReset => 'Kembalikan ke bawaan';

  @override
  String get settingsBackgroundUpdated => 'Latar belakang diperbarui';

  @override
  String settingsBackgroundError(String error) {
    return 'Gagal mengganti latar belakang: $error';
  }

  @override
  String get exerciseHistory => 'Riwayat';

  @override
  String exerciseShowAll(int count) {
    return 'Lihat semua ($count lagi)';
  }

  @override
  String get exerciseShowLess => 'Tampilkan lebih sedikit';

  @override
  String get exerciseBreathingSection => 'Latihan napas';

  @override
  String get exerciseActivitySection => 'Aktivitas';

  @override
  String get breathingEqualName => 'Pernapasan Seimbang';

  @override
  String get breathingEqualDescription =>
      'Tarik dan hembuskan napas dengan hitungan yang sama untuk menenangkan pikiran.';

  @override
  String get breathingBoxName => 'Pernapasan Kotak';

  @override
  String get breathingBoxDescription =>
      'Empat sisi sama — tarik, tahan, hembuskan, tahan. Bagus buat fokus.';

  @override
  String get breathing478Name => 'Pernapasan 4-7-8';

  @override
  String get breathing478Description =>
      'Tahan lama lalu hembuskan perlahan, bantu kamu rileks atau tidur.';

  @override
  String get breathingHoldTestName => 'Tes Menahan Napas';

  @override
  String get breathingHoldTestDescription =>
      'Tarik napas, lalu tahan selama kamu masih nyaman. Ketuk Hembuskan kalau sudah.';

  @override
  String get breathingCustomName => 'Kustom';

  @override
  String get breathingCustomDescription =>
      'Atur sendiri hitungan tiap langkah.';

  @override
  String breathingPatternStep(String phase, int seconds) {
    return '$phase $seconds dtk';
  }

  @override
  String breathingPatternStepOpen(String phase) {
    return '$phase selama kamu bisa';
  }

  @override
  String get breathingPhaseInhale => 'Tarik napas';

  @override
  String get breathingPhaseHold => 'Tahan';

  @override
  String get breathingPhaseExhale => 'Hembuskan';

  @override
  String get breathingPhaseRest => 'Bernapas normal';

  @override
  String get breathingStart => 'Mulai';

  @override
  String get breathingPause => 'Jeda';

  @override
  String get breathingResume => 'Lanjut';

  @override
  String get breathingFinish => 'Selesai';

  @override
  String get breathingReleaseButton => 'Hembuskan';

  @override
  String get breathingReady => 'Ketuk Mulai kalau kamu sudah siap';

  @override
  String get breathingPaused => 'Dijeda';

  @override
  String get breathingElapsed => 'Waktu berjalan';

  @override
  String get breathingCycles => 'Siklus';

  @override
  String get breathingBestHold => 'Tahan terlama';

  @override
  String breathingSessionSaved(String duration, int cycles) {
    return 'Sesi tersimpan · $duration · $cycles siklus';
  }

  @override
  String get breathingSessionTooShort =>
      'Terlalu singkat untuk disimpan — sesi di bawah 10 detik tidak dihitung.';

  @override
  String breathingSaveError(String error) {
    return 'Sesi gagal disimpan: $error';
  }

  @override
  String get breathingSoundTooltip => 'Pengaturan suara';

  @override
  String get breathingBackTooltip => 'Kembali';

  @override
  String get soundSettingsTitle => 'Suara';

  @override
  String get soundVoiceGuide => 'Panduan suara';

  @override
  String get soundVoiceGuideSubtitle =>
      'Menyebutkan tiap langkah: tarik, tahan, hembuskan';

  @override
  String get soundVoiceVolume => 'Volume suara';

  @override
  String get soundAmbience => 'Suasana';

  @override
  String get soundAmbienceVolume => 'Volume suasana';

  @override
  String get ambienceNone => 'Mati';

  @override
  String get ambienceRain => 'Hujan';

  @override
  String get ambienceOcean => 'Ombak';

  @override
  String get ambienceWind => 'Angin';

  @override
  String get ambienceDrone => 'Dengung tenang';

  @override
  String get customPatternTitle => 'Atur pernapasan';

  @override
  String get customPatternHoldAfter => 'Tahan setelah hembus';

  @override
  String get customPatternSave => 'Simpan pola';

  @override
  String get customPatternEdit => 'Ubah pola';

  @override
  String customPatternSeconds(int seconds) {
    return '$seconds dtk';
  }

  @override
  String customPatternCycle(int seconds) {
    return 'Satu siklus: $seconds dtk';
  }

  @override
  String customPatternDecrease(String step) {
    return 'Kurangi $step';
  }

  @override
  String customPatternIncrease(String step) {
    return 'Tambah $step';
  }

  @override
  String get exerciseStatSessions => 'Sesi';

  @override
  String get exerciseStatTimeSpent => 'Waktu latihan';

  @override
  String get exerciseStatStreak => 'Runtutan hari';

  @override
  String exerciseDurationHours(int hours, int minutes) {
    return '${hours}j ${minutes}m';
  }

  @override
  String exerciseDurationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String exerciseDurationSeconds(int seconds) {
    return '${seconds}d';
  }

  @override
  String exerciseCalendarDay(String date, int sessions, String duration) {
    return '$date: $sessions sesi · $duration';
  }

  @override
  String exerciseCalendarDayEmpty(String date) {
    return '$date: belum ada sesi';
  }

  @override
  String exerciseCalendarMonth(int sessions, String duration) {
    return 'Bulan ini: $sessions sesi · $duration';
  }

  @override
  String get exerciseCalendarPrevious => 'Bulan sebelumnya';

  @override
  String get exerciseCalendarNext => 'Bulan berikutnya';

  @override
  String get moodHappy => 'Senang';

  @override
  String get moodNeutral => 'Biasa saja';

  @override
  String get moodSad => 'Sedih';

  @override
  String get moodAnxious => 'Cemas';

  @override
  String get moodExcited => 'Semangat';

  @override
  String get journalTypeReview => 'Ulasan hari ini';

  @override
  String get journalTypePlan => 'Rencana';

  @override
  String get journalTypeGratitude => 'Syukur';

  @override
  String get journalTypeReviewHint => 'Gimana hari kamu tadi?';

  @override
  String get journalTypePlanHint => 'Apa yang mau kamu selesaikan hari ini?';

  @override
  String get journalTypeGratitudeHint => 'Apa yang kamu syukuri hari ini?';

  @override
  String get mindfulnessTabTitle => 'Mindfulness';

  @override
  String get journalTodaySection => 'Jurnal hari ini';

  @override
  String get journalWrite => 'Tulis';

  @override
  String get journalHistoryTitle => 'Riwayat jurnal';

  @override
  String get journalHistoryMonthEmpty => 'Belum ada entri bulan ini';

  @override
  String journalHistoryDayEmpty(String date) {
    return '$date: belum ada entri';
  }

  @override
  String get exerciseActivityTitle => 'Aktivitas latihan';

  @override
  String get homeAddTodo => 'Tambah tugas';

  @override
  String get homeAddRoutine => 'Tambah rutinitas';

  @override
  String get homeSectionMindfulness => 'Mindfulness';

  @override
  String get homeMindfulBreathingTitle => 'Latihan napas';

  @override
  String get homeMindfulBreathingSubtitle =>
      'Tenangkan diri dengan napas terpandu.';

  @override
  String get homeMindfulBreathingAction => 'Mulai';

  @override
  String get breathingPickerTitle => 'Pilih latihan napas';

  @override
  String get loginTagline => 'Harimu, sedikit lebih mindful.';

  @override
  String get loginFeatureJournalTitle => 'Jurnal harian';

  @override
  String get loginFeatureJournalBody =>
      'Rencanakan pagimu, renungkan malammu, dan catat hal yang kamu syukuri.';

  @override
  String get loginFeatureRoutinesTitle => 'Tugas & kebiasaan';

  @override
  String get loginFeatureRoutinesBody =>
      'Bangun kebiasaan yang bertahan dan selesaikan tugas, dengan pengingat biar tetap di jalur.';

  @override
  String get loginFeatureMoneyTitle => 'Belanja dengan sadar';

  @override
  String get loginFeatureMoneyBody =>
      'Catat pengeluaran dan pemasukan, dan lihat sisa anggaranmu.';

  @override
  String get loginFeatureBreathingTitle => 'Latihan napas terpandu';

  @override
  String get loginFeatureBreathingBody =>
      'Tenangkan diri dengan latihan napas, panduan suara, dan suasana yang menenangkan.';

  @override
  String get loginFeatureAiTitle => 'Cek makanan dengan AI';

  @override
  String get loginFeatureAiBody =>
      'Foto makananmu untuk perkiraan nutrisi yang cepat.';

  @override
  String get loginFeatureRecapTitle => 'Rekap bulanan';

  @override
  String get loginFeatureRecapBody =>
      'Lihat kembali bulanmu ala story, dan jaga runtutanmu.';
}
