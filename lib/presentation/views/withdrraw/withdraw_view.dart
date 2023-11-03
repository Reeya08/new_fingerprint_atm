import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_fingerprint_atm/presentation/views/home/home_view.dart';
import '../../../infrastructure/models/transaction_model.dart';
import '../../../infrastructure/preferences/store_account_number_and_pin.dart';
import '../balance_inquiry/balance_inquiry_view.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController withdrawalAmountController = TextEditingController();
  String? withdrawalMessage;
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  // Function to show the transaction details bottom sheet
  void showTransactionDetailsBottomSheet(String accountNumber, double amount, DateTime time) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Transaction Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('From Account: $accountNumber'),
              Text('Amount Withdrawn: $amount'),
              Text('Time: $time'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the balance inquiry screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BalanceInquiryScreen()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff394867),
                  onPrimary: Colors.white,
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text('Check Balance'),
              ),
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
          withdrawCash();
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } catch (e) {
          final snackBar = SnackBar(
              backgroundColor: Color(0xff9BA4B5),
              content: Text("Authentication failed: $e"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawScreen()));
        }
      } else {
        // Handle the case where email and password are not found in shared preferences
        final snackBar = SnackBar(
            backgroundColor: Color(0xff9BA4B5),
            content: Text("User data not found"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawScreen()));
      }
    } else {
      final snackbar = SnackBar(
          backgroundColor: Color(0xff9BA4B5),
          content: Text("Authentication failed"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw Cash'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Enter Withdrawal Amount:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Row of default amount buttons
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        setWithdrawalAmount(1000);
                      },
                      child: Text('1000'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setWithdrawalAmount(3000);
                      },
                      child: Text('3000'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setWithdrawalAmount(4000);
                      },
                      child: Text('4000'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        setWithdrawalAmount(2000);
                      },
                      child: Text('2000'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setWithdrawalAmount(5000);
                      },
                      child: Text('5000'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setWithdrawalAmount(10000);
                      },
                      child: Text('10000'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // Custom amount input field
            TextField(
              controller: withdrawalAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter other amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  borderSide: BorderSide(
                    color: Color(0xff394867),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  borderSide: BorderSide(
                    color: Color(0xff394867),
                    width: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  authenticateUser().then((value){
                    withdrawalAmountController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff394867),
                  onPrimary: Colors.white,
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text(
                  'Withdraw',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> withdrawCash() async {
    final withdrawalAmountText = withdrawalAmountController.text;
    if (withdrawalAmountText.isEmpty) {
      setState(() {
        withdrawalMessage = 'Please enter an amount.';
      });
      return;
    }

    double withdrawalAmount;
    try {
      withdrawalAmount = double.parse(withdrawalAmountText);
      if (withdrawalAmount <= 0) {
        setState(() {
          withdrawalMessage = 'Invalid amount.';
        });
        return;
      }
    } catch (e) {
      setState(() {
        withdrawalMessage = 'Invalid amount: $e';
      });
      return;
    }

    if (withdrawalAmount < 500 || withdrawalAmount > 50000) {
      setState(() {
        withdrawalMessage = 'Withdrawal amount must be between 500 and 50000.';
      });
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();

        if (userData != null) {
          final double currentBalance = userData['balance'] ?? 0;
          final String userAccountNumber = userData['account_number'] ?? '';

          if (userAccountNumber.isEmpty) {
            setState(() {
              withdrawalMessage = 'User account number is empty.';
            });
            return;
          }

          if (withdrawalAmount > currentBalance) {
            setState(() {
              withdrawalMessage = 'Insufficient balance.';
            });
            return;
          }

          try {
            await FirebaseFirestore.instance.runTransaction((transaction) async {
              // Update user's balance
              final newBalance = currentBalance - withdrawalAmount;
              transaction.update(userDoc, {'balance': newBalance});
              // Create a transaction record
              final transactionData = TransactionModel(
                userId: user.uid,
                amount: withdrawalAmount,
                date: Timestamp.now(),
                accountNumber: userAccountNumber,
              );

              // Get a reference to the 'transactions' collection and add the transaction
              final transactionCollection = FirebaseFirestore.instance.collection('transactions');
              final transactionDocRef = await transactionCollection.add(transactionData.toJson());

              // Retrieve the Firestore document ID for the transaction
              final transactionDocId = transactionDocRef.id;

              // Update the withdrawal message
              setState(() {
                withdrawalMessage = 'Withdrawal successful! Transaction ID: $transactionDocId';
              });

              // Show the transaction details in a bottom sheet
              showTransactionDetailsBottomSheet(userAccountNumber, withdrawalAmount, DateTime.now());
            });
          } catch (e) {
            setState(() {
              withdrawalMessage = 'An error occurred: $e';
            });
          }
        } else {
          // User data is null
          setState(() {
            withdrawalMessage = 'User data not found.';
          });
        }
      } else {
        // User document does not exist
        setState(() {
          withdrawalMessage = 'User document not found.';
        });
      }
    } else {
      // User not authenticated
      setState(() {
        withdrawalMessage = 'User not authenticated. Please log in.';
      });
    }
  }

  void setWithdrawalAmount(double amount) {
    withdrawalAmountController.text = amount.toString();
  }

  @override
  void dispose() {
    withdrawalAmountController.dispose();
    super.dispose();
  }
}
