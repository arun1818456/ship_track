import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'exports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget with BaseClass {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        keyBoardOff(context);
      },
      child: GetMaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColor.appColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColor.appColor,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        color: AppColor.backgroundColor,
        title: 'Ship Track',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splashScreen,
        getPages: AppPages.getPages,
      ),
    );
  }
}

printWrapped(text) {
  JsonEncoder.withIndent('  ').convert(text);
}
