import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logistics_app/controller/auth_controller.dart';
import 'package:logistics_app/controller/dashboard_controler.dart';
import 'package:logistics_app/helper/app_colors.dart';
import 'package:logistics_app/helper/dialogs.dart';
import 'package:logistics_app/helper/global_file.dart';
import 'package:logistics_app/helper/text_style.dart';
import 'package:logistics_app/main.dart';
import 'package:logistics_app/model/dashboard_shipment_model.dart';
import 'package:logistics_app/model/get_driver_details.dart';
import 'package:logistics_app/services/db_storage.dart';
import 'package:logistics_app/view/delete_account.dart';
import 'package:logistics_app/view/shipment_details.dart';
import 'package:logistics_app/view/view_all_orders/orders.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StreamController<ShipmentDashboardData> _streamController =
      StreamController();

  final DashboardController _dashboardController =
      Get.put(DashboardController());
  final AuthController _authController = Get.put(AuthController());
  @override
  void initState() {
    super.initState();
    onRefresh();
  }

  Future onRefresh() async {
    _dashboardController.fetchDashboardData(context).then((shipmentData) {
      _streamController.add(shipmentData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: StreamBuilder<ShipmentDashboardData>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data!"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No data available!"));
          } else {
            ShipmentDashboardData data = snapshot.data!;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: Column(
                children: [
                  FutureBuilder<DriverDetails?>(
                    future: _authController.fetchDriver(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.themeColor,
                            child: Text('LG',
                                style: AppStyle.medium_16(AppColors.whiteColor)),
                          ),
                          title: Text("Loading...",
                              style: AppStyle.medium_16(AppColors.black)),
                          subtitle: Text("Fetching driver details...",
                              style: AppStyle.medium_14(AppColors.black)),
                          trailing: _buildSwitchRow(context),
                        );
                      }

                      if (snapshot.hasError) {
                        // 🔴 Error State
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.error, color: Colors.red),
                          title: Text("Error loading driver",
                              style: AppStyle.medium_14(AppColors.black)),
                          subtitle: Text(snapshot.error.toString(),
                              style: AppStyle.normal_12(AppColors.black)),
                          trailing: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {}); // Retry by rebuilding
                            },
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        // ⚠️ No Data / Null Response
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.warning, color: Colors.orange),
                          title: Text("No driver data found",
                              style: AppStyle.medium_14(AppColors.black)),
                          subtitle: Text("Please try again or contact support.",
                              style: AppStyle.normal_12(AppColors.black)),
                          trailing: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {}); // Trigger refresh
                            },
                          ),
                        );
                      }

                      // ✅ Success State
                      final DriverDetails data = snapshot.data!;
                      final String initials = getInitials(data.userResult?.name ?? "NA");

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: GestureDetector(
                          onTap: () => driverDetailsDialog(context, data),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.themeColor,
                            child: Text(initials,
                                style: AppStyle.medium_16(AppColors.whiteColor)),
                          ),
                        ),
                        title: Text(
                          capitalizeFirstLetter(data.userResult?.name ?? "N/A"),
                          style: AppStyle.medium_14(AppColors.black),
                        ),
                        subtitle: Text(
                          capitalizeFirstLetter(data.driver?.companyName ?? 'N/A'),
                          style: AppStyle.medium_12(AppColors.black),
                        ),
                        trailing: _buildSwitchRow(context),
                      );
                    },
                  ),

                  Expanded(
                      child: RefreshIndicator(
                    onRefresh: onRefresh,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: _shipmentContainer(
                                    "Total \nin-transit",
                                    AppColors.themeColor,
                                    AppColors.whiteColor,
                                    data.statusData!.transit.toString(),Icons.fire_truck_outlined),
                              ),
                              SizedBox(width: size.width * 0.03),
                              Flexible(
                                child: _shipmentContainer(
                                    "Delivered Shipment",
                                    AppColors.black,
                                    AppColors.whiteColor,
                                    data.statusData!.delivered.toString(),Icons.delivery_dining),
                              ),
                            ],
                          ),
                          SizedBox(height: size.width * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: _shipmentContainer(
                                    "Pending Delivery",
                                    AppColors.black10,
                                    AppColors.black,
                                    data.statusData!.pending.toString(),Icons.access_time),
                              ),
                              SizedBox(width: size.width * 0.03),
                              Flexible(
                                child: _shipmentContainer(
                                    "Total \nShipment",
                                    AppColors.blueGrey,
                                    AppColors.black,
                                    data.shipment.toString(),Icons.shutter_speed),
                              ),
                            ],
                          ),
                          SizedBox(height: size.width * 0.04),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('All Order',
                                  style: AppStyle.semibold_18(AppColors.black)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        color: AppColors.themeColor)),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => Orders())),
                                  child: Text('View All',
                                      style: AppStyle.medium_12(
                                          AppColors.themeColor)),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: size.width * 0.04),
                          data.shipmentData!.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height * 0.15),
                                    child: Text('Shipment Not Found!',
                                        style: AppStyle.medium_16(
                                            AppColors.black)),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: data.shipmentData!.length,
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (_, index) => allOrdersWidget(
                                      context: context,
                                      shipmentList: data.shipmentData![index])),
                          SizedBox(height: size.width * 0.04),
                        ],
                      ),
                    ),
                  ))
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

Widget _shipmentContainer(
        String text, Color color, Color txtColor, String counts,   IconData? icon) =>
    Container(
      padding: EdgeInsets.all(8),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(8), color: color),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Text(text.toString().toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: AppStyle.medium_14(txtColor))),

              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.whiteColor),
                child: Icon(
                 icon,
                  size: 18,
                  color: AppColors.themeColor,
                ),
              )
            ],
          ),
          SizedBox(height: size.height * 0.015),
          Text(counts.toString(), style: AppStyle.bold_28(txtColor)),
          SizedBox(height: size.height * 0.015),
        ],
      ),
    );

Widget _buildSwitchRow(BuildContext context) {
  return GestureDetector(
    onTap: () {
      reachedLocationDialog(context, () async {
        Navigator.pop(context);
        EasyLoading.show(status: "Please wait...");

        try {
          DbStorage dbStorage = DbStorage();

          // Wait for the delay to complete
          await Future.delayed(Duration(seconds: 2));
          // Now clear all data
          await dbStorage.clearAllData(context);
        } catch (e) {
          EasyLoading.dismiss();
        } finally {
          EasyLoading.dismiss();
        }
      }, fromProfile: true);
    },
    child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: CircleAvatar(
          backgroundColor: AppColors.grey,
          child: Icon(Icons.logout),
        )),
  );
}

/// view all orders list
Widget allOrdersWidget(
        {required BuildContext context, required ShipmentDatum shipmentList}) =>
    Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.black10),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.whiteColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 5),
            dense: true,
            leading: Container(
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.blueGrey),
                child: Icon(Icons.fire_truck_sharp,
                    size: 18, color: AppColors.themeColor)),
            title: Text("Shipment Name :".toUpperCase(),
                style: AppStyle.medium_14(AppColors.black50)),
            subtitle: Text(
              shipmentList.name.toString() ?? "N/A",
              style: AppStyle.medium_14(AppColors.black),
            ),
            trailing: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShipmentDetails(
                    shipmentId: shipmentList.id.toString(),
                  ),
                ),
              ),
              child: CircleAvatar(
                backgroundColor: AppColors.grey,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.black50,
                ),
              ),
            ),
          ),
          Divider(color: AppColors.grey),

          // Shipment Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Shipment Status",
                    style: AppStyle.medium_16(AppColors.black)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: shipmentList.driverLocation == 'transit'
                          ? AppColors.red.withOpacity(0.2)
                          : shipmentList.driverLocation == 'running'
                              ? AppColors.orange.withOpacity(0.2)
                              : shipmentList.driverLocation == 'Reached'
                                  ? AppColors.orange.withOpacity(0.2)
                                  : AppColors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    shipmentList.driverLocation?.toString().toUpperCase() ??
                        "IN-TRANSIT",
                    style: AppStyle.semibold_12(
                      shipmentList.driverLocation == 'transit'
                          ? AppColors.red
                          : shipmentList.driverLocation == 'running'
                              ? AppColors.orange
                              : shipmentList.driverLocation == 'Reached'
                                  ? AppColors.orange
                                  : AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.grey),

          // Pickup & Drop Locations
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup Location
              Row(
                children: [
                  Icon(Icons.my_location, color: AppColors.themeColor),
                  SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pickup",
                            style: AppStyle.medium_14(AppColors.black)),
                        Text(
                          shipmentList.pickupLocation ?? "Not Available",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppStyle.medium_14(AppColors.black50),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Dots Line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: List.generate(
                    2,
                    (index) => Container(
                      margin: EdgeInsets.only(top: 3),
                      height: 5,
                      width: 2,
                      color: AppColors.themeColor,
                    ),
                  ),
                ),
              ),
              // Drop Location
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.themeColor),
                  SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Delivery Point",
                            style: AppStyle.medium_14(AppColors.black)),
                        Text(
                          shipmentList.dropLocation ?? "Not Available",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppStyle.medium_14(AppColors.black50),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

/// VIEW MEMBER DETAILS DIALOG
void driverDetailsDialog(BuildContext context, DriverDetails driver) {
  String initials = getInitials(driver.userResult!.name.toString());
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_ctx) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Driver Details',
                          style: GoogleFonts.ptSans(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                      trailing: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.clear, color: Colors.black))),
                  Divider(height: 0, color: Colors.grey.withOpacity(0.1)),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.themeColor,
                        child: Text(initials,
                            style: AppStyle.medium_16(AppColors.whiteColor))),
                    title: Text(
                        capitalizeFirstLetter(
                            driver.userResult!.name.toString()),
                        style: GoogleFonts.ptSans(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        capitalizeFirstLetter(
                            driver.userResult!.email ?? 'N/A'),
                        style: GoogleFonts.ptSans(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ),
                  Divider(color: Colors.grey.withOpacity(0.1)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mobile Number : ',
                          style: GoogleFonts.ptSans(
                              color: Colors.black, fontSize: 14)),
                      Flexible(
                        child: Text(
                            "+91 ${capitalizeFirstLetter(driver.userResult!.contact ?? '1234567890')}",
                            style: GoogleFonts.ptSans(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.1)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role Type : ',
                          style: GoogleFonts.ptSans(
                              color: Colors.black, fontSize: 14)),
                      Flexible(
                        child: Text(
                            capitalizeFirstLetter(
                                driver.userResult!.role ?? 'Driver'),
                            style: GoogleFonts.ptSans(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.1)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Company Name : ',
                          style: GoogleFonts.ptSans(
                              color: Colors.black, fontSize: 14)),
                      Flexible(
                        child: Text(
                            capitalizeFirstLetter(
                                driver.driver!.companyName ?? 'N/A'),
                            style: GoogleFonts.ptSans(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.1)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Address : ',
                          style: GoogleFonts.ptSans(
                              color: Colors.black, fontSize: 14)),
                      Flexible(
                        child: Text(
                            capitalizeFirstLetter(
                                driver.driver!.address ?? 'N/A'),
                            style: GoogleFonts.ptSans(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DeleteUserAccount()));
                        },
                        color: AppColors.red,
                        child: Text(
                          "Delete Account",
                          style: AppStyle.medium_16(AppColors.whiteColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
