import 'dart:convert';
import 'Device.dart';

List<User> userFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

User userJson(String str) => (json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class User {
  User(
      {this.name,
      this.id,
      this.password,
      this.email,
      this.birthday,
      this.devices,
      required this.admin});

  String? id;
  String? name;
  String? password;
  String? email;
  String? birthday;
  List<Device>? devices;
  bool admin;

  factory User.fromJson(Map<String, dynamic> responseData) {
    List<Device>? tmp3 = responseData["devices"] != null
        ? List<Device>.from(
            responseData["devices"].map((x) => Device.fromJson(x)))
        : null;

    return User(
        id: responseData["_id"],
        name: responseData['name'],
        password: responseData['password'],
        email: responseData['email'],
        birthday: responseData['birthday'],
        devices: tmp3,
        admin: responseData['admin']);
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "password": password,
        "email": email,
        "birthday": birthday,
        "devices": devices,
        "admin": admin
      };
}
