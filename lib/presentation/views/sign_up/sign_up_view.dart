import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_fingerprint_atm/infrastructure/services/auth_services.dart';
import '../../../infrastructure/models/user_model.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserModel userModel = UserModel();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  final OutlineInputBorder textInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18.0),
    borderSide: BorderSide(color: Color(0xff394867), width: 1),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    enabledBorder: textInputBorder,
                    focusedBorder: textInputBorder,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    enabledBorder: textInputBorder,
                    focusedBorder: textInputBorder,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!isEmail(value)) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: accountNumberController,
                  decoration: InputDecoration(
                    labelText: 'Account Number (14 digits)',
                    enabledBorder: textInputBorder,
                    focusedBorder: textInputBorder,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your account number';
                    }
                    if (value.length != 14 || !isNumeric(value)) {
                      return 'Account number must be 14 digits';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: pinController,
                  decoration: InputDecoration(
                    labelText: 'PIN (4 digits)',
                    enabledBorder: textInputBorder,
                    focusedBorder: textInputBorder,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your PIN';
                    }
                    if (value.length != 4 || !isNumeric(value)) {
                      return 'PIN must be 4 digits with no characters';
                    }
                    return null;
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: balanceController,
                  decoration: InputDecoration(
                    labelText: 'Account Balance (PKR)',
                    enabledBorder: textInputBorder,
                    focusedBorder: textInputBorder,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your account balance';
                    }
                    // Add specific validation for the balance format (e.g., numeric).
                    return null;
                  },
                ),
                SizedBox(height: 10,),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff394867),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      AuthServices().signUp(email: emailController.text, password: pinController.text).then((value) {    signUpUser();}).then((value) {
                        showSuccessMessageAndNavigateBack();
                      });

                    },
                    child: Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isNumeric(String? value) {
    if (value == null) {
      return false;
    }
    return int.tryParse(value) != null;
  }

  bool isEmail(String? value) {
    if (value == null) {
      return false;
    }
    final emailPattern = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
    );

    return emailPattern.hasMatch(value);
  }

  void signUpUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await AuthServices().signUp(
          email: emailController.text,
          password: pinController.text, // Using the PIN as the password in this example
        );
        await FirebaseFirestore.instance.collection('users').add({
          'accountNumber': userModel.accountNumber,
          'pin': userModel.pin,
          'balance': userModel.balance,
        });
        showSuccessMessageAndNavigateBack();
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void showSuccessMessageAndNavigateBack() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('User added successfully!'),
    ));

    nameController.clear();
    emailController.clear();
    accountNumberController.clear();
    pinController.clear();
    balanceController.clear();

    Navigator.of(context).pop();
  }
}
