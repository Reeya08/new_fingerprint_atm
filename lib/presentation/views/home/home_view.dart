import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_fingerprint_atm/infrastructure/services/auth_services.dart';
import 'package:new_fingerprint_atm/presentation/views/cash_transfer/cash_transfer_view.dart';
import 'package:new_fingerprint_atm/presentation/views/withdrraw/withdraw_view.dart';

import '../../../infrastructure/models/user_model.dart';
import '../balance_inquiry/balance_inquiry_view.dart';
class HomeScreen extends StatelessWidget {
  @override
  UserModel? _currentUser; // Assuming _currentUser is a private property within AuthServices

  UserModel? get currentUser => _currentUser;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF1F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('ATM Options', style:  TextStyle(
          color: Color(0xff394867),
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              OptionButton(
                title: 'Withdraw',
                icon: Icons.monetization_on,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WithdrawScreen(),
                    ),
                  );
                },
              ),

              OptionButton(
                title: 'Balance Inquiry',
                icon: Icons.account_balance,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BalanceInquiryScreen(accountBalance: 70000000,)));
                },
              ),
              OptionButton(
                title: 'Cash Transfer',
                icon: Icons.compare_arrows,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CashTransferScreen()));
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
class OptionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  OptionButton({required this.title, required this.icon, required this.onPressed});

@override
Widget build(BuildContext context) {
  return Container(
    margin: EdgeInsets.all(16.0),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Color(0xff394867),
        onPrimary: Colors.white,
        padding: EdgeInsets.all(16.0),
        minimumSize: Size(200, 80),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 36.0),
          SizedBox(height: 10.0),
          Text(
            title,
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    ),
  );
}
}
