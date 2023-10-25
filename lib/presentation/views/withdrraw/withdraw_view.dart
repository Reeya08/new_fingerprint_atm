import 'package:flutter/material.dart';

import '../../../infrastructure/models/user_model.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController withdrawalAmountController = TextEditingController();
  UserModel? currentUser;
  String? withdrawalMessage;

  @override
  void initState() {
    super.initState();
    // Simulate fetching the current user data from a data source
    fetchCurrentUser();
  }

  void fetchCurrentUser() {
    // Simulated user data for demonstration
    currentUser = UserModel(
      userId: '123456',
      name: 'John Doe',
      accountNumber: '7890123456',
      pin: '1234',
      balance: '1000.0',
      blocked: false,
    );
  }

  void withdrawCash() {
    if (currentUser == null) {
      // User data is not available, handle this case.
      return;
    }

    final double withdrawalAmount =
        double.tryParse(withdrawalAmountController.text) ?? 0.0;

    if (withdrawalAmount <= 0) {
      // Withdrawal amount is not valid
      setState(() {
        withdrawalMessage = 'Invalid withdrawal amount.';
      });
      return;
    }

    final double currentBalance = double.parse(currentUser!.balance ?? '0.0');

    if (withdrawalAmount > currentBalance) {
      // Withdrawal amount is greater than the available balance
      setState(() {
        withdrawalMessage = 'Insufficient balance.';
      });
      return;
    }

    // Update the user's balance
    final updatedBalance = (currentBalance - withdrawalAmount).toString();
    currentUser!.balance = updatedBalance;

    // Simulate updating the user data in a data source
    // In a real app, replace this with actual data update logic.
    updateUserData(currentUser!);

    setState(() {
      withdrawalMessage = 'Withdrawal successful!';
    });

    // Navigate back to the home screen
    // Add your navigation logic here
    // For simplicity, we'll use Navigator.pop to return to the previous screen
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context, true);
    });
  }

  void updateUserData(UserModel user) {
    // Simulated update of user data
    // In a real app, replace this with actual data update logic.
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
            TextField(
              controller: withdrawalAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Amount',
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
                onPressed: withdrawCash,
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
            if (withdrawalMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  withdrawalMessage!,
                  style: TextStyle(
                    color: withdrawalMessage == 'Withdrawal successful!'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    withdrawalAmountController.dispose();
    super.dispose();
  }
}
