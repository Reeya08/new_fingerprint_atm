import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_fingerprint_atm/infrastructure/models/user_model.dart';
import 'package:new_fingerprint_atm/infrastructure/services/user_services.dart';
import '../home/home_view.dart';

class PinInputScreen extends StatefulWidget {
  const PinInputScreen({Key? key}) : super(key: key);

  @override
  State<PinInputScreen> createState() => _PinInputScreenState();
}

class _PinInputScreenState extends State<PinInputScreen> {
  final TextEditingController atmPinController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final OutlineInputBorder textInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18.0),
    borderSide: const BorderSide(color: Color(0xff394867), width: 1),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your 4-digit PIN', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color:Color(0xff394867),
        ),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                  if (value.length != 4 || !isNumeric(value)) {
                    return 'PIN must be 4 digits with no characters';
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
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff394867),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final enteredPin = int.tryParse(atmPinController.text);

                      if (enteredPin != null) {
                        final User? user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          // Use the current user's ID to fetch their data from Firestore
                          String currentUserId = user.uid;
                          UserServices userServices = UserServices();
                          UserModel currentUser = await userServices.getUserData(currentUserId);

                          if (enteredPin == currentUser.pin) {
                            // PINs match, navigate to the next screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                            );
                          } else {
                            // PINs do not match, show an error message with delay
                            Future.delayed(Duration.zero, () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('PIN does not match. Please try again.'),
                              ));
                            });
                          }
                        } else {
                          // User not authenticated
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Color(0xff9BA4B5),
                            content: Text('User not authenticated. Please log in.'),
                          ));
                        }
                      } else {
                        // Handle the case where the PIN is not a valid integer
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Color(0xff9BA4B5),
                          content: Text('Invalid PIN format. Please enter a 4-digit number.'),
                        ));
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  bool isNumeric(String? value) {
    if (value == null) {
      return false;
    }
    return double.tryParse(value) != null;
  }
}
