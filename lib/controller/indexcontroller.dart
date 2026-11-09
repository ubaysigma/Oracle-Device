import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndexController extends GetxController {
  // Storage keys matching web storage conventions
  static const String keyDate = 'DAILY_PRESCRIPT_DEVICE_DATE';
  static const String keyText = 'DAILY_PRESCRIPT_DEVICE_TEXT';
  static const String keyDeviceId = 'PRESCRIPT_DEVICE_ID';

  // State observables
  final RxBool hasReceived = false.obs;
  final RxString prescriptText = ''.obs;
  final RxString currentDate = ''.obs;
  final RxBool isLoading = true.obs;
  String deviceId = '';

  // 1. Prescript Directives Catalog (General, Natural & Mandatory Directives)
  static const List<String> prescripts = [
    "Minum dua gelas air putih dingin segera setelah kamu membaca preskripsi ini.",
    "Rapikan tempat tidur dan ruang sekitarmu sebelum memulai aktivitas hari ini.",
    "Tuntaskan satu kewajiban atau tugas terberatmu sebelum matahari terbenam.",
    "Hindari membuka media sosial selama dua jam ke depan sebagai bentuk kendali diri.",
    "Berjalan kakilah selama minimal lima belas menit di bawah sinar matahari.",
    "Luangkan waktu dua puluh menit untuk membaca buku dalam keheningan total.",
    "Lakukan peregangan tubuh selama sepuluh menit sambil menjaga postur punggung tetap tegak.",
    "Hubungi satu orang terdekat atau keluargamu dan tanyakan kabar mereka dengan tulus.",
    "Singkirkan ponsel dari meja makanmu dan nikmati makananmu tanpa menatap layar.",
    "Catat tiga target terpenting yang wajib kamu capai sebelum siang hari.",
    "Konsumsi satu porsi buah atau sayuran segar hari ini demi kesehatan fisikmu.",
    "Bersihkan berkas-berkas atau tab browser yang tidak terpakai dari perangkatmu.",
    "Jangan mengeluhkan hal apa pun yang berada di luar kendalimu sepanjang hari ini.",
    "Istirahatkan matamu dari layar gawai setiap tiga puluh menit sekali.",
    "Duduklah dalam keheningan selama lima menit tanpa memegang ponsel atau mendengarkan audio.",
    "Tidurlah tiga puluh menit lebih awal dari jadwal biasamu malam nanti.",
    "Ucapkan terima kasih secara langsung kepada seseorang yang telah membantumu hari ini.",
    "Tuliskan satu hal penting yang kamu syukuri hari ini sebelum kamu tidur.",
    "Hindari minuman manis berlebih sepanjang hari ini sebagai bentuk disiplin diri.",
    "Selesaikan satu urusan penting yang selama beberapa hari terakhir terus kamu tunda.",
    "Ambil napas dalam-dalam sebanyak lima kali setiap kali kamu merasa mulai lelah atau jenuh.",
    "Dengarkan lawan bicaramu dengan penuh perhatian tanpa memotong perkataannya sama sekali.",
    "Matikan notifikasi aplikasi yang tidak penting selama proses kerjamu berlangsung.",
    "Lakukan satu kebaikan kecil tanpa perlu menceritakannya kepada orang lain.",
    "Evaluasi pengeluaran dan seluruh tindakanmu hari ini sebelum menutup hari.",
    "Luangkan sepuluh menit untuk menuliskan isi pikiranmu ke dalam selembar kertas.",
    "Tinggalkan tempat tidurmu seketika begitu kamu bangun tanpa menunda-nunda.",
    "Kurangi bicara hal-hal yang tidak bermanfaat dan fokuslah pada tindakan nyata.",
    "Susun rencana kegiatanmu untuk hari esok sebelum kamu beranjak tidur malam ini.",
    "Berikan senyuman atau sapaan hangat kepada orang pertama yang berpapasan denganmu.",
  ];

  @override
  void onInit() {
    super.onInit();
    initDailyState();
  }

  // Format local date as YYYY-MM-DD
  String getLocalDateString() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // Initialize and check once-a-day status in LocalStorage
  Future<void> initDailyState() async {
    final today = getLocalDateString();
    currentDate.value = today;

    final prefs = await SharedPreferences.getInstance();

    // Get or generate persistent unique device ID (Opsi B: Unique per device)
    var savedDeviceId = prefs.getString(keyDeviceId);
    if (savedDeviceId == null || savedDeviceId.isEmpty) {
      final random = math.Random();
      final partA = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
      final partB = random.nextInt(0xFFFFFF).toRadixString(36);
      savedDeviceId = 'DEV_${partA}_$partB';
      await prefs.setString(keyDeviceId, savedDeviceId);
    }
    deviceId = savedDeviceId;

    final savedDate = prefs.getString(keyDate);
    final savedText = prefs.getString(keyText);

    if (savedDate == today && savedText != null && savedText.isNotEmpty) {
      prescriptText.value = savedText;
      hasReceived.value = true;
    } else {
      hasReceived.value = false;
      prescriptText.value = '';
    }

    isLoading.value = false;
  }

  // 32-bit Integer Math.imul simulation for cross-platform deterministic RNG
  static int _imul(int a, int b) {
    final aHi = (a >> 16) & 0xFFFF;
    final aLo = a & 0xFFFF;
    final bHi = (b >> 16) & 0xFFFF;
    final bLo = b & 0xFFFF;
    return ((aLo * bLo) + (((aHi * bLo + aLo * bHi) & 0xFFFF) << 16)) & 0xFFFFFFFF;
  }

  // 32-bit FNV-1a Hash of the seed string
  static int _hashSeed(String str) {
    int hash = 2166136261;
    for (int i = 0; i < str.length; i++) {
      hash ^= str.codeUnitAt(i);
      hash = _imul(hash, 16777619);
    }
    return hash;
  }

  // Mulberry32 Pseudo-Random Number Generator (PRNG)
  String generateDailyPrescript(String dateSeed) {
    int seed = _hashSeed(dateSeed);

    double nextRandom() {
      seed = (seed + 0x6D2B79F5) & 0xFFFFFFFF;
      int t = seed;
      t = _imul(t ^ (t >> 15), t | 1);
      t = (t ^ (t + _imul(t ^ (t >> 7), (t | 61) & 0xFFFFFFFF))) & 0xFFFFFFFF;
      int res = (t ^ (t >> 14)) & 0xFFFFFFFF;
      return res / 4294967296.0;
    }

    final index = (nextRandom() * prescripts.length).floor();
    return prescripts[index];
  }

  // Action triggered by clicking "- Click to Receive -"
  Future<void> receive() async {
    if (hasReceived.value) return;

    final today = currentDate.value.isNotEmpty ? currentDate.value : getLocalDateString();
    // Opsi B: Seed combines Date + Device ID so every device receives a unique daily prescript
    final combinedSeed = '$today-$deviceId';
    final result = generateDailyPrescript(combinedSeed);

    prescriptText.value = result;
    hasReceived.value = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyDate, today);
    await prefs.setString(keyText, result);
  }

  // Reset daily state for testing/debugging
  Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyDate);
    await prefs.remove(keyText);
    prescriptText.value = '';
    hasReceived.value = false;
  }
}

