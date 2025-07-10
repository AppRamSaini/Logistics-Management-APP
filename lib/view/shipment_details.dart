import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logistics_app/controller/dashboard_controler.dart';
import 'package:logistics_app/helper/app_colors.dart';
import 'package:logistics_app/helper/dialogs.dart';
import 'package:logistics_app/helper/global_file.dart';
import 'package:logistics_app/helper/text_style.dart';
import 'package:logistics_app/main.dart';
import 'package:logistics_app/model/shipment_details_model.dart';
import 'package:logistics_app/view/customer_signature.dart';
import 'package:logistics_app/view/loading_bill.dart';
import 'package:logistics_app/view/qr_code%20page.dart';
import 'package:logistics_app/view/shipment_tracking.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ShipmentDetails extends StatefulWidget {
  final String shipmentId;
  const ShipmentDetails({super.key, required this.shipmentId});

  @override
  State<ShipmentDetails> createState() => _ShipmentDetailsState();
}

final DashboardController _dashboardController = Get.put(DashboardController());

class _ShipmentDetailsState extends State<ShipmentDetails> {
  Future<void> refreshData() async {
    _dashboardController.shipmentDetailsAPi(
        context, widget.shipmentId.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(text: "Shipment Detail"),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: 10),
        child: RefreshIndicator(
          onRefresh: refreshData,
          child: FutureBuilder<List<ShipmentDetailsData>?>(
              future: _dashboardController.shipmentDetailsAPi(
                  context, widget.shipmentId.toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator.adaptive());
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return Center(
                      child: Text("Internet connection error",
                          style: AppStyle.medium_16(AppColors.red)));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}",
                          style: AppStyle.medium_16(AppColors.red)));
                } else if (snapshot.hasData) {
                  ShipmentDetailsData data = ShipmentDetailsData();

                  if (snapshot.data!.isNotEmpty) {
                    data = snapshot.data!.first;
                  } else {
                    return Center(
                        child: Text("Data not fount",
                            style: AppStyle.medium_14(AppColors.black50)));
                  }

                  return SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors.black10),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.whiteColor),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Shipment Name : ",
                                            style: AppStyle.medium_14(
                                                AppColors.black50)),
                                        Expanded(
                                          child: Text(data.name ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: AppStyle.medium_14(
                                                  AppColors.black)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Amt : ₹",
                                          style: AppStyle.medium_14(
                                              AppColors.black50)),
                                      Text(data.cost.toString(),
                                          style: AppStyle.medium_14(
                                              AppColors.black)),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Divider(color: AppColors.black10)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Shipment Status",
                                        style: AppStyle.medium_16(
                                            AppColors.black)),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: data.driverLocation ==
                                                  'transit'
                                              ? AppColors.red.withOpacity(0.2)
                                              : data.driverLocation == 'running'
                                                  ? AppColors.orange
                                                      .withOpacity(0.2)
                                                  : data.driverLocation ==
                                                          'Reached'
                                                      ? AppColors.orange
                                                          .withOpacity(0.2)
                                                      : AppColors.green
                                                          .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text(
                                        data.driverLocation
                                                ?.toString()
                                                .toUpperCase() ??
                                            "IN-TRANSIT",
                                        style: AppStyle.semibold_12(
                                          data.driverLocation == 'transit'
                                              ? AppColors.red
                                              : data.driverLocation == 'running'
                                                  ? AppColors.orange
                                                  : data.driverLocation ==
                                                          'Reached'
                                                      ? AppColors.orange
                                                      : AppColors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Divider(color: AppColors.black10)),
                              Row(
                                children: [
                                  Flexible(
                                    child: Row(children: [
                                      Icon(Icons.location_on_outlined,
                                          color: AppColors.themeColor),
                                      SizedBox(width: 10),
                                      Text("Pickup From",
                                          style: AppStyle.medium_14(
                                              AppColors.black))
                                    ]),
                                  ),
                                  Flexible(
                                    child: Text(data.pickupLocation.toString(),
                                        style: AppStyle.medium_14(
                                            AppColors.black)),
                                  )
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Flexible(
                                      child: Row(children: [
                                    Icon(Icons.location_on_outlined,
                                        color: AppColors.themeColor),
                                    SizedBox(width: 10),
                                    Text("Delivery Point",
                                        style:
                                            AppStyle.medium_14(AppColors.black))
                                  ])),
                                  Flexible(
                                    child: Text(data.dropLocation.toString(),
                                        style: AppStyle.medium_14(
                                            AppColors.black)),
                                  )
                                ],
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Divider(color: AppColors.black10)),
                              Row(
                                children: [
                                  Flexible(
                                    child: Row(children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Customer Name",
                                                style: AppStyle.medium_14(
                                                    AppColors.black)),
                                            Text(
                                                data.customerId!.name
                                                    .toString(),
                                                style: AppStyle.medium_14(
                                                    AppColors.black50)),
                                          ])
                                    ]),
                                  ),
                                  Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Created At",
                                              style: AppStyle.medium_14(
                                                  AppColors.black)),
                                          Text(
                                              formatDateTime(
                                                  data.createdAt.toString()),
                                              style: AppStyle.medium_14(
                                                  AppColors.black50)),
                                        ]),
                                  )
                                ],
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Divider(color: AppColors.black10)),
                              Row(
                                children: [
                                  Flexible(
                                    child: Row(children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Driver Name",
                                                style: AppStyle.medium_14(
                                                    AppColors.black)),
                                            Text(
                                                data.driverId!.name
                                                        .toString() ??
                                                    '',
                                                style: AppStyle.medium_14(
                                                    AppColors.black50)),
                                          ])
                                    ]),
                                  ),
                                  Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Carrier Name",
                                              style: AppStyle.medium_14(
                                                  AppColors.black)),
                                          Text(data.name.toString(),
                                              style: AppStyle.medium_14(
                                                  AppColors.black50)),
                                        ]),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors.black10),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.whiteColor),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: AppColors.blueGrey),
                                    child: Icon(
                                      Icons.fire_truck_sharp,
                                      size: 18,
                                      color: AppColors.themeColor,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Shipment Name",
                                          style: AppStyle.semibold_16(
                                              AppColors.black)),
                                      Text(data.name.toString(),
                                          style: AppStyle.medium_14(
                                              AppColors.black)),
                                    ],
                                  )
                                ],
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Divider(color: AppColors.black10)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("Types Of Goods",
                                              style: AppStyle.medium_14(
                                                  AppColors.black)),
                                          Text(data.typeOfGoods!.toString(),
                                              style: AppStyle.medium_14(
                                                  AppColors.black50)),
                                        ]),
                                  ),
                                  Container(
                                    height: size.height * 0.05,
                                    width: 1,
                                    color: AppColors.black10,
                                  ),
                                  Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("Quantity",
                                              style: AppStyle.medium_14(
                                                  AppColors.black)),
                                          Text(data.quantity!.toString(),
                                              style: AppStyle.medium_14(
                                                  AppColors.black50)),
                                        ]),
                                  ),
                                  Container(
                                    height: size.height * 0.05,
                                    width: 1,
                                    color: AppColors.black10,
                                  ),
                                  Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("Weight",
                                              style: AppStyle.medium_14(
                                                  AppColors.black)),
                                          Text(data.weight!.toString(),
                                              style: AppStyle.medium_14(
                                                  AppColors.black50)),
                                        ]),
                                  )
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Divider(color: AppColors.black10),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("Dimensions",
                                              style: AppStyle.medium_14(
                                                  AppColors.black)),
                                          Text(data.dimensions!.toString(),
                                              style: AppStyle.medium_14(
                                                  AppColors.black50)),
                                        ]),
                                  ),
                                  Container(
                                    height: size.height * 0.05,
                                    width: 1,
                                    color: AppColors.black10,
                                  ),
                                  Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("Shipping Date",
                                              style: AppStyle.medium_14(
                                                  AppColors.black)),
                                          Text(
                                              formatDate(
                                                data.shippingDate!.toString(),
                                              ),
                                              style: AppStyle.medium_14(
                                                  AppColors.black50)),
                                        ]),
                                  ),
                                  Container(
                                      height: size.height * 0.05,
                                      width: 1,
                                      color: AppColors.black10),
                                  Flexible(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("Expected Date",
                                              style: AppStyle.medium_14(
                                                  AppColors.black)),
                                          Text(
                                              formatDate(
                                                data.deliveryDateExpect!
                                                    .toString(),
                                              ),
                                              style: AppStyle.medium_14(
                                                  AppColors.black50)),
                                        ]),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Broker Dispatch Sheet",
                                style: AppStyle.semibold_18(AppColors.black))),
                        SizedBox(height: size.height * 0.01),
                        buildDispatchViewer(
                            data.brokerDispatchSheet.toString()),
                        SizedBox(height: size.height * 0.03),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Carrier Dispatch Sheet",
                                style: AppStyle.semibold_18(AppColors.black))),
                        SizedBox(height: size.height * 0.01),
                        buildDispatchViewer(
                            data.carrierDispatchSheet.toString()),
                        data.driverLocation == 'delivered'
                            ? SizedBox()
                            : Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: size.height * 0.02),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.blueGrey,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    data.driverLocation == 'Reached'
                                        ? SizedBox()
                                        : Expanded(
                                            child: MaterialButton(
                                              onPressed: () {
                                                cancelShipmentDialog(context,
                                                    () async {
                                                  await _dashboardController
                                                      .cancelShipmentAPI(
                                                    context,
                                                    data.id.toString(),
                                                  );
                                                });
                                              },
                                              height: size.height * 0.05,
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color:
                                                          AppColors.themeColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                              child: Text(
                                                "Cancel",
                                                style: AppStyle.medium_16(
                                                    AppColors.themeColor),
                                              ),
                                            ),
                                          ),
                                    SizedBox(width: 10),

                                    // Dynamic Button
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          if (data.driverLocation ==
                                              'running') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ShipmentTracking(
                                                  shipmentId:
                                                      data.id.toString(),
                                                  dropLocation: data
                                                      .dropLocation
                                                      .toString(),
                                                  pickupLocation: data
                                                      .pickupLocation
                                                      .toString(),
                                                  fromDetails: true,
                                                ),
                                              ),
                                            );
                                          } else if (data.driverLocation ==
                                              'Reached') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => QrCOdePage(
                                                  qrcodeLink:
                                                      data.qrcode.toString(),
                                                ),
                                              ),
                                            );
                                          } else {
                                            if (data.showBol == true) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => LoadingBill(
                                                      shipmentId:
                                                          data.id.toString()),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        height: size.height * 0.05,
                                        color: data.showBol==true?  AppColors.themeColor:AppColors.grey,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: FittedBox(
                                          child: Text(
                                            data.driverLocation == 'running'
                                                ? 'TRACKING'
                                                : data.driverLocation ==
                                                        'Reached'
                                                    ? 'VIEW QR'
                                                    : "NEXT",
                                            style: AppStyle.medium_16(
                                                AppColors.whiteColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text("No Shipments Found"));
                }
              }),
        ),
      ),
    );
  }

  Widget buildDispatchViewer(String url) {
    String ext = url.split('.').last.toLowerCase();
    if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
      return Image.network(url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(Icons.broken_image));
    } else if (ext == 'pdf') {
      return SfPdfViewer.network(url, password: 'syncfusion');
    } else {
      return Center(child: Text('Unsupported file format'));
    }
  }
}
