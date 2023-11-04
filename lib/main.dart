import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:new_fingerprint_atm/presentation/views/splash/splash_view.dart';

import 'firebase_options.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FG ATM System",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffF1F6F9)),
        useMaterial3: true,
      ),
      home: SplashView(),
    );
  }
}