import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_fingerprint_atm/presentation/views/cash_transfer/cash_transfer_view.dart';
import 'package:new_fingerprint_atm/presentation/views/change_pin/change_pin_view.dart';
import 'package:new_fingerprint_atm/presentation/views/withdrraw/withdraw_view.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/preferences/store_account_number_and_pin.dart';
import '../balance_inquiry/balance_inquiry_view.dart';
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
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
      final snackBar = const SnackBar(
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => BalanceInquiryScreen()));
        } catch (e) {
          final snackBar = SnackBar(content: Text("Authentication failed: $e"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
        }
      } else {
        // Handle the case where email and password are not found in shared preferences
        final snackBar = const SnackBar(
            backgroundColor: Color(0xff9BA4B5),
            content: Text("User data not found"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      final snackbar = const SnackBar(
          backgroundColor: Color(0xff9BA4B5),
          content: Text("Authentication failed"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
    }
  }

  UserModel? _currentUser;
 // Assuming _currentUser is a private property within AuthServices
  UserModel? get currentUser => _currentUser;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF1F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('ATM Options', style:  TextStyle(
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
              const SizedBox(width: 20),
              OptionButton(
                title: 'Balance Inquiry',
                icon: Icons.account_balance,
                onPressed: () {
                  authenticateUser();
                },
              ),

              OptionButton(
                title: 'Cash Transfer',
                icon: Icons.compare_arrows,
                onPressed: () {

                  Navigator.push(context, MaterialPageRoute(builder: (context) => CashTransferScreen()));
                },
              ),
              const SizedBox(height: 20),
              OptionButton(
                title: 'Change Pin',
                icon: Icons.pinch,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePinView()));
                },
              ),
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
    margin: const EdgeInsets.all(16.0),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: const Color(0xff394867),
        onPrimary: Colors.white,
        padding: const EdgeInsets.all(16.0),
        minimumSize: const Size(200, 80),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 36.0),
          const SizedBox(height: 10.0),
          Text(
            title,
            style: const TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    ),
  );
}
}
