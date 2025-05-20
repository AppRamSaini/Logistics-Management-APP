import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logistics_app/controller/dashboard_controler.dart';
import 'package:logistics_app/helper/app_colors.dart';
import 'package:logistics_app/helper/text_style.dart';
import 'package:logistics_app/services/db_storage.dart';
import 'package:logistics_app/view/dashboard/home_page.dart';
import 'package:logistics_app/view/review_bill_history_list.dart';
import 'package:logistics_app/view/view_all_orders/notification.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DashboardController _dashboardController =
  Get.put(DashboardController());

  List pagesList = [
    HomePage(),
    ReviewBillHistoryList(),
    NotificationListPage(),
  ];

  List tabsList = [
    {"icon": Icons.home, "label": 'Home'},
    {"icon": Icons.delivery_dining, "label": 'History'},
    {"icon": Icons.notifications_none_rounded, "label": 'Notifications'},
  ];

  int selectedIndex = 0;

  bottomTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        tabsList.length,
            (index) => GestureDetector(
          onTap: () {
            _dashboardController.fetchDashboardData(context);
            _dashboardController.getShipmentNotificationsApi(context);
            _dashboardController.getShipmentsHistoryApi(context);
            setState(() {
              selectedIndex = index;
            });
          },
          child: Stack(
            clipBehavior: Clip.none, // Ensure badge is visible outside container
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: selectedIndex == index
                    ? EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                    : EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(selectedIndex == index ? 30 : 100),
                  color: selectedIndex == index
                      ? AppColors.themeColor
                      : AppColors.whiteColor,
                ),
                child: Row(
                  children: [
                    Icon(tabsList[index]['icon'],
                        color: selectedIndex == index
                            ? AppColors.whiteColor
                            : AppColors.black),
                    selectedIndex == index
                        ? Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        tabsList[index]['label'],
                        style: AppStyle.semibold_16(AppColors.whiteColor),
                      ),
                    )
                        : SizedBox()
                  ],
                ),
              ),

              // ✅ Notification Badge (Only for Notification Tab)
              if (index == 2)
                Obx(() {
                  int notiCount = _dashboardController.notificationCount.value;
                  return notiCount > 0
                      ? Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        '$notiCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                      : SizedBox();
                }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _dashboardController.getShipmentNotificationsApi(context);
    _dashboardController.fetchDashboardData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
          color: AppColors.whiteColor,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Container(
              decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(30)),
              child: bottomTabs())),
      body: pagesList[selectedIndex],
    );
  }
}
