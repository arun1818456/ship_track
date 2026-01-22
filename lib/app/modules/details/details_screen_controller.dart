import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ship_track_flutter/app/models/historical_model.dart';

import '../../../exports.dart';

class DetailsController extends GetxController with BaseClass {
  HistoricalModelData historicalModelData = HistoricalModelData();
  ScrollController scrollController = ScrollController();
  List<AISPoint> aisPoints = [];
  CalendarDayResult? result;
  DateTime? signOnDate;
  DateTime? signOffDate;
  Map? selectedVessel;
  bool isLoading = true;
  RxBool showScrollToTop = false.obs;

  @override
  void onInit() {
    super.onInit();
    var data = Get.arguments;
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

  Future<void> fetchHistoricalTrack() async {
    try {
      isLoading = true;
      update();

      String apiKey = dotenv.env['APIKEY'] ?? "";
      final response = await httpRequest(
        REQUEST.get,
        "$getHistoryByDate$apiKey&imo=${selectedVessel?["IMO"]}"
        "&from=${formatDate(signOnDate!)}"
        "&to=${formatDate(signOffDate!)}",
        {},
      );

      /// 1️⃣ Parse full response
      historicalModelData = HistoricalModelData.fromJson(response);

      /// 2️⃣ Convert historical positions → AISPoint
      aisPoints = historicalModelData.data!.positions!
          .map((p) => AISPoint.fromJson(p.toJson()))
          .toList();

      /// 3️⃣ Sort by time (VERY IMPORTANT)
      aisPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      /// 4️⃣ Calculate calendar day result
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
      print("Historical Error: $e");
    }
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }
}
