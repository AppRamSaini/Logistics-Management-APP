// To parse this JSON data, do
//
//     final shipmentDetailsModels = shipmentDetailsModelsFromJson(jsonString);

import 'dart:convert';

ShipmentDetailsModels shipmentDetailsModelsFromJson(String str) => ShipmentDetailsModels.fromJson(json.decode(str));

String shipmentDetailsModelsToJson(ShipmentDetailsModels data) => json.encode(data.toJson());

class ShipmentDetailsModels {
  bool? status;
  String? message;
  List<ShipmentDetailsData>? data;

  ShipmentDetailsModels({
    this.status,
    this.message,
    this.data,
  });

  factory ShipmentDetailsModels.fromJson(Map<String, dynamic> json) => ShipmentDetailsModels(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<ShipmentDetailsData>.from(json["data"]!.map((x) => ShipmentDetailsData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class ShipmentDetailsData {
  String? id;
  String? name;
  String? description;
  String? pickupLocation;
  String? dropLocation;
  String? currentLocation;
  ErId? customerId;
  String? status;
  ErId? shipperId;
  ErId? brokerId;
  ErId? carrierId;
  DriverId? driverId;
  DateTime? shippingDate;
  DateTime? deliveryDateExpect;
  int? cost;
  String? paymentStatus;
  int? quantity;
  int? weight;
  String? dimensions;
  String? typeOfGoods;
  String? uploadedBol;
  String? driverAccept;
  dynamic customerSign;
  String? driverSign;
  String? driverLocation;
  dynamic review;
  dynamic reviewText;
  String? qrcode;
  String? brokerDispatchSheet;
  String? carrierDispatchSheet;
  bool? brokerApprove;
  DateTime? createdAt;
  int? v;
  bool? showBol;

  ShipmentDetailsData({
    this.id,
    this.name,
    this.description,
    this.pickupLocation,
    this.dropLocation,
    this.currentLocation,
    this.customerId,
    this.status,
    this.shipperId,
    this.brokerId,
    this.carrierId,
    this.driverId,
    this.shippingDate,
    this.deliveryDateExpect,
    this.cost,
    this.paymentStatus,
    this.quantity,
    this.weight,
    this.dimensions,
    this.typeOfGoods,
    this.uploadedBol,
    this.driverAccept,
    this.customerSign,
    this.driverSign,
    this.driverLocation,
    this.review,
    this.reviewText,
    this.qrcode,
    this.brokerDispatchSheet,
    this.carrierDispatchSheet,
    this.brokerApprove,
    this.createdAt,
    this.v,
    this.showBol,
  });

  factory ShipmentDetailsData.fromJson(Map<String, dynamic> json) => ShipmentDetailsData(
    id: json["_id"],
    name: json["name"],
    description: json["description"],
    pickupLocation: json["pickup_location"],
    dropLocation: json["drop_location"],
    currentLocation: json["current_location"],
    customerId: json["customer_id"] == null ? null : ErId.fromJson(json["customer_id"]),
    status: json["status"],
    shipperId: json["shipper_id"] == null ? null : ErId.fromJson(json["shipper_id"]),
    brokerId: json["broker_id"] == null ? null : ErId.fromJson(json["broker_id"]),
    carrierId: json["carrier_id"] == null ? null : ErId.fromJson(json["carrier_id"]),
    driverId: json["driver_id"] == null ? null : DriverId.fromJson(json["driver_id"]),
    shippingDate: json["shippingDate"] == null ? null : DateTime.parse(json["shippingDate"]),
    deliveryDateExpect: json["deliveryDateExpect"] == null ? null : DateTime.parse(json["deliveryDateExpect"]),
    cost: json["cost"],
    paymentStatus: json["paymentStatus"],
    quantity: json["quantity"],
    weight: json["weight"],
    dimensions: json["dimensions"],
    typeOfGoods: json["typeOfGoods"],
    uploadedBol: json["uploadedBol"],
    driverAccept: json["driverAccept"],
    customerSign: json["customer_sign"],
    driverSign: json["driver_sign"],
    driverLocation: json["driver_location"],
    review: json["review"],
    reviewText: json["reviewText"],
    qrcode: json["qrcode"],
    brokerDispatchSheet: json["broker_dispatch_sheet"],
    carrierDispatchSheet: json["carrier_dispatch_sheet"],
    brokerApprove: json["broker_approve"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    v: json["__v"],
    showBol: json["showBOL"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "description": description,
    "pickup_location": pickupLocation,
    "drop_location": dropLocation,
    "current_location": currentLocation,
    "customer_id": customerId?.toJson(),
    "status": status,
    "shipper_id": shipperId?.toJson(),
    "broker_id": brokerId?.toJson(),
    "carrier_id": carrierId?.toJson(),
    "driver_id": driverId?.toJson(),
    "shippingDate": "${shippingDate!.year.toString().padLeft(4, '0')}-${shippingDate!.month.toString().padLeft(2, '0')}-${shippingDate!.day.toString().padLeft(2, '0')}",
    "deliveryDateExpect": "${deliveryDateExpect!.year.toString().padLeft(4, '0')}-${deliveryDateExpect!.month.toString().padLeft(2, '0')}-${deliveryDateExpect!.day.toString().padLeft(2, '0')}",
    "cost": cost,
    "paymentStatus": paymentStatus,
    "quantity": quantity,
    "weight": weight,
    "dimensions": dimensions,
    "typeOfGoods": typeOfGoods,
    "uploadedBol": uploadedBol,
    "driverAccept": driverAccept,
    "customer_sign": customerSign,
    "driver_sign": driverSign,
    "driver_location": driverLocation,
    "review": review,
    "reviewText": reviewText,
    "qrcode": qrcode,
    "broker_dispatch_sheet": brokerDispatchSheet,
    "carrier_dispatch_sheet": carrierDispatchSheet,
    "broker_approve": brokerApprove,
    "created_at": createdAt?.toIso8601String(),
    "__v": v,
    "showBOL": showBol,
  };
}

class ErId {
  String? id;
  String? name;
  String? email;
  String? contact;

  ErId({
    this.id,
    this.name,
    this.email,
    this.contact,
  });

  factory ErId.fromJson(Map<String, dynamic> json) => ErId(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    contact: json["contact"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "contact": contact,
  };
}

class DriverId {
  String? id;
  String? name;
  String? email;
  String? contact;
  String? driverIdRef;
  String? address;
  String? vin;
  String? companyName;
  String? mcNumber;
  int? v;

  DriverId({
    this.id,
    this.name,
    this.email,
    this.contact,
    this.driverIdRef,
    this.address,
    this.vin,
    this.companyName,
    this.mcNumber,
    this.v,
  });

  factory DriverId.fromJson(Map<String, dynamic> json) => DriverId(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    contact: json["contact"],
    driverIdRef: json["driver_id_ref"],
    address: json["address"],
    vin: json["vin"],
    companyName: json["company_name"],
    mcNumber: json["mc_number"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "contact": contact,
    "driver_id_ref": driverIdRef,
    "address": address,
    "vin": vin,
    "company_name": companyName,
    "mc_number": mcNumber,
    "__v": v,
  };
}
