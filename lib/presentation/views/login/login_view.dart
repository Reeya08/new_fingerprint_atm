import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:new_fingerprint_atm/presentation/views/home/home_view.dart';
import 'package:new_fingerprint_atm/presentation/views/pin_input/pin_input_view.dart';
import 'package:new_fingerprint_atm/presentation/views/sign_up/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../infrastructure/preferences/store_account_number_and_pin.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}
class _LoginViewState extends State<LoginView> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF1F6F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset("assets/images/fingerprint.png",
                  height: 150, width: 150),
            ),
            const Text(
              "Wellcome!",
              style: TextStyle(
                fontSize: 28,
                color: Color(0xff394867),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Login using your fingerprint",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xff9BA4B5),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff394867),
                ),
                onPressed: authenticateUser,
                child: const Text(
                  "Authenticate",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xffF1F6F9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Not have an Account?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff9BA4B5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()));
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xff394867),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
