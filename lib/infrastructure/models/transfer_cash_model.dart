  import 'package:cloud_firestore/cloud_firestore.dart';

  class TransferCashModel {
    String? transactionId;
    String? accountNumber;
    String? userId; // Store the user's ID as a string
    double? amount;
    Timestamp? date;

    TransferCashModel({
      this.transactionId,
      this.userId,
      this.accountNumber,
      this.amount,
      this.date,
    });

    factory TransferCashModel.fromJson(Map<String, dynamic> json) => TransferCashModel(
      transactionId: json["transaction_id"],
      userId: json["user_id"],
      accountNumber: json["accountNumber"],
      amount: json["amount"],
      date: json["date"],
    );

    Map<String, dynamic> toJson() => {
      "transaction_id": transactionId,
      "user_id": userId,
      "accountNumber": accountNumber,// Save the user's ID
      "amount": amount,
      "date": Timestamp.now(),
    };
  }
