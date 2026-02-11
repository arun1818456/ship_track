
import '../constant/enums.dart';

class STCWModel {
  final int totalActualSeaDays;
  final int totalStandByDays;
  final int totalYardDays;
  final int totalUnknownDays;
  final bool isCountedDay;
  final StcwDayResult status;

  STCWModel({

    required this.totalActualSeaDays,
    required this.totalStandByDays,
    required this.totalYardDays,
    required this.totalUnknownDays,
    required this.status,
    required this.isCountedDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_actual_sea_days': totalActualSeaDays,
      'total_stand_by_days': totalStandByDays,
      'total_yard_days': totalYardDays,
      'total_unknown_days': totalUnknownDays,
      'status': status.name,
      'is_counted_day': isCountedDay,
    };
  }
}
