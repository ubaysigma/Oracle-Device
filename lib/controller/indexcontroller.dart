import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndexController extends GetxController {
  // Storage keys matching web storage conventions
  static const String keyDate = 'DAILY_PRESCRIPT_DEVICE_DATE';
  static const String keyText = 'DAILY_PRESCRIPT_DEVICE_TEXT';

  // State observables
  final RxBool hasReceived = false.obs;
  final RxString prescriptText = ''.obs;
  final RxString currentDate = ''.obs;
  final RxBool isLoading = true.obs;

  // 1. Core Logic Arrays (The Index Prescripts)
  static const List<String> actions = [
    "Laksanakan",
    "Eksekusi",
    "Selesaikan",
    "Konsumsi",
    "Tonton dan cerna",
    "Push",
    "Pelajari",
    "Rapihkan",
    "Tinggalkan sejenak",
  ];

  static const List<String> targets = [
    "minimal 1 commit kode ke repositori GitHub",
    "satu porsi sayuran hijau",
    "ibadah wajibmu",
    "satu video pembelajaran pengembangan perangkat lunak",
    "dokumentasi framework atau bahasa pemrograman baru",
    "gelas berisi air putih penuh",
    "meja komputermu dari barang yang tidak perlu",
    "satu struktur database atau UI yang sedang kamu rancang",
    "bacaan literatur atau satu chapter ceritamu",
  ];

  static const List<String> conditions = [
    "sebelum kamu membuka aplikasi game apa pun hari ini.",
    "tanpa menyentuh layar handphone selama prosesnya berlangsung.",
    "sambil mempertahankan postur punggung yang lurus tegak.",
    "sebelum matahari terbenam.",
    "dengan keheningan total, tanpa mendengarkan musik.",
    "sebelum kamu membuka kembali tab browser yang tidak penting.",
    "sebagai bentuk kedisiplinan absolut.",
    "segera setelah kamu membaca pesan ini.",
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

    final actionIndex = (nextRandom() * actions.length).floor();
    final targetIndex = (nextRandom() * targets.length).floor();
    final conditionIndex = (nextRandom() * conditions.length).floor();

    final action = actions[actionIndex];
    final target = targets[targetIndex];
    final condition = conditions[conditionIndex];

    return '$action $target $condition';
  }

  // Action triggered by clicking "- Click to Receive -"
  Future<void> receive() async {
    if (hasReceived.value) return;

    final today = currentDate.value.isNotEmpty ? currentDate.value : getLocalDateString();
    final result = generateDailyPrescript(today);

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

