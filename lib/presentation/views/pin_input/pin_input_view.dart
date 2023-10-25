import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_fingerprint_atm/infrastructure/services/auth_services.dart';
import '../home/home_view.dart';

class PinInPutScreen extends StatefulWidget {
  const PinInPutScreen({Key? key});

  @override
  State<PinInPutScreen> createState() => _PinInPutScreenState();
}

class _PinInPutScreenState extends State<PinInPutScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final OutlineInputBorder textInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18.0),
    borderSide: BorderSide(color: Color(0xff394867), width: 1),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Email and PIN'),
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
              SizedBox(height: 10),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final email = emailController.text;
                    final pin = pinController.text;
                    AuthServices().loginUser(email: email, pin: pin).then((value) {
                      emailController.clear();
                      pinController.clear();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    });
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isEmail(String? value) {
    if (value == null) {
      return false;
    }
    // You can add more email validation logic here if needed
    // For a simple check, you can use a regular expression pattern.
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
