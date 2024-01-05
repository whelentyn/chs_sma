import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String _email = "";
  String _password = "";
  String _firstName = "";
  String _lastName = "";
  void displayMessage(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
      print("User successfully registered! ${userCredential.user!.email}");

      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
      });

      displayMessage("User successfully registered! Redirecting...");
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
      });

    } catch(e) {
      print("Error during registration: $e");
      displayMessage("Error during registration: $e", isError: true);
    } finally {
      _emailController.clear();
      _passController.clear();
      _firstNameController.clear();
      _lastNameController.clear();

      setState(() {
        _email = "";
        _password = "";
        _firstName = "";
        _lastName = "";
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
            )
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
                    "Sign Up",
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
                padding: const EdgeInsets.all(16),
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
                          fillColor: Color(0xFFD9D9D9),
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty) {
                            return "Please enter your email address!";
                          }
                          return null;
                        },
                        onChanged: (value){
                          setState(() {
                            _email = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                          hintText: " Password",
                          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30),),
                          filled: true,  // Set to true to enable background color
                          fillColor: Color(0xFFD9D9D9),
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty) {
                            return "Please enter your password!";
                          }
                          return null;
                        },
                        onChanged: (value){
                          setState(() {
                            _password = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _firstNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                          hintText: " First Name",
                          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30),),
                          filled: true,  // Set to true to enable background color
                          fillColor: Color(0xFFD9D9D9),
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty) {
                            return "Please enter your first name!";
                          }
                          return null;
                        },
                        onChanged: (value){
                          setState(() {
                            _firstName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _lastNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                          hintText: " Last Name",
                          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30),),
                          filled: true,  // Set to true to enable background color
                          fillColor: Color(0xFFD9D9D9),
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty) {
                            return "Please enter your last name!";
                          }
                          return null;
                        },
                        onChanged: (value){
                          setState(() {
                            _lastName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: (){
                          if(_formKey.currentState!.validate()) {
                            handleSignUp();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0), // Set a high value for a rounded square
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
                    ],
                  ),
                ),
              ),
            ),
          ]
      ),
    );
  }
}


