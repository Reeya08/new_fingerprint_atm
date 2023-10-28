import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_fingerprint_atm/presentation/views/login/login_view.dart';

import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/preferences/store_account_number_and_pin.dart';
import '../../../infrastructure/services/auth_services.dart';
import '../../../infrastructure/services/user_services.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserModel userModel = UserModel();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController atmPinController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final UserServices _userServices = UserServices();

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
                SizedBox(
                  height: 10,
                ),
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
                SizedBox(
                  height: 10,
                ),
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(14),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: loginPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Login Password (6 digits)',
                    enabledBorder: textInputBorder,
                    focusedBorder: textInputBorder,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your PIN';
                    }
                    if (value.length != 6) {
                      return 'password must be 6 characters';
                    }
                    return null;
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: atmPinController,
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
                SizedBox(
                  height: 10,
                ),
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
                SizedBox(
                  height: 10,
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff394867),
                      onPrimary: Colors.white,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        AuthServices()
                            .signUp(
                          email: emailController.text,
                          password: loginPasswordController.text,
                        )
                            .then((UserCredential userCredential) {
                          User? user = userCredential
                              .user; // Make sure you define 'User' here

                          if (user != null) {
                            UserModel userModel = UserModel(
                              userId: user.uid,
                              pin: atmPinController.text,
                              name: nameController.text,
                              accountNumber: accountNumberController.text,
                              balance: balanceController.text,
                              email: emailController.text,
                              blocked: false,
                            );
                            _userServices.addUser(userModel);
                          }
                          // Save user email and password in shared preferences
                          UserDataStorage.saveUserEmailAndPassword(
                              emailController.text,
                              loginPasswordController.text);
                        }).then((value) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                nameController.clear();
                                emailController.clear();
                                balanceController.clear();
                                accountNumberController.clear();
                                atmPinController.clear();
                                loginPasswordController.clear();
                                FocusManager.instance.primaryFocus!.unfocus();
                                return AlertDialog(
                                  content: Text('Sign Up Successfully'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginView()));
                                      },
                                      child: Text("oK"),
                                    ),
                                  ],
                                );
                              });
                        }).onError((error, stackTrace) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                nameController.clear();
                                emailController.clear();
                                accountNumberController.clear();
                                loginPasswordController.clear();
                                atmPinController.clear();
                                balanceController.clear();
                                return AlertDialog(
                                  content: Text(error.toString()),
                                );
                              });
                        });
                      }
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

  bool isEmail(String? value) {
    if (value == null) {
      return false;
    }
    final emailPattern = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailPattern.hasMatch(value);
  }

  bool isNumeric(String? value) {
    if (value == null) {
      return false;
    }
    return int.tryParse(value) != null;
  }
}
