import 'package:cloud_firestore/cloud_firestore.dart';

class CashTransfer {
  final String userId;
  final String sourceAccountNumber;
  final String destinationAccountNumber;
  final double transferAmount;
  final DateTime transferDate;

  CashTransfer({
    required this.userId,
    required this.sourceAccountNumber,
    required this.destinationAccountNumber,
    required this.transferAmount,
    required this.transferDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sourceAccountNumber': sourceAccountNumber,
      'destinationAccountNumber': destinationAccountNumber,
      'transferAmount': transferAmount,
      'transferDate': transferDate,
    };
  }

  factory CashTransfer.fromMap(Map<String, dynamic> map) {
    return CashTransfer(
      userId: map['userId'],
      sourceAccountNumber: map['sourceAccountNumber'],
      destinationAccountNumber: map['destinationAccountNumber'],
      transferAmount: map['transferAmount'],
      transferDate: (map['transferDate'] as Timestamp).toDate(),
    );
  }
}
