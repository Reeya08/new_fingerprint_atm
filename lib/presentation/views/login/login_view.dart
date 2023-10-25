import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_fingerprint_atm/presentation/views/pin_input/pin_input_view.dart';
import 'package:new_fingerprint_atm/presentation/views/sign_up/sign_up_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
                Navigator.of(context).pop(false); // Return false to cancel the exit.
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
    if (!mounted) return;
    setState(() {
      if (authenticated) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PinInPutScreen(),
          ),

        );
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginView()));
        final snackBar = SnackBar(content: Text("Authentication failed"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
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
                  "Login",
                  style: TextStyle(
                    fontSize: 38,
                    color: Color(0xff394867),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Login using your fingerprint",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff9BA4B5),
                    fontWeight: FontWeight.bold,
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PinInPutScreen()));
                       });
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xffF1F6F9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not have an Account?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff9BA4B5),
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
                        },
                        child: Text(
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
        ),
      ),
    );
  }
}
