import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

UserModel transactionModelFromJson(String str) =>
    UserModel.fromJson(json.decode(str));

String transactionModelToJson(UserModel data) =>
    json.encode(data.toJson());
class UserModel {
  String? userId;
  String?  pin;
  String? name;
  String? accountNumber;
  String? balance;
  String? email;  // Add the email field
  bool blocked;

  UserModel({
    this.userId,
    this.name,
    this.accountNumber,
    this.pin,
    this.balance,
    this.email,  // Initialize the email field
    this.blocked = false,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json["user_id"],
    name: json["name"],
    accountNumber: json["account_number"],
    pin: json["pin"],
    balance: json["balance"],
    email: json["email"],  // Parse the email field
    blocked: json['blocked'] ?? false,
  );


  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "name": name,
    "account_number": accountNumber,
    "pin": pin,
    "balance": balance,
    'email': email,// Include the email field in the JSON representation
    'blocked': blocked,
  };
}
