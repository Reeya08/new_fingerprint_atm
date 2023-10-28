 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_fingerprint_atm/presentation/views/login/login_view.dart';
import '../../../infrastructure/models/transaction_model.dart';
import '../../../infrastructure/preferences/store_account_number_and_pin.dart';
import '../home/home_view.dart';
import '../pin_input/pin_input_view.dart';




  class WithdrawScreen extends StatefulWidget {
    @override
    _WithdrawScreenState createState() => _WithdrawScreenState();
  }

  class _WithdrawScreenState extends State<WithdrawScreen> {
    final TextEditingController withdrawalAmountController = TextEditingController();
    String? withdrawalMessage;

    Future<void> authenticateUser() async {
      bool authenticated = false;
      final LocalAuthentication _localAuthentication = LocalAuthentication();

      try {
        authenticated = await _localAuthentication.authenticate(
          localizedReason: "Scan your finger to authenticate",
        );
      } on PlatformException catch (e) {
        print(e);
      }

      if (authenticated) {
        final snackBar = SnackBar(content: Text("Authentication Successful"));
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawScreen()));
          } catch (e) {
            final snackBar = SnackBar(content: Text("Authentication failed: $e"));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          // Handle the case where email and password are not found in shared preferences
          final snackBar = SnackBar(content: Text("User data not found"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        final snackbar = SnackBar(content: Text("Authentication failed"));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
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
                     withdrawCash();
                   })
                .then((value) {
                     final snackbar = SnackBar(content: Text("Transaction Successfull"));
                     ScaffoldMessenger.of(context).showSnackBar(snackbar);
                   })..then((value){
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                   }).onError((error, stackTrace) {
                     Text(error.toString());
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
    // void withdrawFunds() async {
    //   String enteredAmount = withdrawalAmountController.text;
    //   final User? user = FirebaseAuth.instance.currentUser;
    //
    //   if (user != null) {
    //     // Use the current user's ID to fetch their data from Firestore
    //     String currentUserId = user.uid;
    //     UserServices userServices = UserServices();
    //     UserModel currentUser = await userServices.getUserData(currentUserId);
    //
    //     // Convert the entered amount to a double
    //     double withdrawalAmount = double.tryParse(enteredAmount) ?? 0.0;
    //
    //     if (withdrawalAmount <= 0) {
    //       // Display an error message for an invalid amount
    //       setState(() {
    //         withdrawalMessage = 'Invalid withdrawal amount. Please enter a valid amount.';
    //       });
    //     } else if (currentUser != null && currentUser.balance != null) {
    //       if (withdrawalAmount > currentUser.balance!) {
    //         // Display an error message if the withdrawal amount is greater than the balance
    //         setState(() {
    //           withdrawalMessage = 'Insufficient balance. Please enter a valid amount.';
    //         });
    //       } else {
    //         // Update the user's balance by subtracting the withdrawal amount
    //         double updatedBalance = currentUser.balance! - withdrawalAmount;
    //
    //         // Update the user's balance in Firestore
    //         await userServices.updateUserBalance(balance: updatedBalance);
    //
    //         // Display a success message
    //         setState(() {
    //           withdrawalMessage = 'Withdrawal successful!';
    //         });
    //       }
    //     } else {
    //       // Handle the case where currentUser or currentUser.balance is null
    //       setState(() {
    //         withdrawalMessage = 'User data not available. Please try again later.';
    //       });
    //     }
    //   } else {
    //     // User not authenticated
    //     setState(() {
    //       withdrawalMessage = 'User not authenticated. Please log in.';
    //     });
    //   }
    // }
    Future<void> withdrawCash() async {
      final withdrawalAmountText = withdrawalAmountController.text;
      if (withdrawalAmountText.isEmpty) {
        setState(() {
          withdrawalMessage = 'Please enter an amount.';
        });
        return;
      }

      final withdrawalAmount = double.tryParse(withdrawalAmountText);
      if (withdrawalAmount == null || withdrawalAmount <= 0) {
        setState(() {
          withdrawalMessage = 'Invalid amount.';
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
        final userData = userSnapshot.data();

        if (userData == null || !userData.containsKey('balance')) {
          setState(() {
            withdrawalMessage = 'User balance not found.';
          });
          return;
        }

        final double currentBalance = userData['balance'];
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
            );

            // Get a reference to the 'transactions' collection and add the transaction
            final transactionCollection =
            FirebaseFirestore.instance.collection('transactions');
            await transactionCollection.add(transactionData.toJson());

            // Update the withdrawal message
            setState(() {
              withdrawalMessage = 'Withdrawal successful!';
            });
          });
        } catch (e) {
          // Handle any errors that might occur during the transaction
          setState(() {
            withdrawalMessage = 'An error occurred: $e';
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
