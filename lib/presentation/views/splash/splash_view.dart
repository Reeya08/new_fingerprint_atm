import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_fingerprint_atm/presentation/views/biometric/biometric_verification_view.dart';
import 'package:new_fingerprint_atm/presentation/views/login/login_view.dart';
class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
     Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginView()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Image.asset("assets/images/logo.jpg",)),
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
    );
  }
}