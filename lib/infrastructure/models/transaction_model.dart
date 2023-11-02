import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String userId;
  final double amount;
  final Timestamp date;
  final String accountNumber; // Add this field

  TransactionModel({
    required this.userId,
    required this.amount,
    required this.date,
    required this.accountNumber,
  });
  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    userId: json["user_id"],
    accountNumber: json["accountNumber"],
    amount: json["amount"],
    date: json["date"],
  );
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'date': date,
      'accountNumber': accountNumber,
    };
  }
}

