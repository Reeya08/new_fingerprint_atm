import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_fingerprint_atm/presentation/views/pin_input/pin_input_view.dart';

import '../../../infrastructure/preferences/store_account_number_and_pin.dart';


class BiomerticVerificationView extends StatefulWidget {
  const BiomerticVerificationView({Key? key}) : super(key: key);

  @override
  State<BiomerticVerificationView> createState() => _BiomerticVerificationViewState();
}
class _BiomerticVerificationViewState extends State<BiomerticVerificationView> {
  final LocalAuthentication auth = LocalAuthentication();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _showExitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Confirmation'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(
                    false,); // Return false to cancel the exit.
              },
            ),
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true to confirm the exit.
              },
            ),
          ],
        );
      },
    );

    if (result != null) {
      return result;
    } else {
      throw Exception('Exit confirmation dialog dismissed');
    }
  }
  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => PinInputScreen()));
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

  Future<bool> _onBackPressed() async {
    bool shouldNavigateBack = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Authentication Not Successful"),
        content: Text("Authentication was not successful. Do you want to go back to the login screen?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              shouldNavigateBack = false; // Continue with the current screen
              Navigator.push(context, MaterialPageRoute(builder: (context)=>BiomerticVerificationView()));
            },
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              shouldNavigateBack = true; // Go back to the login screen
              Navigator.push(context, MaterialPageRoute(builder: (context)=>BiomerticVerificationView()));
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
    return shouldNavigateBack;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitConfirmationDialog();
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: Color(0xffF1F6F9),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset("assets/images/fingerprint.png",
                      height: 150, width: 150),
                ),
                Text(
                  "Wellcome",
                  style: TextStyle(
                    fontSize: 38,
                    color: Color(0xff394867),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "To Our Biometric Scanning ATM System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff9BA4B5),

                  ),
                ),
                SizedBox(height: 40),
                Container(
                  height: 55,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff394867),
                    ),
                    onPressed: () {
                      _authenticate().then((value){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PinInputScreen()));
                      });
                    },
                    child: Text(
                      "Verify Your Identity",
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xffF1F6F9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}