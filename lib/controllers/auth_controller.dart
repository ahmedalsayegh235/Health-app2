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
    required String name,
    required String cpr,
    required String gender,
    String role = 'patient',
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection("users").doc(uid).set({
        "id": uid,
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
}
