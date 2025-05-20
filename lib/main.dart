import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logistics_app/helper/app_colors.dart';
import 'package:logistics_app/view/splash_screen.dart';

late Size size; //  global variable  for media query size
void main() async{
  await GetStorage.init();
  runApp(const MyApp());
  configLoading();
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);
    return GetMaterialApp(
      title: 'TraceBill',
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),

      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.whiteColor,

        appBarTheme: AppBarTheme(backgroundColor:  AppColors.whiteColor,
            iconTheme: IconThemeData(color: AppColors.themeColor)),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true),
          home: const SplashScreen(),
    );
  }
}
void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 44.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}