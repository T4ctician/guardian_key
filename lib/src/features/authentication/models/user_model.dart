// ignore: depend_on_referenced_packages
//import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String password;

  /// Constructor
  const UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
  });

  /// Convert model to Json structure so that you can use it to store data in Firebase
  Map<String, dynamic> toJson() {
    return {
      "FirstName": firstName,
      "LastName": lastName,
      "Email": email,
      "DateOfBirth": dateOfBirth,
      "Gender": gender,
      // Storing password in Firebase is not a secure practice. You should use Firebase Auth to manage user passwords.
    };
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory UserModel.fromSnapshot( document) { // remove DocumentSnapshot<Map<String, dynamic>> rmb to add back
    final data = document.data()!;
    return UserModel(
      id: document.id,
      email: data["Email"],
      password: "", // Do not store or read passwords from Firestore. This should be managed by Firebase Auth.
      firstName: data["FirstName"],
      lastName: data["LastName"],
      dateOfBirth: data["DateOfBirth"],
      gender: data["Gender"],
    );
  }
}

