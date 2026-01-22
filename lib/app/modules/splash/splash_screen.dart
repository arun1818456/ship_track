import '../../../exports.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) => Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColor.appColorsSplash1,
                AppColor.appColorsSplash2,
              ],
            ),
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Transform.translate(
                    offset: Offset(0, (1 - scale) * 50), // bottom → up feel
                    child: child,
                  ),
                );
              },

              /// 🚢 SHIP IN WATER ICON
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 130),
                    child: Icon(
                      Icons.waves,
                      size: Get.width * 0.22,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Icon(
                    Icons.directions_boat_filled,
                    size: Get.width * 0.22,
                    color: Colors.white,
                  ),
                ],
              ),

              // 👉 If later you want logo instead:
              // child: Image.asset(AppImages.appLogo, width: Get.width * 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
