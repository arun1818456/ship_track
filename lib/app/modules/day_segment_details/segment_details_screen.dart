import 'package:ship_track_flutter/app/modules/day_segment_details/segment_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../exports.dart';

class SegmentDetailsScreen extends StatelessWidget {
  const SegmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SegmentController>(
      init: SegmentController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: BackButton(color: AppColor.white),
          elevation: 0,
          title: Text(
            'Day Segment Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.white,
            ),
          ),
          centerTitle: true,
        ),

        body: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: controller.filteredPositions.isEmpty
              ? const Center(
                  child: Text(
                    'No historical data available for selected date',
                    style: TextStyle(fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.filteredPositions.length,
                  itemBuilder: (context, index) {
                    final pos = controller.filteredPositions[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Location
                            GestureDetector(
                              onTap: () async {
                                final lat = pos.lat;
                                final lon = pos.lon;
                                try {
                                  await launchUrl(
                                    Uri.parse(
                                      "https://www.google.com/maps/search/?api=1&query=$lat,$lon",
                                    ),
                                  );
                                } catch (e) {
                                  controller.showMyAlertDialog(
                                    message: "Could not open Google Maps $e",
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Lat: ${pos.lat}, Lon: ${pos.lon}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontSize: 16,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            /// Speed & Course
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _infoText('Speed', '${pos.speed}'),
                                _infoText('Course', '${pos.course}°'),
                                _infoText(
                                  'Heading',
                                  pos.heading?.toString() ?? '-',
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            /// Destination
                            _infoText('Destination', pos.destination ?? '-'),

                            const SizedBox(height: 6),

                            /// Time
                            _infoText(
                              'UTC Time',
                              formatTimeFromIso(
                                pos.lastPositionUTC ??
                                    DateTime.now().toIso8601String(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  String formatTimeFromIso(String isoTime) {
    final date = DateTime.parse(isoTime).toUtc();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$year-$month-$day $hour :$minute";
  }

  Widget _infoText(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title: ',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 12,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
