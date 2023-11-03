import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_fingerprint_atm/presentation/views/home/home_view.dart';

import '../../../infrastructure/models/transfer_cash_model.dart';
import '../../../infrastructure/preferences/store_account_number_and_pin.dart';
import '../balance_inquiry/balance_inquiry_view.dart';

class CashTransferScreen extends StatefulWidget {
  @override
  _CashTransferScreenState createState() => _CashTransferScreenState();
}

class _CashTransferScreenState extends State<CashTransferScreen> {
  final TextEditingController sourceAccountController = TextEditingController();
  final TextEditingController destinationAccountController = TextEditingController();
  final TextEditingController transferAmountController = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  Future<void> authenticateUser() async {
    bool authenticated = false;

    try {
      authenticated = await _localAuthentication.authenticate(
        localizedReason: "Scan your finger to authenticate",
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (authenticated) {
      final snackBar = SnackBar(
          backgroundColor: Color(0xff9BA4B5),
          content: Text("Authentication Successful"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Retrieve user email and password from shared preferences
      final userData = await UserDataStorage.getUserEmailAndPassword();
      final email = userData[UserDataStorage.emailKey];
      final password = userData[UserDataStorage.passwordKey];

      if (email != null && password != null) {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // If authentication is successful, navigate to the PinInputScreen
          performBalanceTransfer();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomeScreen()));
        } catch (e) {
          final snackBar = SnackBar(
              backgroundColor: Color(0xff9BA4B5),
              content: Text("Authentication failed: $e"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CashTransferScreen()));
        }
      } else {
        // Handle the case where email and password are not found in shared preferences
        final snackBar = SnackBar(
            backgroundColor: Color(0xff9BA4B5),
            content: Text("User data not found"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CashTransferScreen()));
      }
    } else {
      final snackbar = SnackBar(
          backgroundColor: Color(0xff9BA4B5),
          content: Text("Authentication failed"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => CashTransferScreen()));
    }
  }
  Future<void> showTransactionDetailsBottomSheet(CashTransfer cashTransfer) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Transaction Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('From Account: ${cashTransfer.sourceAccountNumber}'),
              Text('To Account: ${cashTransfer.destinationAccountNumber}'),
              Text('Amount Transferred: ${cashTransfer.transferAmount}'),
              Text('Date and Time: ${cashTransfer.transferDate.toString()}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BalanceInquiryScreen()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff394867),
                  onPrimary: Colors.white,
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text('Check Balance'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff394867),
                  onPrimary: Colors.white,
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> performBalanceTransfer() async {
    // Replace with your logic to get sourceAccount, destinationAccount, transferAmount
    final sourceAccount = sourceAccountController.text;
    final destinationAccount = destinationAccountController.text;
    final transferAmount = double.tryParse(transferAmountController.text);

    // Save the cash transfer details to Firestore
    final cashTransfer = CashTransfer(
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      sourceAccountNumber: sourceAccount,
      destinationAccountNumber: destinationAccount,
      transferAmount: transferAmount ?? 0.0,
      transferDate: DateTime.now(),
    );

    final cashTransferRef = await FirebaseFirestore.instance.collection('cash_transfers').add(cashTransfer.toJson());

    cashTransferRef.get().then((DocumentSnapshot document) {
      final cashTransferDetails = CashTransfer.fromMap(document.data() as Map<String, dynamic>);
      showTransactionDetailsBottomSheet(cashTransferDetails);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Source Account Number',
                labelText: 'Source Account',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(14),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: destinationAccountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Destination Account Number',
                labelText: 'Destination Account',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(14),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: transferAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Transfer Amount',
                labelText: 'Transfer Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                 authenticateUser().then((value) {
                   sourceAccountController.clear();
                   destinationAccountController.clear();
                   transferAmountController.clear();
                 });
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff394867),
                  onPrimary: Colors.white,
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text(
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


