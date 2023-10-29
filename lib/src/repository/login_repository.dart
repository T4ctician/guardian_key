import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/models/credential_model.dart'; 
import 'package:guardian_key/src/repository/exceptions/t_exceptions.dart';

class LoginRepository extends GetxController {
  static LoginRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
 
  // Get the user's UID dynamically
  String? get userId => FirebaseAuth.instance.currentUser?.uid;


  // Check if the user is logged in
  String get checkUserId {
    final uid = userId;
    if (uid == null) throw Exception('No user logged in.');
    return uid;
  }

  /// Store login data
Future<void> createLogin(CredentialModel login, String masterPassword) async {
    try {
      await _db.collection("Users").doc(checkUserId).collection("Logins").add(login.toJson(masterPassword));
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }
  /// Fetch specific login details
  Future<CredentialModel> getLoginDetails(String email, String masterPassword) async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("Logins").where("Email", isEqualTo: email).get();
      if (snapshot.docs.isEmpty) throw 'No such login found';
      return CredentialModel.fromSnapshot(snapshot.docs.first, masterPassword);
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  /// Update Login details
  Future<void> updateLoginRecord(CredentialModel login, String masterPassword) async {
    Map<String, dynamic> loginData = login.toJson(masterPassword);
    try {
      if (login.userID.isEmpty) {
        // Explicitly delete the fields related to userID if it's empty
        await _db.collection("Users").doc(checkUserId).collection("Logins").doc(login.id).update({
          "UserID": FieldValue.delete(),
          "UserIDIV": FieldValue.delete()
        });
        await _db.collection("Users").doc(checkUserId).collection("Logins").doc(login.id).update(loginData);
      } else {
        await _db.collection("Users").doc(checkUserId).collection("Logins").doc(login.id).update(loginData);
      }
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  /// Handle Firebase Errors
  Exception handleFirebaseErrors(dynamic e) {
    if (e is FirebaseAuthException) {
      final result = TExceptions.fromCode(e.code);
      return Exception(result.message);
    } else if (e is FirebaseException) {
      return Exception(e.message.toString());
    } else {
      return Exception(e.toString().isEmpty ? 'Something went wrong. Please Try Again' : e.toString());
    }
  }

  /// Delete Login Data
Future<void> deleteLogin(String id) async {
  try {
      await _db.collection("Users").doc(checkUserId).collection("Logins").doc(id).delete();
  } on FirebaseAuthException catch (e) {
    final result = TExceptions.fromCode(e.code);
    throw result.message;
  } on FirebaseException catch (e) {
    throw e.message.toString();
  } catch (_) {
    throw 'Something went wrong. Please Try Again';
  }
}

// Fetch a login by website name
Future<CredentialModel?> getLoginByWebsiteName(String websiteName, String masterPassword) async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("Logins").where("WebsiteName", isEqualTo: websiteName).get();
      if (snapshot.docs.isEmpty) return null;
      return CredentialModel.fromSnapshot(snapshot.docs.first, masterPassword);
    } catch (e) {
        throw e.toString();
    }
}

  //
    Future<List<CredentialModel>> getAllLogins(String masterPassword) async {
        try {
            final snapshot = await _db.collection("Users").doc(checkUserId).collection("Logins").get();
            return snapshot.docs.map((doc) => CredentialModel.fromSnapshot(doc, masterPassword)).toList();
        } catch (e) {
            throw handleFirebaseErrors(e);
        }
    }

  // Inside the LoginRepository class
  Stream<List<CredentialModel>> listenToAllLogins(String masterPassword) {
    return _db.collection("Users").doc(checkUserId).collection("Logins").snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => CredentialModel.fromSnapshot(doc, masterPassword)).toList();
    });
}

    
}
