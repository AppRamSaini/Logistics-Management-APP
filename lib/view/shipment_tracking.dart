import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistics_app/controller/dashboard_controler.dart';
import 'package:logistics_app/helper/app_buttons.dart';
import 'package:logistics_app/helper/app_colors.dart';
import 'package:logistics_app/helper/dialogs.dart';
import 'package:logistics_app/helper/global_file.dart';
import 'package:logistics_app/helper/text_style.dart';
import 'package:logistics_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:logistics_app/view/dashboard/dashboard.dart';

class ShipmentTracking extends StatefulWidget {
  final String shipmentId;
  final String? pickupLocation;
  final String? dropLocation;
  final bool fromDetails;

  const ShipmentTracking(
      {super.key,
      required this.shipmentId,
      this.dropLocation,
      this.pickupLocation,
      this.fromDetails = false});

  @override
  State<ShipmentTracking> createState() => ShipmentTrackingState();
}

class ShipmentTrackingState extends State<ShipmentTracking> {
  final DashboardController _dashboardController =
      Get.put(DashboardController());
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  BitmapDescriptor? truckIcon;
  Timer? _timer;
  Position? _currentPosition;
  LatLng? _currentLatLng;

  // 🔹 Google Directions API Key (Replace with your API Key)
  final String googleAPIKey = "AIzaSyAZdS5ILSddnuGPqz1TbLNd24wApLunFGU";

  @override
  void initState() {
    super.initState();
    // _loadCustomIcons();
    _determinePosition();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateTruckLocation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCustomIcons() async {
    truckIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)), "assets/images/trucks.png");
    setState(() {});
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentLatLng =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    LatLng pickupLatLng =
        await _getLatLngFromAddress(widget.pickupLocation!.toString());
    LatLng dropLatLng =
        await _getLatLngFromAddress(widget.dropLocation!.toString());

    setState(() {
      _markers.add(Marker(
        markerId: MarkerId("pickup"),
        position: pickupLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: "Pickup Location"),
      ));
      _markers.add(Marker(
          markerId: MarkerId("drop"),
          position: dropLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: "Drop Location")));
      _markers.add(Marker(
        markerId: MarkerId("truck"),
        position: _currentLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: "Current Location"),
      ));
    });

    _getRoutePolyline(_currentLatLng!, dropLatLng);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLatLng!, 14));
  }

  Future<LatLng> _getLatLngFromAddress(String address) async {
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$googleAPIKey";
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data["status"] == "OK") {
      double lat = data["results"][0]["geometry"]["location"]["lat"];
      double lng = data["results"][0]["geometry"]["location"]["lng"];
      return LatLng(lat, lng);
    } else {
      throw Exception("Failed to convert address to coordinates");
    }
  }

  Future<void> _getRoutePolyline(LatLng pickup, LatLng drop) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${pickup.latitude},${pickup.longitude}&destination=${drop.latitude},${drop.longitude}&key=$googleAPIKey&overview=full";
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data["status"] == "OK") {
      List<LatLng> routeCoords =
          _decodePolyline(data["routes"][0]["overview_polyline"]["points"]);
      setState(() {
        polylineCoordinates = routeCoords;
        _polylines.add(Polyline(
          polylineId: PolylineId("route"),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ));
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  /// UPDATE LOCATION
  Future<void> _updateTruckLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng updatedLatLng =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    print('------->>>>>$updatedLatLng');
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == "truck");
      _markers.add(Marker(
          markerId: MarkerId("truck"),
          position: updatedLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
              title: "Current Location", snippet: "Driver is here now")));
      _getRoutePolyline(updatedLatLng,
          _markers.firstWhere((m) => m.markerId.value == "drop").position);
    });
    _dashboardController.updateLocation(
        widget.shipmentId.toString(),
        _currentPosition!.latitude.toString(),
        _currentPosition!.longitude.toString());
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(updatedLatLng));
  }

  /// CALL TO REACH LOCATION API
  callToReachedLocation() async {
    Navigator.pop(context);
    await _dashboardController.reachedLocationAPI(
        context, widget.shipmentId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar(
          text: "Shipment Tracking",
          leading: GestureDetector(
              onTap: () {
                if (widget.fromDetails) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => Dashboard()),
                      (route) => false);
                }
              },
              child: Icon(Icons.arrow_back_ios))),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(26.926106, 75.790917), zoom: 8),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.blueGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Auto height
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Important for auto height
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.whiteColor,
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.my_location,
                                color: AppColors.themeColor),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                children: List.generate(
                                  4,
                                  (index) => Container(
                                    margin: EdgeInsets.only(top: 5),
                                    height: 5,
                                    width: 2,
                                    color: AppColors.themeColor,
                                  ),
                                ),
                              ),
                            ),
                            Icon(Icons.location_on,
                                color: AppColors.themeColor),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: AppColors.whiteColor),
                              child: Text(
                                widget.pickupLocation.toString(),
                                style: TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.whiteColor
                              ),
                              child: Text(
                                widget.dropLocation.toString(),
                                style: TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Updates every 10 minutes and visible to Broker, Carrier, and Customer.",
                    style: TextStyle(fontSize: 10),
                  ),
                  SizedBox(height: 12),
                  appButton(
                    onPressed: () {
                      reachedLocationDialog(context, () async {
                        callToReachedLocation();
                      });
                    },
                    minWidth: size.width,
                    text: "Reached Location",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
