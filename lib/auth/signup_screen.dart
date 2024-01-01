import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  void handleSignUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
      print("User successfully registered! ${userCredential.user!.email}");

      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
      });
    } catch(e) {
      print("Error during registration: $e");
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
        title: const Text("Sign Up"),
      ),
      body: Center(
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
                  decoration: const InputDecoration(
                    label: Text("Email"),
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    label: Text("Password"),
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    label: Text("First name"),
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    label: Text("Last name"),
                    border: OutlineInputBorder(),
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
                  child: const Text("Sign Up"),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}


