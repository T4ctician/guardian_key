import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String dateOfBirth;
  final String gender;
  String? masterPasswordHash;

  /// Constructor
   UserModel({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.masterPasswordHash,
  });

  /// Convert model to Json structure so that you can use it to store data in Firebase
  Map<String, dynamic> toJson() {
    return {
      "FirstName": firstName,
      "LastName": lastName,
      "Email": email,
      "DateOfBirth": dateOfBirth,
      "Gender": gender,
      "MasterPasswordHash": masterPasswordHash

    };
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){
    final data = document.data()!;
    return UserModel(
      id: document.id,
      firstName: data["FirstName"],
      lastName: data["LastName"],
      email: data["Email"],
      dateOfBirth: data["DateOfBirth"],
      gender: data["Gender"],
      masterPasswordHash: data["MasterPasswordHash"], 
    );
  }
}

