import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
class BalanceInquiryScreen extends StatefulWidget {


  @override
  _BalanceInquiryScreenState createState() => _BalanceInquiryScreenState();
}

class _BalanceInquiryScreenState extends State<BalanceInquiryScreen> {

  User? _user = FirebaseAuth.instance.currentUser;
  double _accountBalance = 0.0; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    if (_user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid) // Assuming your users are stored in a "users" collection
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _accountBalance = data['balance'] ?? 0.0;
          });
        } else {
          // Handle the case where the user's data doesn't exist in Firestore
          print("user not fount");
        }
      }).catchError((error) {
        // Handle errors while fetching data
        error.toString();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance Inquiry', style: TextStyle(
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
             const Center(
              child: Text(
                'Account Balance:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:Color(0xff394867),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '\$$_accountBalance', // Display the account balance'
                style: const TextStyle(
                  fontSize: 24,

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}