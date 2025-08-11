import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/components/CustomTextFormField.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); // ✅ Add form key

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _cprController = TextEditingController();
  String? _selectedGender = "";

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    // ✅ Trigger validation first
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String uid = userCred.user!.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "id": uid,
        "name": _nameController.text.trim(),
        "cpr": _cprController.text.trim(),
        "role": 'patient',
        "gender": _selectedGender,
      });

      Navigator.pushReplacementNamed(context, 'home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey, // ✅ Wrap with Form
          child: Column(
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),

              CustomTextFormField(
                controller: _nameController,
                hintText: "Name",
                maxLines: 1,
                obscureText: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              CustomTextFormField(
                controller: _cprController,
                hintText: "CPR",
                maxLines: 1,
                obscureText: false,
                digitsOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your CPR";
                  }
                  if (value.length != 9) {
                    return "CPR must be 9 digits";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedGender!.isEmpty ? null : _selectedGender,
                items: ["Male", "Female"]
                    .map(
                      (gender) =>
                          DropdownMenuItem(value: gender, child: Text(gender)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value ?? "";
                  });
                },
                decoration: const InputDecoration(labelText: "Gender"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a gender";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              CustomTextFormField(
                controller: _emailController,
                hintText: "Email",
                obscureText: false,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              CustomTextFormField(
                controller: _passwordController,
                obscureText: true,
                hintText: "Password",
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a password";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                hintText: "Confirm Password",
                maxLines: 1,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signUp,
                      child: const Text("Sign Up"),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'login');
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
