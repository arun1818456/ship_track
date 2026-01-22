import '../../exports.dart';

class RecentCard extends StatelessWidget {
  final String shipName;
  final String signOnDate;
  final String signOffDate;
  final GestureTapCallback onTap;
  const RecentCard({
    super.key,
    required this.shipName,
    required this.signOnDate,
    required this.signOffDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.black.withOpacity(0.3)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🚢 Header – Ship Name
              Row(
                children: [
                  const Icon(Icons.directions_boat_filled, color: AppColor.appColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shipName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),

              /// 📅 Bottom – Sign On / Sign Off
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dateColumn(title: "Sign-On", date: signOnDate),
                  _dateColumn(title: "Sign-Off", date: signOffDate),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable Date Column
  Widget _dateColumn({required String title, required String date}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
