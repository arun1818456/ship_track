import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ship_track_flutter/app/models/historical_model.dart';
import '../../../exports.dart';

class DetailsController extends GetxController with BaseClass {
  HistoricalModelData historicalModelData = HistoricalModelData();
  ScrollController scrollController = ScrollController();

  List<Positions> aisPoints = [];
  CalendarDayResult? result;

  DateTime? signOnDate;
  DateTime? signOffDate;
  Map? selectedVessel;

  bool isLoading = true;
  RxBool showScrollToTop = false.obs;

  @override
  void onInit() {
    super.onInit();

    final data = Get.arguments;
    selectedVessel = data['selectedVessel'];
    signOnDate = dateFormatter.parse(data['signOnDate']);
    signOffDate = dateFormatter.parse(data['signOffDate']);

    fetchHistoricalTrack();

    scrollController.addListener(() {
      showScrollToTop.value = scrollController.offset > 300;
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // -------------------------------
  // 🔹 Split Date Range (30 days)
  // -------------------------------
  List<Map<String, DateTime>> _splitDateRange(
      DateTime start,
      DateTime end,
      ) {
    final List<Map<String, DateTime>> ranges = [];
    DateTime currentStart = start;

    while (currentStart.isBefore(end)) {
      DateTime currentEnd = currentStart.add(const Duration(days: 29));
      if (currentEnd.isAfter(end)) {
        currentEnd = end;
      }

      ranges.add({
        "from": currentStart,
        "to": currentEnd,
      });

      currentStart = currentEnd.add(const Duration(days: 1));
    }

    return ranges;
  }

  // -----------------------------------
  // 🔥 Fetch Historical Track (Batched)
  // -----------------------------------
  Future<void> fetchHistoricalTrack() async {
    try {
      isLoading = true;
      aisPoints.clear();
      update();

      final apiKey = dotenv.env['APIKEY'] ?? "";

      /// 1️⃣ Split into 30-day batches
      final ranges = _splitDateRange(signOnDate!, signOffDate!);

      /// 2️⃣ Call API for each batch
      for (int i = 0; i < ranges.length; i++) {
        final range = ranges[i];

        final response = await httpRequest(
          REQUEST.get,
          "$getHistoryByDate$apiKey"
              "&imo=${selectedVessel?["IMO"]}"
              "&from=${formatDate(range["from"]!)}"
              "&to=${formatDate(range["to"]!)}",
          {},
        );
        historicalModelData=HistoricalModelData.fromJson(response);
        final tempModel = HistoricalModelData.fromJson(response);

        if (tempModel.data?.positions != null) {
          final tempPoints = tempModel.data!.positions!
              .map((p) => Positions.fromJson(p.toJson()))
              .toList();

          aisPoints.addAll(tempPoints);
          historicalModelData.data?.positions=tempPoints;
        }

        /// 🔹 Small delay to avoid rate-limit
        await Future.delayed(const Duration(milliseconds: 400));
      }

      aisPoints.sort((a, b) => a.lastPositionUTC!.compareTo(b.lastPositionUTC??DateTime.now()));
      /// 5️⃣ Calculate calendar days
      result = CalendarDayCalculator.calculateDays(
        points: aisPoints,
        signOnDate: signOnDate,
        signOffDate: signOffDate,
      );

      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
      showMyAlertDialog(message: e.toString());
    }
  }

  // -------------------------------
  // 🔼 Scroll to top helper
  // -------------------------------
  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }
}
