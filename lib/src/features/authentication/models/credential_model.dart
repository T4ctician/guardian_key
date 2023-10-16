import 'package:cloud_firestore/cloud_firestore.dart';

class CredentialModel {
  final String? id;
  final String websiteName;    // Name of the website/application
  final String email;
  final String password;
  final String userID;         // UserID for the website/application

  /// Constructor
  const CredentialModel({
    this.id,
    required this.websiteName,
    required this.email,
    required this.password,
    required this.userID,
  });

  /// Convert model to Json structure so that you can use it to store data in Firebase
  Map<String, dynamic> toJson() {
    return {
      "WebsiteName": websiteName,
      "UserID": userID,
      "Email": email,
      "Password": password,
    };
  }

  /// Map Json oriented document snapshot from Firebase to CredentialModel
  factory CredentialModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){
    final data = document.data()!;
    return CredentialModel(
      id: document.id,
      websiteName: data["WebsiteName"],
      userID: data["UserID"],
      email: data["Email"],
      password: data["Password"],

    );
  }
}
