import 'package:new_fingerprint_atm/presentation/views/home/home_view.dart';
import 'package:new_fingerprint_atm/presentation/views/pin_input/pin_input_view.dart';
import 'package:new_fingerprint_atm/presentation/views/sign_up/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}
class _LoginViewState extends State<LoginView> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      if (canCheckBiometrics) {
        bool didAuthenticate = await _localAuthentication.authenticate(
          localizedReason: "Authenticate to login",
        );

        if (didAuthenticate) {
          // Authentication successful, you can proceed with login
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Athentication Successfull!",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, fontWeight:
                FontWeight.bold),), duration: Duration(seconds: 2), backgroundColor: Color(0xff394867),)
          );
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PinInputScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Athentication Failed!",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, fontWeight:
                FontWeight.bold),), duration: Duration(seconds: 2), backgroundColor: Color(0xff394867),)
          );
          // Authentication failed
        }
      } else {
        // Biometrics are not available on this device
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Oh! Biometric is not available on this device",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, fontWeight:
              FontWeight.bold),), duration: Duration(seconds: 2), backgroundColor: Color(0xff394867),)
        );
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
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
                onPressed: _authenticateWithBiometrics,
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
