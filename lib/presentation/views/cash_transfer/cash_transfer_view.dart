import 'package:flutter/material.dart';

class CashTransferScreen extends StatefulWidget {
  @override
  _CashTransferScreenState createState() => _CashTransferScreenState();
}

class _CashTransferScreenState extends State<CashTransferScreen> {
  final TextEditingController sourceAccountController = TextEditingController();
  final TextEditingController destinationAccountController = TextEditingController();
  final TextEditingController transferAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cash Transfer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Source Account:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: sourceAccountController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Source Account',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Destination Account:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: destinationAccountController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Destination Account',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Transfer Amount:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: transferAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final sourceAccount = sourceAccountController.text;
                  final destinationAccount = destinationAccountController.text;
                  final transferAmount = double.tryParse(transferAmountController.text);
                  if (sourceAccount.isNotEmpty &&
                      destinationAccount.isNotEmpty &&
                      transferAmount != null &&
                      transferAmount > 0) {
                    // Show a confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Transfer Successful'),
                          content: Text('You have transferred $transferAmount dollars from $sourceAccount to $destinationAccount.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Display a message for invalid input
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Invalid Input'),
                          content: Text('Please enter a valid source account, destination account, and transfer amount.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
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

  @override
  void dispose() {
    sourceAccountController.dispose();
    destinationAccountController.dispose();
    transferAmountController.dispose();
    super.dispose();
  }
}

