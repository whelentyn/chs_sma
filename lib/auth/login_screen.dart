import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/auth/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'forgot_password.dart';
import '../main_user/main_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  String _email = "";
  String _password = "";

  void displayMessage(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void handleLogin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      print("User successfully logged in! ${userCredential.user!.email}");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()));
    } catch (e) {
      print("Error during login: $e");
      displayMessage("Error during login: $e", isError: true);
    } finally {
      _emailController.clear();
      _passController.clear();

      setState(() {
        _email = "";
        _password = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Food\nCam", style: GoogleFonts.lexendMega(
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
            height: 0.8,
            color: Color(0xFF545454)
        ),),
        leading: Padding(
          padding: EdgeInsets.only(left: 15.0), // Adjust the value as needed
          child: Image.asset(
            'assets/logoFoodCam.png', // Replace with the path to your custom icon
            width: 50, // Adjust the width as needed
            height: 50, // Adjust the height as needed
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Column(
              children: [
                /*Icon(
                  Icons.egg_alt, // Choose a food-related icon
                  size: 50,
                  color: Colors.yellow,
                ),*/
                SizedBox(height: 40),
                Text(
                  "Log In",
                  style: TextStyle(
                    color: Color(0xFF545454),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                        hintText: " Email",
                        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30),),
                        filled: true,  // Set to true to enable background color
                        fillColor: Color(0xAAD9D9D9),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email address!";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _email = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                        hintText: " Password",
                        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30),),
                        filled: true,  // Set to true to enable background color
                        fillColor: Color(0xAAD9D9D9),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password!";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _password = value;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          handleLogin();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          // Set a high value for a rounded square
                        ),
                        backgroundColor: const Color(0xFFD9D9D9),
                        padding: const EdgeInsets.all(5.0),
                      ),
                      child: const Icon(
                        Icons.done, // Choose a food-related icon
                        size: 40,
                        color: Color(0xFF545454),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SignUpScreen())),
                      child: const Text("Don't have an account? Sign up", style: TextStyle(color: Color(0xFF545454))),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                              const ForgotPasswordScreen())),
                      child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF545454))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
