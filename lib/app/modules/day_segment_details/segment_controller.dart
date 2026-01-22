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
      if (utcString == null ) return false;

      DateTime? positionDate;

      try {
        positionDate = DateTime.parse(
          utcString.toString(),
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
