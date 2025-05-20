import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logistics_app/api/api_manager.dart';
import 'package:logistics_app/helper/api_end_points.dart';
import 'package:logistics_app/helper/global_file.dart';
import 'package:logistics_app/model/dashboard_shipment_model.dart';
import 'package:logistics_app/model/get_all_order_listing.dart';
import 'package:logistics_app/model/notification_modal.dart';
import 'package:logistics_app/model/shipment_details_model.dart';
import 'package:logistics_app/services/db_storage.dart';
import 'package:logistics_app/view/auth/login.dart';
import 'package:logistics_app/view/customer_signature.dart';
import 'package:logistics_app/view/dashboard/dashboard.dart';
import 'package:logistics_app/view/qr_code%20page.dart';
import 'package:logistics_app/view/shipment_tracking.dart';
import 'package:http/http.dart' as http;

class DashboardController extends GetxController {
  ApiManager manager = ApiManager();
  DbStorage storage = DbStorage();

  var notificationCount = 0.obs; // Observable integer
  void updateNotificationCount(int count) {
    notificationCount.value = count; // Update the count
  }

  navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
  }

  /// GET SHIPMENT DASHBOARD DETAILS API
  Future fetchDashboardData(BuildContext context) async {
    ApiManager manager = ApiManager();

    EasyLoading.show(status: 'Loading...'); // Show loading
    try {
      var response = await manager.getRequest(ApiEndPoints.dashboard);
      var resData = json.decode(await response.stream.bytesToString());

      if (response.statusCode == 200) {
        if (resData['status']) {
          ShipmentDashboardData shipmentData =
              ShipmentDashboardData.fromJson(resData['data']);
          getShipmentNotificationsApi(context);
          return shipmentData;
        } else {
          customSnackBar(resData['message'] ?? 'Failed to load!',
              isError: true);
        }
      } else if (response.statusCode == 401) {
        customSnackBar(resData['message'] ?? 'Token has been expired!',
            isError: true);
        navigateToLogin(context);
      } else {
        customSnackBar('Error: ${resData['message']}', isError: true);
      }
    } on SocketException {
      customSnackBar('Internet Connection Error!', isError: true);
    } catch (e) {
      customSnackBar('Something went wrong', isError: true);
    } finally {
      EasyLoading.dismiss(); // Hide loading
    }
  }

  /// GET SHIPMENT LISTING API
  List<Shipment> shipments = [];
  Future<List<Shipment>?> getAllShipmentsApi(BuildContext context) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response = await manager.getRequest(ApiEndPoints.getAllOrders);
      if (response.statusCode == 200) {
        var resData = json.decode(await response.stream.bytesToString());

        if (resData['status']) {
          shipments = (resData['data']['shipments'] as List)
              .map((item) => Shipment.fromJson(item))
              .toList();
          return shipments;
        } else {
          // customSnackBar(resData['message'] ?? 'Failed to load!',
          //     isError: true);
          return shipments;
        }
      } else if (response.statusCode == 401) {
        customSnackBar('Token has been expired!', isError: true);
        navigateToLogin(context);
      } else {
        // customSnackBar('Error: ${response.statusCode}', isError: true);
        return shipments;
      }
    } on SocketException {
      customSnackBar('Internet Connection Error!', isError: true);
      return shipments;
    } catch (e) {
      // customSnackBar('Something went wrong', isError: true);
      return shipments;
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// GET SHIPMENT DETAILS API
  List<ShipmentDetailsData>? shipmentDetailsData = [];
  Future<List<ShipmentDetailsData>?> shipmentDetailsAPi(
      BuildContext context, String shipmentId) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response = await manager
          .getRequest("${ApiEndPoints.getShipmentDetails}$shipmentId");

      print(response.statusCode);
      if (response.statusCode == 200) {
        var resData = json.decode(await response.stream.bytesToString());
        if (resData['status']) {
          shipmentDetailsData = (resData['data'] as List)
              .map((item) => ShipmentDetailsData.fromJson(item))
              .toList();
          return shipmentDetailsData;
        } else {
          customSnackBar(resData['message'] ?? 'Failed to load!',
              isError: true);
          return shipmentDetailsData;
        }
      } else if (response.statusCode == 401) {
        customSnackBar('Token has been expired!', isError: true);
        navigateToLogin(context);
      } else {
        customSnackBar('Error: ${response.statusCode}', isError: true);
        return shipmentDetailsData;
      }
    } on SocketException {
      customSnackBar('Internet Connection Error!', isError: true);
      return shipmentDetailsData;
    } catch (e) {
      // customSnackBar('Something went wrong', isError: true);
      return shipmentDetailsData;
    } finally {
      EasyLoading.dismiss();
    }
    return null;
  }

  ///  SHIPMENT CANCEL API
  Future<void> cancelShipmentAPI(
      BuildContext context, String shipmentId) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response =
          await manager.getRequest("${ApiEndPoints.cancelShipment}$shipmentId");
      var resData = json.decode(await response.stream.bytesToString());
      if (response.statusCode == 200) {
        if (resData['status'] == true) {
          customSnackBar(
              resData['message'] ?? 'Shipment Cancelled Successfully');
        Future.delayed(Duration(milliseconds: 100),(){
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => Dashboard()), (route) => false);
        });
        } else {
          customSnackBar(resData['message'] ?? 'Failed to cancel shipment',
              isError: true);
        }
      } else if (response.statusCode == 401) {
        customSnackBar(resData['message'] ?? 'Token has been expired!',
            isError: true);
        navigateToLogin(context);
      } else {
        customSnackBar('Error: ${response.statusCode}', isError: true);
      }
    } on SocketException {
      customSnackBar('Internet Connection Error! Please check your network.',
          isError: true);
    } catch (e) {
      print("Error in cancelShipmentAPI: $e");
      // customSnackBar('Something went wrong', isError: true);
    } finally {
      EasyLoading.dismiss(); // Dismiss loading indicator before navigation
      Navigator.pop(context);
    }
  }

  ///  SHIPMENT start api
  Future<void> uploadSignatureAPI(BuildContext context, String shipmentID,
      String type, Uint8List signatureBytes,
      {bool fromCustomer = false}) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response = await manager.multiPartRequest(
          "${ApiEndPoints.driverSignUpload}$shipmentID", type, signatureBytes);

      print("Response Code: ${response.statusCode}");
      var resData = json.decode(await response.stream.bytesToString());

      if (response.statusCode == 200) {
        if (resData['status'] == true) {
          customSnackBar(resData['message'].toString());

          print(resData);
          if (fromCustomer == true) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => Dashboard()),
                (route) => false);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ShipmentTracking(
                          shipmentId: shipmentID,
                          pickupLocation:
                              resData['data']['pickup_location'].toString(),
                          dropLocation:
                              resData['data']['drop_location'].toString(),

                        )));
          }
        } else {
          customSnackBar(resData['message'], isError: true);
        }
      } else if (response.statusCode == 401) {
        customSnackBar(resData['message'] ?? 'Token has been expired!',
            isError: true);
        navigateToLogin(context);
      } else {
        customSnackBar('Error: ${response.statusCode}', isError: true);
      }
    } on SocketException {
      customSnackBar('Internet Connection Error! Please check your network.',
          isError: true);
    } catch (e) {
      print("Error in cancelShipmentAPI: $e");
      customSnackBar('Something went wrong', isError: true);
    } finally {
      EasyLoading.dismiss(); // Dismiss loading indicator before navigation
    }
  }

  ///  REACHED CUSTOMER LOCATION API
  Future<void> reachedLocationAPI(
      BuildContext context, String shipmentId) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response = await manager
          .getRequest("${ApiEndPoints.reachedLocation}$shipmentId");
      var resData = json.decode(await response.stream.bytesToString());

      print("------->>>>$resData");



      if (response.statusCode == 200) {
        if (resData['status'] == true) {
          customSnackBar(resData['message']);
          EasyLoading.dismiss();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      QrCOdePage(qrcodeLink: resData['data']['qrcode'].toString())));
        } else {
          customSnackBar(resData['message'], isError: true);
        }
      } else if (response.statusCode == 401) {
        customSnackBar(resData['message'] ?? 'Token has been expired!',
            isError: true);
        navigateToLogin(context);
      } else {
        customSnackBar('Error: ${response.statusCode}', isError: true);
      }
    } on SocketException {
      customSnackBar('Internet Connection Error! Please check your network.',
          isError: true);
    } catch (e) {
      print("Error in: $e");
      // customSnackBar('Something went wrong', isError: true);
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// GET SHIPMENT history LISTING API
  List<Shipment> shipmentsHistory = [];
  Future<List<Shipment>?> getShipmentsHistoryApi(BuildContext context) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response = await manager.getRequest(ApiEndPoints.getAllOrders);

      var resData = json.decode(await response.stream.bytesToString());

      if (response.statusCode == 200) {
        if (resData['status']) {
          shipmentsHistory = (resData['data']['shipmentdelivered'] as List)
              .map((item) => Shipment.fromJson(item))
              .toList();
          return shipmentsHistory;
        } else {
          customSnackBar(resData['message'] ?? 'Failed to load!',
              isError: true);
          return shipmentsHistory;
        }
      } else if (response.statusCode == 401) {
        customSnackBar(resData['message'] ?? 'Token has been expired!',
            isError: true);
        navigateToLogin(context);
      } else {
        customSnackBar('Error: ${response.statusCode}', isError: true);
        return shipmentsHistory;
      }
    } on SocketException {
      customSnackBar('Internet Connection Error!', isError: true);
      return shipmentsHistory;
    } catch (e) {
      // customSnackBar('Something went wrong', isError: true);
      return shipmentsHistory;
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// GET ALL NOTIFICATIONS LISTING API
  List<NotificationList> notifications = []; // Notifications list

  Future<List<NotificationList>?> getShipmentNotificationsApi(
      BuildContext context) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response = await manager.getRequest(ApiEndPoints.getNotifications);
      var resData = json.decode(await response.stream.bytesToString());

      if (response.statusCode == 200) {
        if (resData['status']) {
          int counts = resData['count'] as int;
          updateNotificationCount(counts);
          storage.setNotiCounts(counts.toString());
          notifications = (resData['data'] as List)
              .map((item) => NotificationList.fromJson(item))
              .toList();
        } else {
          customSnackBar(resData['message'] ?? 'Failed to load!',
              isError: true);
        }
      } else if (response.statusCode == 401) {
        customSnackBar(resData['message'] ?? 'Token has been expired!',
            isError: true);
        navigateToLogin(context);
      } else {
        customSnackBar('Error: ${response.statusCode}', isError: true);
      }
    } on SocketException {
      customSnackBar('Internet Connection Error!', isError: true);
    } catch (e) {
      customSnackBar('Something went wrong', isError: true);
    } finally {
      EasyLoading.dismiss();
    }
    return notifications;
  }

  // ready notifications
  Future<void> readNotificationAPI(BuildContext context, var id) async {
    print( ApiEndPoints.readNotifications);
    DbStorage dbStorage = DbStorage();
    var token = dbStorage.getToken();
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              ApiEndPoints.readNotifications));
      request.body = json.encode({"id": id});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var resData = json.decode(await response.stream.bytesToString());
      print(resData);
      if (response.statusCode == 200) {
        if (resData['status'] == true) {
          getShipmentNotificationsApi(context);
          customSnackBar(resData['message'].toString());
        } else {
          customSnackBar(resData['message'].toString(), isError: true);
        }
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      customSnackBar('Something went wrong', isError: true);
      print('Error in loginApi: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // ready notifications
  Future<void> updateLocation(var id, String lat, String long) async {
    DbStorage dbStorage = DbStorage();
    var token = dbStorage.getToken();
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var request =
          http.Request('POST', Uri.parse(ApiEndPoints.updateDirection));
      request.body = json.encode({"Shipment_id": id, "lat": lat, "long": long});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var resData = json.decode(await response.stream.bytesToString());
      print(resData);
      if (response.statusCode == 200) {
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error in loginApi: $e');
    } finally {
    }
  }
}
