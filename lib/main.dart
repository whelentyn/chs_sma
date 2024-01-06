import 'package:cooking_app/auth/login_screen.dart';
import 'package:cooking_app/auth/signup_screen.dart';
import 'package:cooking_app/recipe_handler/photo_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

//comment for testing

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initCamera();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme)),
      home: LoginScreen(),
    );
  }
}
