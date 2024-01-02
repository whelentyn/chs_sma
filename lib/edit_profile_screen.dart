import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _newPassConfirmedController = TextEditingController();
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
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user.uid).get();
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
        // Update the user's first and last names
        await _firestore.collection('Users').doc(user.uid).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
        });

        // If new password fields are filled and match, update the password
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      label: Text("First name"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _lastNameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      label: Text("Last name"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _newPassController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      label: Text("New Password"),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value){
                      _newPassword = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _newPassConfirmedController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      label: Text("Confirm New Password"),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value){
                      if(value != _newPassController.text) {
                        return "Passwords do not match!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: handleEditProfile,
                    child: const Text("Update"),
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



