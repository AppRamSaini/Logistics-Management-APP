import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logistics_app/controller/dashboard_controler.dart';

import 'package:logistics_app/helper/app_colors.dart';
import 'package:logistics_app/helper/global_file.dart';

import 'package:logistics_app/helper/text_style.dart';

import 'package:logistics_app/model/notification_modal.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => NotificationListState();
}

class NotificationListState extends State<NotificationListPage> {
  final DashboardController _dashboardController =
      Get.put(DashboardController());

  Future<void> refreshData() async {
    _dashboardController.getShipmentNotificationsApi(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(text: 'Notifications'),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: RefreshIndicator(
          onRefresh: refreshData,
          child: FutureBuilder<List<NotificationList>?>(
            future: _dashboardController.getShipmentNotificationsApi(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator.adaptive());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text("Error: ${snapshot.error}",
                        style: AppStyle.medium_16(AppColors.red)));
              } else if (snapshot.hasData) {
                return snapshot.data!.isEmpty
                    ? Center(child: Text("No Notifications Found!"))
                    : ListView.builder(
                        itemCount: snapshot
                            .data!.length, // Shipment की लंबाई के आधार पर
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (_, index) => Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors.black10),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.whiteColor),
                          child: Column(
                            children: [
                              ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 0),
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.blueGrey,
                                    child: Icon(
                                      Icons.notifications_none,
                                      size: 18,
                                      color: AppColors.themeColor,
                                    ),
                                  ),
                                  title: Text('New Shipment "${snapshot.data![index].shipmentId!.name??''}" has been Assigned',
                                      style: AppStyle.semibold_14(
                                          AppColors.black)),
                                  subtitle: Text(
                                      snapshot.data![index].text ??
                                          'The customer left a review',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: AppStyle.medium_12(
                                          AppColors.black50))),
                              Divider(color: AppColors.black10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      formatDate(snapshot.data![index].createdAt
                                          .toString()),
                                      style:
                                          AppStyle.medium_14(AppColors.black)),
                                  TextButton(
                                      onPressed: () async {
                                        await _dashboardController
                                            .readNotificationAPI(
                                                context,
                                                snapshot.data![index].id
                                                    .toString());

                                        setState(() {});
                                      },
                                      child: Text("Mark As Read",
                                          style: AppStyle.semibold_14(
                                              AppColors.themeColor)))
                                ],
                              )
                            ],
                          ),
                        ),
                      );
              } else {
                return Center(child: Text("No Notifications Found!"));
              }
            },
          ),
        ),
      ),
    );
  }
}
