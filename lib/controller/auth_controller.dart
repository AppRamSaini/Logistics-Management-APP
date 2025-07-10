import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logistics_app/api/api_manager.dart';
import 'package:logistics_app/helper/api_end_points.dart';
import 'package:logistics_app/helper/global_file.dart';
import 'package:logistics_app/model/get_driver_details.dart';
import 'package:logistics_app/services/db_storage.dart';
import 'package:logistics_app/view/auth/driver_page.dart';
import 'package:logistics_app/view/auth/login.dart';
import 'package:logistics_app/view/auth/otp_verify.dart';
import 'package:logistics_app/view/auth/reset_password.dart';
import 'package:logistics_app/view/dashboard/dashboard.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  ApiManager manager = ApiManager();
  DbStorage storage = DbStorage();

  DriverDetails driverDetails = DriverDetails();

  // Login API
  Future<void> loginApi(BuildContext context, var bodyData) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response = await manager.postRequest(ApiEndPoints.login, bodyData);
      var resData = json.decode(await response.stream.bytesToString());
      print(resData);
      if (response.statusCode == 200) {
        if (resData['status'] == true) {
          storage.setToken(resData['token'].toString());
          storage.setUserid(resData['user']['_id'].toString());
          customSnackBar(resData['message'].toString());
          getDriver(context, false);
        } else {
          customSnackBar(resData['message'].toString(), isError: true);
        }
      } else {
        customSnackBar(resData['message'].toString(), isError: true);
      }
    } on SocketException {
      customSnackBar('Internet Connection Error!', isError: true);
    } on TimeoutException {
      customSnackBar('Server time out Exception', isError: true);
    } catch (e) {
      customSnackBar('Something went wrong', isError: true);
      print('Error in loginApi: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

// Login API
  Future<DriverDetails?> getDriver(
      BuildContext context, bool forDashboard) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response = await manager.getRequest(ApiEndPoints.getDriver);

      if (response.statusCode == 201) {
        var resData = json.decode(await response.stream.bytesToString());

        if (resData['status'] == true) {
          driverDetails = DriverDetails.fromJson(resData['data']);
          print(
              'Driver Details: ${driverDetails.driver!.companyName.toString()}');
          if (!forDashboard && driverDetails.driver!.companyName == null ||
              driverDetails.driver!.companyName!.isEmpty) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DriverPage(
                        driverName: driverDetails.userResult?.name ?? '')));
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => Dashboard()),
                (route) => false);
          }

          return driverDetails;
        } else {
          customSnackBar(resData['message'] ?? 'Login failed', isError: true);
          return null;
        }
      } else {
        customSnackBar('Error: ${response.statusCode}', isError: true);
        return null;
      }
    } on SocketException {
      customSnackBar('Internet Connection Error!', isError: true);
    } catch (e) {
      customSnackBar('Something went wrong', isError: true);
      print('Error in getDriver API: $e');
      return null;
    } finally {
      EasyLoading.dismiss();
    }
    return null;
  }

  // // Add driver details  API
  // Future<void> addDriverDetailsAPI(BuildContext context, var bodyData) async {
  //   EasyLoading.show(status: 'Loading...'); // Show loading indicator
  //   try {
  //     var response = await manager.postRequestWithToken(
  //         ApiEndPoints.addDriverDetails, bodyData);
  //     var resData = json.decode(await response.stream.bytesToString());
  //     print(resData);
  //     if (response.statusCode == 201) {
  //       if (resData['status'] == true) {
  //         customSnackBar(resData['message'].toString());
  //         Navigator.pushAndRemoveUntil(context,
  //             MaterialPageRoute(builder: (_) => Dashboard()), (route) => false);
  //       } else {
  //         customSnackBar(resData['message'].toString(), isError: true);
  //       }
  //     } else {
  //       customSnackBar(resData['message'].toString(), isError: true);
  //     }
  //   } catch (e) {
  //     customSnackBar('Something went wrong', isError: true);
  //     print('Error in loginApi: $e');
  //   } finally {
  //     EasyLoading.dismiss();
  //   }
  // }

  // ready notifications
  Future<void> addDriverDetailsAPI(BuildContext context, String driverName,
      String mcNumber, String companyName) async {
    DbStorage dbStorage = DbStorage();
    var token = dbStorage.getToken();
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var request =
          http.Request('POST', Uri.parse(ApiEndPoints.addDriverDetails));
      request.body = json.encode({
        "company_name": companyName,
        "mc_number": mcNumber,
        "driver_name": driverName
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var resData = json.decode(await response.stream.bytesToString());
      print(resData);
      if (response.statusCode == 201) {
        if (resData['status'] == true) {
          customSnackBar(resData['message'].toString());
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => Dashboard()), (route) => false);
        } else {
          customSnackBar(resData['message'].toString(), isError: true);
        }
      } else {
        customSnackBar(resData['message'].toString(), isError: true);
      }
    } catch (e) {
      customSnackBar('Something went wrong', isError: true);
      print('Error in loginApi: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // forgot password API
  Future<void> forgotPasswordAPI(
      BuildContext context, var bodyData, bool isResend) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response =
          await manager.postRequest(ApiEndPoints.forgotPassword, bodyData);
      var resData = json.decode(await response.stream.bytesToString());
      print('Driver Details: ${resData}');
      if (response.statusCode == 200) {
        if (resData['status'] == true) {
          customSnackBar(resData['message'].toString());

          if (!isResend) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        PasswordOtpVerify(email: bodyData['email'])));
          }
        } else {
          customSnackBar(resData['message'].toString(), isError: true);
        }
      } else {
        customSnackBar(resData['message'].toString(), isError: true);
      }
    } catch (e) {
      customSnackBar('Something went wrong', isError: true);
      print('Error in loginApi: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // forgot password API
  Future<void> passwordOtpVerifyAPI(BuildContext context, var bodyData) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response =
          await manager.postRequest(ApiEndPoints.passwordOtpVerify, bodyData);
      var resData = json.decode(await response.stream.bytesToString());
      print('Driver Details:$resData ${bodyData}');
      if (response.statusCode == 200) {
        if (resData['status'] == true) {
          customSnackBar(resData['message'].toString());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ResetPassword(object: bodyData)));
        } else {
          customSnackBar(resData['message'].toString(), isError: true);
        }
      } else {
        customSnackBar(resData['message'].toString(), isError: true);
      }
    } catch (e) {
      customSnackBar('Something went wrong', isError: true);
      print('Error in loginApi: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // forgot password API
  Future<void> resetPasswordAPI(BuildContext context, var bodyData) async {
    EasyLoading.show(status: 'Loading...'); // Show loading indicator
    try {
      var response =
          await manager.postRequest(ApiEndPoints.resetPassword, bodyData);
      var resData = json.decode(await response.stream.bytesToString());
      print('Driver Details:$resData ${bodyData}');
      if (response.statusCode == 200) {
        if (resData['status'] == true) {
          customSnackBar(resData['message'].toString());
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
        } else {
          customSnackBar(resData['message'].toString(), isError: true);
        }
      } else {
        customSnackBar(resData['message'].toString(), isError: true);
      }
    } catch (e) {
      customSnackBar('Something went wrong', isError: true);
      print('Error in loginApi: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

// FETCH DRIVER DETAIL
  DriverDetails fetchDriversDetails = DriverDetails();
  Future<DriverDetails?> fetchDriver(BuildContext context) async {
    try {
      var response = await manager.getRequest(ApiEndPoints.getDriver);

      // 🔧 Stream को एक ही बार read करें
      String responseString = await response.stream.bytesToString();
      var resData = json.decode(responseString);

      if (response.statusCode == 201) {
        if (resData['status'] == true) {
          fetchDriversDetails = DriverDetails.fromJson(resData['data']);
          print('Driver Details: ${fetchDriversDetails.userResult}');
          return fetchDriversDetails;
        } else {
          customSnackBar(resData['message'] ?? 'Login failed', isError: true);
          return null;
        }
      } else {
        customSnackBar('Error: ${resData['message']}', isError: true);
        return null;
      }
    } catch (e) {
      customSnackBar('Something went wrong', isError: true);
      print('Error in getDriver API: $e');
      return null;
    }
  }

}
