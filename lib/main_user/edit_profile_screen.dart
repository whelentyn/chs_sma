import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _newPassConfirmedController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String _newPassword = "";
  String _confirmNewPassword = "";
  String _firstName = "";
  String _lastName = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(user.uid).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null) {
        setState(() {
          _firstNameController.text = userData['firstName'] ?? "";
          _lastNameController.text = userData['lastName'] ?? "";
        });
      }
    }
  }

  void displayMessage(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void handleEditProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
        });
        if (_newPassword == _confirmNewPassword && _newPassword.isNotEmpty) {
          await user.updatePassword(_newPassword);
        } else if (_newPassword.isNotEmpty) {
          displayMessage("New passwords do not match!", isError: true);
          return;
        }

        displayMessage("Profile updated successfully!");
      }
    } catch (e) {
      print("Error during update: $e");
      displayMessage("Error during update: $e", isError: true);
    } finally {
      // Clear password fields
      _newPassController.clear();
      _newPassConfirmedController.clear();

      setState(() {
        _newPassword = "";
        _confirmNewPassword = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    alignment: Alignment.topLeft,
                    child: const Column(
                      children: [
                        SizedBox(height: 0),
                        Text(
                          "Change your information",
                          style: TextStyle(
                            color: Color(0xFF545454),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _firstNameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                      hintText: " First Name",
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30),),
                      filled: true,
                      fillColor: Color(0xFFD9D9D9),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _lastNameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                      hintText: " Last Name",
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30),),
                      filled: true,
                      fillColor: Color(0xFFD9D9D9),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(3),
                    alignment: Alignment.topLeft,
                    child: const Column(
                      children: [
                        SizedBox(height: 0),
                        Text(
                          "Change your password",
                          style: TextStyle(
                            color: Color(0xFF545454),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _newPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                      hintText: " New Password",
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30),),
                      filled: true,
                      fillColor: Color(0xFFD9D9D9),
                    ),
                    onChanged: (value) {
                      _newPassword = value;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _newPassConfirmedController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                      hintText: " Confirm New Password",
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30),),
                      filled: true,
                      fillColor: Color(0xFFD9D9D9),
                    ),
                    validator: (value) {
                      if (value != _newPassController.text) {
                        return "Passwords do not match!";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: handleEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD9D9D9),
                    ),
                    child: Text("Update", style: TextStyle(color: Color(0xFF545454))),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      _auth.signOut();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD9D9D9),
                    ),
                    child: Text("Log Out", style: TextStyle(color: Color(0xFF545454))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
