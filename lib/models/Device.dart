import 'dart:convert';
import 'package:tfg_app/models/user.dart';

List<Device> ratingFromJson(String str) =>
    List<Device>.from(json.decode(str).map((x) => Device.fromJson(x)));

String deviceToJson(List<Device> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
class Device {
  Device(
      {
      required this.name,
      required this.model,
      required this.brand,
      required this.owner,

      //required this.insurance
      });
  String name;
  String model;
  String brand;
  User owner;
  //ObjectElement insurance;

  factory Device.fromJson(Map<String, dynamic> responseData) {
    return new Device(
        name: responseData["name"],
        model: responseData["model"],
        brand: responseData["brand"],
      
        owner: responseData["owner"],
        );
  }

  Map<String, dynamic> toJson() => {
        "name":name,
        "model": model,
        "brand": brand,
        "owner": owner,
      };
}