import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ship_track_flutter/app/models/historical_model.dart';
import 'package:ship_track_flutter/app/models/saved_local_data_model.dart';
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

  List<LocalSavedDataModel> localSavedList = [];

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    final data = Get.arguments;
    selectedVessel = data['selectedVessel'];
    signOnDate = dateFormatter.parse(data['signOnDate']);
    signOffDate = dateFormatter.parse(data['signOffDate']);

    fetchHistoricalTrack();

    scrollController.addListener(() {
      showScrollToTop.value = scrollController.offset > 300;
    });
  }

  // ---------------- LOCAL STORAGE ----------------

  void _loadSavedData() {
    final List<dynamic>? storedData = storage.read(LocalKeys.storedAis);
    if (storedData != null) {
      localSavedList = storedData
          .map(
            (item) =>
                LocalSavedDataModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      update();
    }
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
      for (var data in localSavedList) {
        if (data.vesselIMO == selectedVessel?["IMO"] &&
            element.date == data.date) {
          element.stcwDayResult = data.status!;
          element.confirm=data.confirm??false;
        }
      }

      // 🔹 2. Apply countable rule
      DaySegment updatedSegment = AISClassifier().countAbleDays(
        segments,
        element,
      );

      // 🔹 3. IMPORTANT → update list item
      segments[i] = updatedSegment;
    }
    calculateTotals();
    update();
  }

  void editTap(BuildContext context, selectedSegment) {
    StcwDayResult? selectedValue;
    selectedValue = selectedSegment.stcwDayResult;
    DateTime selectedDate = selectedSegment.date;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: AppColor.white,
              title: Text("Select Service Type"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<StcwDayResult>(
                    title: Text("Stand by day"),
                    value: StcwDayResult.stand_by,
                    groupValue: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                  ),
                  RadioListTile<StcwDayResult>(
                    title: Text("Yard day"),
                    value: StcwDayResult.yard,
                    groupValue: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                  ),
                  RadioListTile<StcwDayResult>(
                    title: Text("Actual sea day"),
                    value: StcwDayResult.actual_sea,
                    groupValue: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        textColor: AppColor.appColor,
                        color: AppColor.transparent,
                        isBorderEnable: true,
                        borderColor: AppColor.appColor,
                        text: "Cancel",
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          Get.back();
                          onChangedService(selectedValue!, selectedDate);
                        },

                        text: "Save",
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
  // on  service Status changes

  onChangedService(StcwDayResult selectedValue, DateTime selectedDate) {
    final String? imo = selectedVessel?["IMO"];

    int index = localSavedList.indexWhere(
      (element) => element.vesselIMO == imo && element.date == selectedDate,
    );

    if (index != -1) {
      // ✅ Replace existing status
      localSavedList[index].status = selectedValue;
    } else {
      // ✅ Add new entry
      localSavedList.add(
        LocalSavedDataModel(
          vesselIMO: imo,
          date: selectedDate,
          status: selectedValue,
        ),
      );
    }

    // Save updated list to storage
    storage.write(
      LocalKeys.storedAis,
      localSavedList.map((e) => e.toJson()).toList(),
    );

    // Recalculate STCW totals
    setCalculateStcwRule();

    // Now close the dialog
  }

  //////
  void calculateTotals() {
    int totalCountableDay = 0;
    int totalUnCountableDay = 0;
    int totalActualSeaDays = 0;
    int totalStandByDays = 0;
    int totalYardDays = 0;
    int totalUnknownDays = 0;

    final segments = calendarDayCalculation?.segments ?? [];

    for (var segment in segments) {
      if (segment.isCountedDay == true) {
        totalCountableDay++;
      } else {
        totalUnCountableDay++;
      }

      switch (segment.stcwDayResult) {
        case StcwDayResult.actual_sea:
          totalActualSeaDays++;
          break;
        case StcwDayResult.stand_by:
          totalStandByDays++;
          break;
        case StcwDayResult.yard:
          totalYardDays++;
          break;
        case StcwDayResult.unknown:
          totalUnknownDays++;
          break;
      }
    }

    calendarDayCalculation = CalendarDaysResult(
      totalCalendarDays: calendarDayCalculation!.totalCalendarDays,
      totalAtSeaDays: calendarDayCalculation!.totalAtSeaDays,
      totalInPortDays: calendarDayCalculation!.totalInPortDays,
      segments: calendarDayCalculation!.segments,
      totalActualSeaDays: totalActualSeaDays,
      totalStandByDays: totalStandByDays,
      totalYardDays: totalYardDays,
      totalUnknownDays: totalUnknownDays,
      totalCountableDay: totalCountableDay,
      totalUnCountableDay: totalUnCountableDay,
    );
  }

  ////// conformation  Actual sea Day Service
  onTapYes(DaySegment daySegment) async {
    final String? imo = selectedVessel?["IMO"];

    /// 1️⃣ Update only that segment (NO update() inside loop)
    final segments = calendarDayCalculation?.segments ?? [];

    for (var element in segments) {
      if (element.date == daySegment.date) {
        print(">>>>> next ");
        element.confirm = true;
        break;
      }
    }


    /// 2️⃣ Update local storage list
    int index = localSavedList.indexWhere(
      (element) => element.vesselIMO == imo && element.date == daySegment.date,
    );
    print(">>>>>>${index}");
    if (index != -1) {
      localSavedList[index].confirm = true;
    } else {
      localSavedList.add(
        LocalSavedDataModel(
          vesselIMO: imo,
          date: daySegment.date,
          status: daySegment.stcwDayResult,
          confirm: true,
        ),
      );
    }

    /// 3️⃣ Save storage (this is sync, keep once)
    storage.write(
      LocalKeys.storedAis,
      localSavedList.map((e) => e.toJson()).toList(),
    );
    setCalculateStcwRule();
    update();
  }
}
