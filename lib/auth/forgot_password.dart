import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String _message = '';

  void _resetPassword() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _message = 'Password reset link has been sent to your email.';
      });
    } catch (e) {
      setState(() {
        _message = 'An error occurred while trying to send password reset link';
      });
      print(e); // For debugging
    }

    setState(() {
      _isLoading = false;
    });
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
            padding: EdgeInsets.only(left: 15.0),
            child: Image.asset(
              'assets/logoFoodCam.png',
              width: 50,
              height: 50,
            )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email and we will send you a link to reset your password.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Color(0XAA7A7A7A)),
                  hintText: " Email",
                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(30)),
                  filled: true,
                  fillColor: Color(0xFFD9D9D9),
                ),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _resetPassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9D9D9),
                ),
                child: const Text('Send Password Reset Email', style: TextStyle(color: Color(0xFF545454))),
              ),
              const SizedBox(height: 20),
              Text(
                _message,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
