import 'package:intl/intl.dart';
import '../../../exports.dart';
import '../../constant/vessel_data.dart';

class HomeController extends GetxController with BaseClass {
  // ---------------- VARIABLES ----------------
  List<Map<String, dynamic>> recentListData = [];
  bool isLoading = false;
  Map<String, dynamic>? selectedVessel;
  DateTime? signOnDate;
  DateTime? signOffDate;

  // ---------------- LIFECYCLE ----------------
  @override
  void onInit() {
    super.onInit();

    final now = DateTime.now();
    signOnDate = _normalizeDate(now.subtract(const Duration(days: 30)));
    signOffDate = _normalizeDate(now.subtract(const Duration(days: 1)));
    selectedVessel = vesselList.first;
    _loadRecentData();
  }

  // ---------------- LOCAL STORAGE ----------------

  void _loadRecentData() {
    final List<dynamic>? storedData = storage.read(LocalKeys.recentKey);
    if (storedData != null) {
      recentListData = List<Map<String, dynamic>>.from(storedData);
      update();
    }
  }

  // ---------------- HELPERS ----------------
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void saveRecentData() {
    storage.write(LocalKeys.recentKey, recentListData);
  }

  // ---------------- DATE PICKERS ----------------

  /// Sign-On Date Picker
  Future<void> selectSignOnDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: signOnDate ?? DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      signOnDate = _normalizeDate(picked);
      signOffDate = _normalizeDate(picked.add(Duration(days: 30)));

      // Auto adjust sign-off if invalid
      if (signOffDate != null && signOffDate!.isBefore(signOnDate!)) {
        signOffDate = signOnDate;
      }

      update();
    }
  }

  /// Sign-Off Date Picker
  Future<void> selectSignOffDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: signOffDate ?? DateTime.now().subtract(Duration(days: 1)),
      firstDate: signOnDate ?? DateTime(2019),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      signOffDate = _normalizeDate(picked);
      update();
    }
  }

  // ---------------- ACTIONS ----------------

  Future<void> onFetchData() async {
    if (selectedVessel == null || signOnDate == null || signOffDate == null) {
      showMyAlertDialog(message: "Please select all fields");
      return;
    }

    // impliment here if selected date is more then 1 month show error
    if (isMoreThanOneMonth(signOnDate!, signOffDate!)) {
      showMyAlertDialog(message: "Date should not be more than one month");
      return;
    }

    isLoading = true;
    update();
    final Map<String, dynamic> payload = {
      "selectedVessel": selectedVessel,
      "signOnDate": formatDate(signOnDate!),
      "signOffDate": formatDate(signOffDate!),
    };
    Get.toNamed(AppRoutes.detailsScreen, arguments: payload);
    Future.delayed(const Duration(seconds: 1), () {
      /// 🔍 Remove duplicate entry if exists
      recentListData.removeWhere(
        (item) =>
            item['selectedVessel'] == payload['selectedVessel'] &&
            item['signOnDate'] == payload['signOnDate'] &&
            item['signOffDate'] == payload['signOffDate'],
      );

      ///   /// ⬆️ Add new data at top
      recentListData.insert(0, payload);
      if (recentListData.length > 3) {
        recentListData.removeLast();
      }
      saveRecentData();

      isLoading = false;
      update();
    });
  }

  void onTapRecentCard(Map<String, dynamic> value) {
    Get.toNamed(AppRoutes.detailsScreen, arguments: value);
  }

  void clearRecent() {
    recentListData.clear();
    storage.remove(LocalKeys.recentKey);
    update();
  }

  bool isMoreThanOneMonth(DateTime start, DateTime end) {
    final DateTime oneMonthLater = DateTime(
      start.year,
      start.month + 1,
      start.day,
    );
    return end.isAfter(oneMonthLater);
  }
}
