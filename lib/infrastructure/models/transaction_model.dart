import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String? transactionId;
  String? userId; // Store the user's ID as a string
  double? amount;
  Timestamp? date;

  TransactionModel({
    this.transactionId,
    this.userId,
    this.amount,
    this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    transactionId: json["transaction_id"],
    userId: json["user_id"],
    amount: json["amount"],
    date: json["date"],
  );

  Map<String, dynamic> toJson() => {
    "transaction_id": transactionId,
    "user_id": userId, // Save the user's ID
    "amount": amount,
    "date": Timestamp.now(),
  };
}
