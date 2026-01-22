import 'package:intl/intl.dart';

import '../../exports.dart';

mixin BaseClass {
  final storage = GetStorage();
  final dateFormatter = DateFormat('yyyy-MM-dd');

  String formatDate(DateTime date) {
    return dateFormatter.format(date);
  }

  keyBoardOff(context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  void showMyAlertDialog({
    String title = "Alert",
    required String message,
    VoidCallback? onOkTap,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0), // Like Cupertino
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              const Divider(height: 1),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    Future.delayed(Duration(milliseconds: 200), () {
                      if (onOkTap != null) {
                        onOkTap();
                      }
                    });
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatUtcToLocal(String utcDateTime) {
    final DateTime utc = DateTime.parse(utcDateTime); // parses as UTC
    final DateTime local = utc.toLocal(); // convert to device time

    return "${local.day.toString().padLeft(2, '0')}-"
        "${local.month.toString().padLeft(2, '0')}-"
        "${local.year} "
        "${local.hour.toString().padLeft(2, '0')}:"
        "${local.minute.toString().padLeft(2, '0')}";
  }
}
