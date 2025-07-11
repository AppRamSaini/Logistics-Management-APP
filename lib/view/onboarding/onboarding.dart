import 'package:flutter/material.dart';
import 'package:logistics_app/helper/app_assets.dart';
import 'package:logistics_app/helper/app_buttons.dart';
import 'package:logistics_app/helper/app_colors.dart';
import 'package:logistics_app/helper/app_strings.dart';
import 'package:logistics_app/helper/text_style.dart';
import 'package:logistics_app/main.dart';
import 'package:logistics_app/view/auth/driver_page.dart';
import 'package:logistics_app/view/auth/login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List sliderList = [
    AppAssets.slider,
    AppAssets.slider,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
            child: appButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => LoginPage()));
                },
                text: AppStrings.skipToMainContents)),
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Image.asset(AppAssets.appLogo,
                  // height: size.height * 0.08,
                  width: size.width * 0.5,
                  fit: BoxFit.fill)),
          SizedBox(
            height: size.height * 0.45,
            child: PageView.builder(
              controller: _pageController,
              itemCount: sliderList.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(sliderList[index],
                      height: 180, width: double.infinity, fit: BoxFit.cover),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              sliderList.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: _currentPage == index ? 12.0 : 8.0,
                height: _currentPage == index ? 12.0 : 8.0,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.themeColor
                      : AppColors.themeColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Text(
                "Welcome to your driver portal. Easily upload your BOLs, add essential details, and sign documents—all in one place. Stay organized, save time, and focus on the road ahead.",
                textAlign: TextAlign.center,
                style: AppStyle.medium_14(AppColors.black50)),
          )
        ],
      ),
    );
  }
}
