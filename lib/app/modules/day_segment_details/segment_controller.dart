import '../../../exports.dart';
import '../../models/historical_model.dart';

class SegmentController extends GetxController with BaseClass {
  List<Positions> aisPoints = [];

  late DateTime selectedDate;

  /// Filtered positions (UI ke liye)
  List<Positions> filteredPositions = <Positions>[];

  @override
  void onInit() {
    super.onInit();

    var args = Get.arguments;

    aisPoints = args['data'];
    selectedDate = args['date'];

    _filterPositionsByDate();
  }

  void _filterPositionsByDate() {
    filteredPositions = aisPoints.where((pos) {
      final utcString = pos.lastPositionUTC;
      if (utcString == null) return false;

      DateTime? positionDate;

      try {
        positionDate = DateTime.parse(utcString.toString()).toUtc();
      } catch (e) {
        return false;
      }

      return positionDate.year == selectedDate.year &&
          positionDate.month == selectedDate.month &&
          positionDate.day == selectedDate.day;
    }).toList();
  }

  DayReasonCode getReasonCodeByIndex(int index) {
    /// Safety
    if (filteredPositions.isEmpty) {
      return DayReasonCode.NO_DATA;
    }

    if (index < 0 || index >= filteredPositions.length) {
      return DayReasonCode.NO_DATA;
    }

    /// 4️⃣ AT SEA – strong signals
    if (filteredPositions[index].speed! > 60.0) {
      return DayReasonCode.OUTLIER_FILTERED;
    }

    if (filteredPositions[index].speed! > 2.0) {
      return DayReasonCode.AT_SEA_SPEED_THRESHOLD;
    }

    if (filteredPositions[index].speed! >= 0.1 &&
        filteredPositions[index].speed! <= 2.0) {
      return DayReasonCode.AT_SEA_UNDERWAY_STATUS;
    }

    /// 6️⃣ IN PORT
    if (filteredPositions[index].speed! < 0.1) {
      return DayReasonCode.IN_PORT_STATIONARY;
    }

    /// Fallback
    return DayReasonCode.INSUFFICIENT_DATA;
  }
}
