// auth controller for reusability following the MVC pattern
// soo if we decide to change the auth logic, we only change it here
// and maybe when we make the admin and doctor views it will make life easier👍🏾
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Sign up and store user data in Firestore
  Future<User?> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String cpr,
    required String gender,
    String role = 'patient',
  }) async {
    // Check for empty fields
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        name.isEmpty ||
        cpr.isEmpty ||
        gender.isEmpty) {
      throw Exception("All fields are required.");
    }

    // Check email format
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      throw Exception("Please enter a valid email address.");
    }

    // Check password match
    if (password != confirmPassword) {
      throw Exception("Passwords do not match.");
    }

    // Check CPR format (9 digits)
    final cprRegex = RegExp(r"^\d{9}$");
    if (!cprRegex.hasMatch(cpr)) {
      throw Exception("CPR must be exactly 9 digits.");
    }

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      String uid = userCredential.user!.uid;

      await _firestore.collection("users").doc(uid).set({
        "id": uid,
        "email": email.trim(),
        "name": name.trim(),
        "cpr": cpr.trim(),
        "role": role,
        "gender": gender,
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  ///update user info
  Future<String> updateUser({
    required String userId,
    String? name,
    String? email,
    String? password,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      Map<String, dynamic> updates = {};

      if (name != null && name.trim().isNotEmpty) {
        updates['name'] = name.trim();
      }

      bool emailChanged = email != null && email.trim() != currentUser?.email;
      if (emailChanged) {
        if (password == null || password.isEmpty) {
          return "Password required to change email.";
        }

        final AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser!.email!,
          password: password,
        );
        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.verifyBeforeUpdateEmail(email.trim());

        // Optionally: update Firestore email field
        updates['email'] = email.trim();
      }

      if (updates.isNotEmpty) {
        await _firestore.collection("users").doc(userId).update(updates);
      }

      return emailChanged
          ? "Verification email sent to ${email!.trim()}. Please verify your new email address."
          : "Profile updated successfully.";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') return "The password you entered is incorrect.";
      if (e.code == 'requires-recent-login') return "This action requires you to re-login.";
      return "An error occurred: ${e.message}";
    } catch (e) {
      print(e);
      return "An unknown error occurred.";
    }
  }
}
