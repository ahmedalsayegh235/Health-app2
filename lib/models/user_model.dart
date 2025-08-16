import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? id;
  String? role;
  String? name;
  String? cpr;
  String? gender;

  User({this.id, this.role, this.name, this.cpr, this.gender});

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      role: data['role'],
      name: data['name'],
      cpr: data['cpr'],
      gender: data['gender'],
    );
  }
  Map<String, dynamic> toMap() {
    return {'role': role, 'name': name, 'cpr': cpr, 'gender': gender};
  }

  static Future<User?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return User.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
}
