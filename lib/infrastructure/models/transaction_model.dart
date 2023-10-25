import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

TransactionModel transactionModelFromJson(String str) =>
    TransactionModel.fromJson(json.decode(str));

String transactionModelToJson(TransactionModel data) =>
    json.encode(data.toJson());

class TransactionModel {
  String? transactionId;
  String? userId; // Add the user ID field
  double? amount;
  Timestamp? date;
  TransactionModel({
    this.transactionId,
    this.userId, // Add the user ID parameter
    this.amount,
    this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        transactionId: json["transaction_id"],
        userId: json["user_id"],
        amount: json["amount"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
    "transaction_id": transactionId,
    "user_id": userId, // Include the user ID in the JSON representation
    "amount": amount,
    "date" : Timestamp.now(),
  };
}
