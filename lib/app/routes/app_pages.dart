import '../../exports.dart';
import '../modules/day_segment_details/segment_details_screen.dart';

class AppPages {
  static List<GetPage> getPages = [
    GetPage(name: AppRoutes.splashScreen, page: () => SplashScreen()),
    GetPage(name: AppRoutes.homeScreen, page: () => HomeScreen()),
    GetPage(name: AppRoutes.detailsScreen, page: () => DetailsScreen()),
    GetPage(
      name: AppRoutes.segmentDetailsScreen,
      page: () => SegmentDetailsScreen(),
    ),
  ];
}
