import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/controllers/masterpassword_controller.dart';
import 'package:guardian_key/src/services/encryption_service.dart';

class CredentialModel {
  final String? id;
  final String websiteName;    // Name of the website/application
  final String email;
  final String password;
  final String userID;         // UserID for the website/application

  /// Constructor
  CredentialModel({
    this.id,
    required this.websiteName,
    required this.email,
    required this.password,
    required this.userID,
  });

  /// Convert model to Json structure so that you can use it to store data in Firebase
  Map<String, dynamic> toJson(String masterPassword) {
    final encryptionService = EncryptionService();

    final encryptedWebsiteName = encryptionService.encryptData(websiteName, masterPassword);
    final encryptedEmail = encryptionService.encryptData(email, masterPassword);
    final encryptedPassword = encryptionService.encryptData(password, masterPassword);
    
    Map<String, dynamic> data = {
      "WebsiteName": encryptedWebsiteName['encryptedText'],
      "WebsiteNameIV": encryptedWebsiteName['iv'],
      "Email": encryptedEmail['encryptedText'],
      "EmailIV": encryptedEmail['iv'],
      "Password": encryptedPassword['encryptedText'],
      "PasswordIV": encryptedPassword['iv'],
    };

    if (userID.isNotEmpty) {
      final encryptedUserID = encryptionService.encryptData(userID, masterPassword);
      data["UserID"] = encryptedUserID['encryptedText'];
      data["UserIDIV"] = encryptedUserID['iv'];
    }

    return data;
  }

  /// Map Json oriented document snapshot from Firebase to CredentialModel
  factory CredentialModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document, String masterPassword) {
    final data = document.data()!;
    final encryptionService = EncryptionService();
    
    String websiteName, userID, email, password;

    try {
      websiteName = encryptionService.decryptData(data["WebsiteName"], masterPassword, data["WebsiteNameIV"]);
      email = encryptionService.decryptData(data["Email"], masterPassword, data["EmailIV"]);
      password = encryptionService.decryptData(data["Password"], masterPassword, data["PasswordIV"]);
      
      // Only attempt to decrypt the userID if its IV is present
      if (data.containsKey("UserIDIV") && (data["UserIDIV"]?.isNotEmpty ?? false)) {
        userID = encryptionService.decryptData(data["UserID"], masterPassword, data["UserIDIV"]);
      } else {
        userID = "";
      }
    } catch (error) {
      print('Decryption error: $error');
      // You should handle this more gracefully. Maybe set them to empty strings or throw an error.
      websiteName = "";
      userID = "";
      email = "";
      password = "";
    }

    return CredentialModel(
      id: document.id,
      websiteName: websiteName,
      userID: userID,
      email: email,
      password: password
    );
  }
}
