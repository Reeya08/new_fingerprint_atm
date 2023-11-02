import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../../infrastructure/preferences/store_account_number_and_pin.dart';
import '../home/home_view.dart';





class ChangePinView extends StatefulWidget {
  @override
  _ChangePinViewState createState() => _ChangePinViewState();
}

class _ChangePinViewState extends State<ChangePinView> {
  final TextEditingController pinUpdateController = TextEditingController();
  String? changPinMessage;
  final OutlineInputBorder textInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18.0),
    borderSide: const BorderSide(color: Color(0xff394867), width: 1),
  );
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

          // If authentication is successful
          changePin();
          Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
        } catch (e) {
          final snackBar = SnackBar(
              backgroundColor: const Color(0xff9BA4B5),
              content: Text("Authentication failed: $e"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangePinView()));
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
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Pin', style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color:Color(0xff394867),
        ),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
             const Text(
              'Change Account Pin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:Color(0xff394867),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: pinUpdateController,
              decoration: InputDecoration(
                labelText: 'ATM PIN (4 digits)',
                enabledBorder: textInputBorder,
                focusedBorder: textInputBorder,
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your PIN';
                }
                if (value.length != 4) {
                  return 'password must be 4 characters';
                }
                return null;
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  authenticateUser()
                     .then((value){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                  }).onError((error, stackTrace) {
                    Text(error.toString());
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xff394867),
                  onPrimary: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
                child: const Text(
                  'Update Pin',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> changePin() async {
    final newPinText = pinUpdateController.text;

    if (newPinText.isEmpty) {
      setState(() {
        changPinMessage = 'Please enter a new PIN.';
      });
      return;
    }

    final newPin = int.tryParse(newPinText);

    if (newPin == null || newPin.toString().length != 4) {
      setState(() {
        changPinMessage = 'Invalid PIN format. Please use a 4-digit number.';
      });
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDoc.update({'pin': newPin});

        setState(() {
          changPinMessage = 'PIN successfully updated!';
        });
      } catch (e) {
        setState(() {
          changPinMessage = 'An error occurred: $e';
        });
        // Display a Snackbar for pin change failure
        final snackBar = SnackBar(
          backgroundColor: const Color(0xff9BA4B5),
          content: Text("Pin not changed: $e"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      // User not authenticated
      setState(() {
        changPinMessage = 'User not authenticated. Please log in.';
      });
      // Display a Snackbar for pin change failure
      final snackBar = const SnackBar(
        backgroundColor: Color(0xff9BA4B5),
        content: Text("Pin not changed: User not authenticated."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }


  bool isNumeric(String? value) {
    if (value == null) {
      return false;
    }
    return int.tryParse(value) != null;
  }

}
