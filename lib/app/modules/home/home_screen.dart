import '../../../exports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'AIS Track Analysis',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.white,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: ListView(
              physics: ClampingScrollPhysics(),
              children: [
                /// Header
                const Text(
                  'Select Vessel & Dates',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: TextEditingController(
                    text:
                        "${controller.selectedVessel?["name"]} , IMO:${controller.selectedVessel?["IMO"]}",
                  ),
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Found Vessel',
                    prefixIcon: const Icon(Icons.directions_boat),
                  ),
                ),
                const SizedBox(height: 15),

                /// Vessel Dropdown
                // DropdownButtonFormField<String>(
                //   value: controller.selectedVessel?['name'],
                //   borderRadius: BorderRadius.circular(25),
                //   decoration: const InputDecoration(
                //     labelText: 'Vessel',
                //     hintText: "Select a vessel",
                //     prefixIcon: Icon(Icons.directions_boat),
                //   ),
                //   items: vesselList
                //       .map(
                //         (entry) => DropdownMenuItem<String>(
                //           value: entry['name'],
                //           child: Padding(
                //             padding: const EdgeInsets.symmetric(horizontal: 16),
                //             child: Text(entry['name']),
                //           ),
                //         ),
                //       )
                //       .toList(),
                //   onChanged: (value) {
                //     controller.selectedVessel = vesselList.firstWhere(
                //       (e) => e['name'] == value,
                //     );
                //     controller.update();
                //   },
                // ),
                //
                // const SizedBox(height: 15),

                /// Sign-On Date
                _buildDateField(
                  label: 'Sign-On',
                  date: controller.signOnDate,
                  onTap: () => controller.selectSignOnDate(context),
                ),

                const SizedBox(height: 15),

                /// Sign-Off Date
                _buildDateField(
                  label: 'Sign-Off',
                  date: controller.signOffDate,
                  onTap: () => controller.selectSignOffDate(context),
                ),

                const SizedBox(height: 20),

                /// Fetch Button
                CustomButton(
                  loading: controller.isLoading,
                  text: 'Fetch AIS Data',
                  onPressed: controller.onFetchData,
                ),

                const SizedBox(height: 20),

                /// Recent Searches
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Search',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (controller.recentListData.isNotEmpty)
                      GestureDetector(
                        onTap: controller.clearRecent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.appColor.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Clear All",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                if (controller.recentListData.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.recentListData.length,
                    itemBuilder: (_, index) {
                      final item = controller.recentListData[index];
                      return RecentCard(
                        shipName: item["selectedVessel"]["name"].toString(),
                        signOnDate: item["signOnDate"].toString(),
                        signOffDate: item["signOffDate"].toString(),
                        onTap: () => controller.onTapRecentCard(item),
                      );
                    },
                  )
                else
                  SizedBox(
                    height: Get.height / 3,
                    child: const Center(child: Text('No recent searches')),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Date Field Widget
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ).copyWith(labelText: label),
      controller: TextEditingController(
        text: date != null ? _formatDate(date) : '',
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
