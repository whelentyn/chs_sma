import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      print("User successfully registered! ${userCredential.user!.email}");

      displayMessage("User successfully registered! Redirecting...");
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
      });
    } catch (e) {
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
        title: const Text("Food\nCam"),
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Image.asset(
            'assets/logoFoodCam.png',
            width: 50,
            height: 50,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  SizedBox(height: 10),
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
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Color(0xFFD9D9D9),
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
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                          hintText: " Password",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Color(0xFFD9D9D9),
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
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _firstNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                          hintText: " First Name",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Color(0xFFD9D9D9),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your first name!";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _firstName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _lastNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                          hintText: " Last Name",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Color(0xFFD9D9D9),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your last name!";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _lastName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            handleSignUp();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          backgroundColor: const Color(0xFFD9D9D9),
                          padding: const EdgeInsets.all(5.0),
                        ),
                        child: const Icon(
                          Icons.done,
                          size: 40,
                          color: Color(0xFF545454),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}