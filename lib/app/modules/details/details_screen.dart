import 'dart:math';

import 'package:ship_track_flutter/app/models/historical_model.dart';
import 'package:ship_track_flutter/app/modules/details/details_screen_controller.dart';

import '../../../exports.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: DetailsController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(color: AppColor.white),
            elevation: 0,
            title: Text(
              'AIS Track Data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.white,
              ),
            ),
            centerTitle: true,
          ),
          body: controller.isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchHistoricalTrack();
                  },
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(10.0),
                    children: [
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.analytics,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Summary',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildStatRow(
                                'Total Calendar Days',
                                '${controller.result?.totalCalendarDays ?? 0}',
                                Icons.calendar_today,
                                Colors.grey[700]!,
                                context,
                              ),
                              const Divider(height: 16),
                              _buildStatRow(
                                'Total At-Sea Days',
                                '${controller.result?.totalAtSeaDays ?? 0}',
                                Icons.directions_boat,
                                Colors.blue[700]!,
                                context,
                              ),
                              const Divider(height: 16),
                              _buildStatRow(
                                'Total In-Port Days',
                                '${controller.result?.totalInPortDays ?? 0}',
                                Icons.anchor,
                                Colors.green[700]!,
                                context,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildTimestampCard(context, controller: controller),
                      const SizedBox(height: 15),
                      _buildSegmentsCard(context, controller: controller),
                      SizedBox(height: 70),
                    ],
                  ),
                ),
          // floatingActionButton: controller.showScrollToTop
          //     ? GestureDetector(
          //         // onTap: () {
          //         //   _scrollController.animateTo(
          //         //     0,
          //         //     duration: const Duration(milliseconds: 500),
          //         //     curve: Curves.easeInOut,
          //         //   );
          //         // },
          //         child: Container(
          //           height: 45,
          //           width: 45,
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             shape: BoxShape.circle,
          //           ),
          //           child: Center(child: Icon(Icons.arrow_upward)),
          //         ),
          //       )
          //     : null,
          floatingActionButton: Obx(
            () => controller.showScrollToTop.value
                ? GestureDetector(
                    onTap: controller.scrollToTop,
                    child: Container(
                      height: 55,
                      width: 55,
                      padding: EdgeInsets.all(10),
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Icon(Icons.arrow_upward)),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        );
      },
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    Color color,
    context,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampCard(context, {DetailsController? controller}) {
    controller?.aisPoints.where((point) {
      if (controller.signOnDate == null || controller.signOffDate == null) {
        return true;
      }
      return !point.lastPositionUTC!.isBefore(controller.signOnDate!) &&
          !point.lastPositionUTC!.isAfter(controller.signOffDate!);
    }).toList();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Timestamps & Data Range',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Sign-On Date
            if (controller?.signOnDate != null)
              _buildInfoRow(
                'Sign-On Date',
                _formatDate(controller!.signOnDate!),
                Icons.play_arrow,
                context,
              ),
            if (controller?.signOnDate != null &&
                controller?.signOffDate != null)
              const SizedBox(height: 8),
            // Sign-Off Date
            if (controller?.signOffDate != null)
              _buildInfoRow(
                'Sign-Off Date',
                _formatDate(controller!.signOffDate!),
                Icons.stop,
                context,
              ),

            const SizedBox(height: 4),
            if (controller?.aisPoints.isNotEmpty ?? false)
              _buildInfoRow(
                'Total Data Points (available)',
                '${controller?.aisPoints.length}',
                Icons.storage,
                context,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentsCard(context, {required DetailsController controller}) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.view_list,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Day Segments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${controller.result?.segments.length ?? 0} days',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if ((controller.result?.segments.length ?? 0) != 0)
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.result?.segments.length ?? 0,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final segment = controller.result?.segments[index];
                  final isAtSea = segment?.status == VesselStatus.atSea;
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.segmentDetailsScreen,
                        arguments: {
                          "date": segment.date,
                          "data": controller.aisPoints,
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isAtSea ? Colors.blue[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAtSea
                              ? Colors.blue[200]!
                              : Colors.green[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isAtSea
                                  ? Colors.blue[100]
                                  : Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              isAtSea ? Icons.directions_boat : Icons.anchor,
                              color: isAtSea
                                  ? Colors.blue[700]
                                  : Colors.green[700],
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(segment!.date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Wrap(
                                  runSpacing: 5,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAtSea
                                            ? Colors.blue[200]
                                            : Colors.green[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isAtSea ? 'AT_SEA' : 'IN_PORT',
                                        style: TextStyle(
                                          color: isAtSea
                                              ? Colors.blue[900]
                                              : Colors.green[900],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5 , height: 15,),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAtSea
                                            ? Colors.blue[200]
                                            : Colors.green[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        getReasonCodeForDate(controller.aisPoints,segment.date).name.toString(),
                                        style: TextStyle(
                                          color: isAtSea
                                              ? Colors.blue[900]
                                              : Colors.green[900],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAtSea
                                  ? Colors.blue[200]
                                  : Colors.green[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${_filterPositionsByDate(segment.date, controller)} AIS",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isAtSea
                                        ? Colors.blue[900]
                                        : Colors.green[900],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: isAtSea
                                      ? Colors.blue[900]
                                      : Colors.green[900],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          Icon(Icons.arrow_forward_ios, size: 12),
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              SizedBox(
                height: 100,
                child: Center(
                  child: Text('No data found for the selected date range'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _filterPositionsByDate(date, DetailsController controller) {
    final positions = controller.aisPoints ;

    var filteredPositions = positions.where((pos) {
      final utcString = pos.lastPositionUTC;
      if (utcString == null) return false;
      DateTime? positionDate;

      try {
        positionDate = DateTime.parse(utcString.toString()).toUtc();
      } catch (e) {
        return false;
      }

      return positionDate.year == date.year &&
          positionDate.month == date.month &&
          positionDate.day == date.day;
    }).toList();
    return filteredPositions.length.toString();
  }

  DayReasonCode getReasonCodeForDate(List<Positions> aisPoints, DateTime date) {
    // 1️⃣ Filter positions by date
    final dayPoints = aisPoints.where((pos) {
      final utc = pos.lastPositionUTC;
      if (utc == null) return false;
      return utc.year == date.year &&
          utc.month == date.month &&
          utc.day == date.day;
    }).toList();

    // 2️⃣ No data
    if (dayPoints.isEmpty) return DayReasonCode.NO_DATA;

    // 3️⃣ Insufficient points
    if (dayPoints.length < 3) return DayReasonCode.INSUFFICIENT_DATA;

    // 4️⃣ Speed calculations
    double maxSpeed = 0;
    double totalDistanceKm = 0;
    bool allZeroSpeed = true;
    List<int> timeGaps = [];

    for (int i = 0; i < dayPoints.length; i++) {
      final p = dayPoints[i];
      final speed = p.speed ?? 0;

      if (speed > maxSpeed) maxSpeed = speed;
      if (speed > 0) allZeroSpeed = false;

      // Calculate gaps
      if (i > 0 && p.lastPositionUTC != null && dayPoints[i - 1].lastPositionUTC != null) {
        final gap = p.lastPositionUTC!.difference(dayPoints[i - 1].lastPositionUTC!).inHours;
        timeGaps.add(gap);
      }

      // Calculate distance from previous point
      if (i > 0 && p.lat != null && p.lon != null && dayPoints[i - 1].lat != null && dayPoints[i - 1].lon != null) {
        totalDistanceKm += _haversineDistance(
            dayPoints[i - 1].lat!, dayPoints[i - 1].lon!, p.lat!, p.lon!);
      }
    }

    // 5️⃣ Partial data gaps
    if (timeGaps.any((gap) => gap > 6)) return DayReasonCode.PARTIAL_DATA_GAPS;

    // 6️⃣ Outlier filtered (example: impossible speeds > 60 knots)
    if (maxSpeed > 60) return DayReasonCode.OUTLIER_FILTERED;

    // 7️⃣ AT SEA logic
    if (maxSpeed > 2.0) return DayReasonCode.AT_SEA_SPEED_THRESHOLD;
    if (totalDistanceKm > 10) return DayReasonCode.AT_SEA_DISTANCE_THRESHOLD;
    if (!allZeroSpeed && maxSpeed <= 2.0) return DayReasonCode.AT_SEA_UNDERWAY_STATUS;

    // 8️⃣ IN PORT logic
    if (allZeroSpeed && totalDistanceKm < 1) return DayReasonCode.IN_PORT_STATIONARY;

    // 9️⃣ Anchored (example: stationary but not in port)
    if (allZeroSpeed && totalDistanceKm >= 1) return DayReasonCode.ANCHORED_STATUS;

    // 10️⃣ Mixed / fallback
    return DayReasonCode.MIXED_BEHAVIOR;
  }


}
double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Radius of Earth in km
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _deg2rad(double deg) => deg * pi / 180;
