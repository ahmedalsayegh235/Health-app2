import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? role;
  String? name;
  String? email;
  String? cpr;
  String? gender;
  static UserModel userData = UserModel();
  UserModel({this.id, this.email, this.role, this.name, this.cpr, this.gender});

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      role: data['role'],
      name: data['name'],
      email: data['email'],
      cpr: data['cpr'],
      gender: data['gender'],
    );
  }
  Map<String, dynamic> toMap() {
    return {'role': role, 'name': name, 'cpr': cpr, 'gender': gender};
  }

  static Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        UserModel fetchedUser = UserModel.fromFirestore(doc);
        userData = fetchedUser;
        return fetchedUser;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching UserModel: $e');
      return null;
    }
  }
}
