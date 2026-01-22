
import '../../../exports.dart';
import '../../models/historical_model.dart';

class SegmentController extends GetxController with BaseClass{
  HistoricalModelData historicalModelData = HistoricalModelData();

  late DateTime selectedDate;

  /// Filtered positions (UI ke liye)
  List<Positions> filteredPositions = <Positions>[];

  @override
  void onInit() {
    super.onInit();

    var args = Get.arguments;

    historicalModelData = args['data'];
    selectedDate = args['date'];

    _filterPositionsByDate();
  }

  void _filterPositionsByDate() {
    final positions = historicalModelData.data?.positions ?? [];

    filteredPositions = positions.where((pos) {
      final utcString = pos.lastPositionUTC;
      if (utcString == null || utcString.isEmpty) return false;

      DateTime? positionDate;

      try {
        positionDate = DateTime.parse(
          utcString.contains('T')
              ? utcString
              : utcString.replaceFirst(' ', 'T'),
        ).toUtc();
      } catch (e) {
        return false;
      }

      return positionDate.year == selectedDate.year &&
          positionDate.month == selectedDate.month &&
          positionDate.day == selectedDate.day;
    }).toList();
  }

}
