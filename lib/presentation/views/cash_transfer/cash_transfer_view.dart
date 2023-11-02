import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../../infrastructure/preferences/store_account_number_and_pin.dart';

class CashTransferScreen extends StatefulWidget {
  @override
  _CashTransferScreenState createState() => _CashTransferScreenState();
}

class _CashTransferScreenState extends State<CashTransferScreen> {
  final TextEditingController sourceAccountController = TextEditingController();
  final TextEditingController destinationAccountController = TextEditingController();
  final TextEditingController transferAmountController = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<bool> authenticateUser() async {
    bool authenticated = false;

    try {
      authenticated = await _localAuthentication.authenticate(
        localizedReason: "Scan your finger to authenticate",
      );
    } on PlatformException catch (e) {
      print(e);
    }

    return authenticated;
  }

  Future<void> performBalanceTransfer() async {
    // Authenticate the user
    bool isAuthenticated = await authenticateUser();

    if (isAuthenticated) {
      // Get the current user's account number from Firestore
      final currentUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      final currentUserAccountNumber = currentUser['account_number'];
      final currentUserBalance = currentUser['balance'];

      // Get the destination account number from the text field
      final destinationAccountNumber = destinationAccountController.text;

      // Fetch the destination user's document from Firestore
      final destinationUser = await FirebaseFirestore.instance
          .collection('users')
          .where('account_number', isEqualTo: destinationAccountNumber)
          .get();

      // Check if the destination account exists
      if (destinationUser.docs.isNotEmpty) {
        final destinationUserData = destinationUser.docs.first.data();
        final destinationUserBalance = destinationUserData['balance'];

        // Perform the balance transfer
        final transferAmount = double.tryParse(transferAmountController.text);

        if (transferAmount != null && transferAmount > 0) {
          if (currentUserBalance >= transferAmount) {
            // Update the balances for both users
            await FirebaseFirestore.instance.runTransaction((transaction) async {
              transaction.update(currentUser.reference, {
                'balance': currentUserBalance - transferAmount,
              });

              transaction.update(destinationUser.docs.first.reference, {
                'balance': destinationUserBalance + transferAmount,
              });
            });

            final snackBar = const SnackBar(
                backgroundColor: Color(0xff9BA4B5),
                content: Text('Balance transferred successfully'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            final snackBar = const SnackBar(
                backgroundColor: Color(0xff9BA4B5),
                content: Text('Insufficient balance'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          final snackBar = const SnackBar(
              backgroundColor: Color(0xff9BA4B5),
              content: Text('Invalid transfer amount'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        final snackBar = const SnackBar(
            backgroundColor: Color(0xff9BA4B5),
            content: Text('Destination account not found'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      final snackbar = const SnackBar(
        backgroundColor: Color(0xff9BA4B5),
        content: Text("Authentication failed. Transaction not completed."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cash Transfer',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff394867),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: sourceAccountController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: 'Source Account',
                labelText: 'Source Account Number',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(14),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: destinationAccountController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: 'Destination Account Number',
                border: OutlineInputBorder(),
                labelText: 'Destination Account',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(14),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: transferAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Transfer Amount',
                labelText: 'Transfer Amount',
                border: OutlineInputBorder(),
              ),
            ),
             const SizedBox(height: 20),
             Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  performBalanceTransfer();
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xff394867),
                  onPrimary: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
                child: const Text(
                  'Transfer',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
