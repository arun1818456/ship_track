import '../../../exports.dart';

/// DetailsScreen shows AIS track data, STCW summary, and day segments.
/// It uses [DetailsController] to fetch and manage the data.

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailsController>(
      init: DetailsController(),
      builder: (controller) {
        return Scaffold(
          // App Bar with title and back button
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

          // Main body
          body: controller.isLoading
              ? Center(child: CircularProgressIndicator()) // Loading state
              : RefreshIndicator(
                  onRefresh: controller.fetchHistoricalTrack,
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(10.0),
                    children: [
                      // Summary Card (Calendar, At-Sea, In-Port)
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
                                '${controller.calendarDayCalculation?.totalCalendarDays ?? 0}',
                                Icons.calendar_today,
                                Colors.grey[700]!,
                                context,
                              ),
                              const Divider(height: 16),
                              _buildStatRow(
                                'Total At-Sea Days',
                                '${controller.calendarDayCalculation?.totalAtSeaDays ?? 0}',
                                Icons.directions_boat,
                                Colors.blue[700]!,
                                context,
                              ),
                              const Divider(height: 16),
                              _buildStatRow(
                                'Total In-Port Days',
                                '${controller.calendarDayCalculation?.totalInPortDays ?? 0}',
                                Icons.anchor,
                                Colors.green[700]!,
                                context,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Timestamps & Date Range Card
                      _buildTimestampCard(context, controller: controller),

                      const SizedBox(height: 15),

                      // STCW Summary Card
                      _buildStcwSummaryCard(context, controller: controller),

                      const SizedBox(height: 15),

                      // Day Segments Card
                      _buildSegmentsCard(context, controller: controller),

                      const SizedBox(height: 70),
                    ],
                  ),
                ),

          // Scroll-to-top FAB
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

  /// STCW Service Summary Card
  Widget _buildStcwSummaryCard(
    BuildContext context, {
    required DetailsController controller,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'STCW Service Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // STCW Stats
            _buildStatRow(
              'Actual Sea Days',
              (controller.calendarDayCalculation?.totalActualSeaDays ?? 0)
                  .toString(),
              Icons.directions_boat,
              Colors.blue,
              context,
            ),
            const Divider(),
            _buildStatRow(
              'Standby Days',
              (controller.calendarDayCalculation?.totalStandByDays ?? 0)
                  .toString(),
              Icons.pause_circle,
              Colors.orange,
              context,
            ),
            const Divider(),
            _buildStatRow(
              'Yard Days',
              (controller.calendarDayCalculation?.totalYardDays ?? 0)
                  .toString(),
              Icons.construction,
              Colors.brown,
              context,
            ),
            const Divider(),
            _buildStatRow(
              'Unknown Days',
              (controller.calendarDayCalculation?.totalUnknownDays ?? 0)
                  .toString(),
              Icons.help_outline,
              Colors.grey,
              context,
            ),
            const Divider(thickness: 1.2),
            _buildStatRow(
              'Total Countable',
              "--",
              Icons.check_circle,
              Colors.green,
              context,
            ),
          ],
        ),
      ),
    );
  }

  /// Generic row for displaying label, value and icon
  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
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

  /// Card showing timestamps, sign-on/sign-off, and total AIS data points
  Widget _buildTimestampCard(
    BuildContext context, {
    DetailsController? controller,
  }) {
    // Filter AIS points within sign-on/off dates
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
            // Header
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
                controller!.formatDate(controller.signOnDate!),
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
                controller!.formatDate(controller.signOffDate!),
                Icons.stop,
                context,
              ),

            const SizedBox(height: 4),

            // Total AIS points
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

  /// Card showing all day segments with tap navigation to segment details
  Widget _buildSegmentsCard(
    BuildContext context, {
    required DetailsController controller,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with total segments count
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
                    '${controller.calendarDayCalculation?.segments.length ?? 0} days',
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

            // Segment List
            if ((controller.calendarDayCalculation?.segments.length ?? 0) != 0)
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    controller.calendarDayCalculation?.segments.length ?? 0,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final segment =
                      controller.calendarDayCalculation?.segments[index];
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                  isAtSea
                                      ? Icons.directions_boat
                                      : Icons.anchor,
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
                                      controller.formatDate(segment!.date),
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
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
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
                                        SizedBox(width: 5, height: 15),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isAtSea
                                                ? Colors.blue[200]
                                                : Colors.green[200],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            controller
                                                .calendarDayCalculation!
                                                .segments[index]
                                                .reasonCode
                                                .name
                                                .toString(),
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
                                      "${controller.calendarDayCalculation?.segments[index].pointCount} AIS",
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
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: getColor(
                                  controller
                                      .calendarDayCalculation!
                                      .segments[index]
                                      .stcwDayResult,
                                ),
                              ),
                              color: getColor(
                                controller
                                    .calendarDayCalculation!
                                    .segments[index]
                                    .stcwDayResult,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Service :- ${controller.calendarDayCalculation?.segments[index].stcwDayResult.name.toString() ?? ""}",
                              style: TextStyle(
                                color: getColor(
                                  controller
                                      .calendarDayCalculation!
                                      .segments[index]
                                      .stcwDayResult,
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // const SizedBox(height: 5),
                          // Text("Standby Day: 3 of 14"),
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

  /// Info Row used inside timestamp card
  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
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

  Color getColor(StcwDayResult stcwCalculations) {
    switch (stcwCalculations) {
      case StcwDayResult.actual_sea:
        return Colors.blue;
      case StcwDayResult.stand_by:
        return Colors.orange;
      case StcwDayResult.yard:
        return Colors.brown;
      case StcwDayResult.unknown:
        return Colors.grey;
    }
  }
}
