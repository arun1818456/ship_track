import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ship_track_flutter/app/models/historical_model.dart';
import '../../../exports.dart';
import '../../models/day_segment_model.dart';
import '../../models/stcw_model.dart';
import '../../services/ais_classifier.dart';

class DetailsController extends GetxController with BaseClass {
  HistoricalModelData historicalModelData = HistoricalModelData();
  ScrollController scrollController = ScrollController();
  STCWModel? stcwModel;
  List<Positions> aisPoints = [];
  CalendarDaysResult? calendarDayCalculation;

  DateTime? signOnDate;
  DateTime? signOffDate;
  Map? selectedVessel;

  bool isLoading = true;
  RxBool showScrollToTop = false.obs;

  List storedDataList = [
    {
      "vessel": {"name": "NITA K II", "IMO": "1007940", "MMSI": "339435000"},
      "date": DateTime.now(),
      "status": StcwDayResult.stand_by,
    },
  ];

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

  // -----------------------------------
  // 🔥 Fetch Historical Track
  // -----------------------------------
  Future<void> fetchHistoricalTrack() async {
    try {
      isLoading = true;
      aisPoints.clear();
      update();

      final apiKey = dotenv.env['APIKEY'] ?? "";

      /// 1️⃣ Split into 30-day batches
      final ranges = _splitDateRange(signOnDate!, signOffDate!);

      // 2️⃣ Call API for each batch
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
        // historicalModelData = HistoricalModelData.fromJson(response);
        final tempModel = HistoricalModelData.fromJson(response);

        if (tempModel.data?.positions != null) {
          final tempPoints = tempModel.data!.positions!
              .map((p) => Positions.fromJson(p.toJson()))
              .toList();

          aisPoints.addAll(tempPoints);
          historicalModelData.data?.positions = tempPoints;
        }

        /// 🔹 Small delay to avoid rate-limit
        await Future.delayed(const Duration(milliseconds: 400));
      }
      /////-------------------------
      // historicalModelData = HistoricalModelData.fromJson(dataApi);
      // aisPoints =
      //     historicalModelData.data?.positions!
      //         .map((p) => Positions.fromJson(p.toJson()))
      //         .toList() ??
      //     [];

      ////-------------------test data for testing

      aisPoints.sort(
        (a, b) =>
            a.lastPositionUTC!.compareTo(b.lastPositionUTC ?? DateTime.now()),
      );

      /// 5️⃣ Calculate calendar days
      calendarDayCalculation = CalendarDayCalculator.calculateDays(
        points: aisPoints,
        signOnDate: signOnDate ?? DateTime.now().subtract(Duration(days: 25)),
        signOffDate: signOffDate ?? DateTime.now(),
      );
      setCalculateStcwRule();
      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
      showMyAlertDialog(message: e.toString());
    }
  }

  // -------------------------------
  // 🔹 Split Date Range (30 days)
  // -------------------------------
  List<Map<String, DateTime>> _splitDateRange(DateTime start, DateTime end) {
    final List<Map<String, DateTime>> ranges = [];
    DateTime currentStart = start;

    while (currentStart.isBefore(end)) {
      DateTime currentEnd = currentStart.add(const Duration(days: 29));
      if (currentEnd.isAfter(end)) {
        currentEnd = end;
      }

      ranges.add({"from": currentStart, "to": currentEnd});

      currentStart = currentEnd.add(const Duration(days: 1));
    }
    return ranges;
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

  setCalculateStcwRule() async {

    final segments = calendarDayCalculation?.segments ?? [];

    for (int i = 0; i < segments.length; i++) {

      DaySegment element = segments[i];

      // 🔹 1. Replace stored data
      for (var data in storedDataList) {
        if (data["vessel"]["IMO"] == selectedVessel?["IMO"] &&
            element.date == data["date"]) {

          element.stcwDayResult = data["status"];
        }
      }

      // 🔹 2. Apply countable rule
      DaySegment updatedSegment =
      AISClassifier().countAbleDays(segments, element);

      // 🔹 3. IMPORTANT → update list item
      segments[i] = updatedSegment;
    }

    update();
  }

}
