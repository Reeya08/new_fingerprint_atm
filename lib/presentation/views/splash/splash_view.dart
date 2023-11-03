import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_fingerprint_atm/presentation/views/login/login_view.dart';
class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {


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
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginView()));
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset("assets/images/logo.jpg")),
            Text(
              'FG ATM System',
              style: TextStyle(
                color: Color(0xff394867),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
