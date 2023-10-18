import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/models/creditcard_model.dart';  // Note: Adjust the import path
import 'package:guardian_key/src/repository/exceptions/t_exceptions.dart';

class CreditCardRepository extends GetxController {
  static CreditCardRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  // Get the user's UID dynamically
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Check if the user is logged in
  String get checkUserId {
    final uid = userId;
    if (uid == null) throw Exception('No user logged in.');
    return uid;
  }

  /// Store credit card data
  Future<void> createCreditCard(CreditCardModel creditCard) async {
    try {
      await _db.collection("Users").doc(checkUserId).collection("CreditCards").add(creditCard.toJson());
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  /// Fetch specific credit card details by card number
  Future<CreditCardModel> getCreditCardDetails(String creditCardNumber) async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("CreditCards").where("CreditCardNumber", isEqualTo: creditCardNumber).get();
      if (snapshot.docs.isEmpty) throw 'No such credit card found';
      return CreditCardModel.fromSnapshot(snapshot.docs.first);
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  /// Update Credit Card
  Future<void> updateCreditCardRecord(CreditCardModel creditCard) async {
    try {
      await _db.collection("Users").doc(checkUserId).collection("CreditCards").doc(creditCard.id).update(creditCard.toJson());
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

  /// Delete Credit Card
  Future<void> deleteCreditCard(String id) async {
    try {
      await _db.collection("Users").doc(checkUserId).collection("CreditCards").doc(id).delete();
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code);
      throw result.message;
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (_) {
      throw 'Something went wrong. Please Try Again';
    }
  }

// Fetch a credit card by cardholder name, issuing bank, and last 4 digits
Future<CreditCardModel?> getCreditCardByCardholderNameBankAndLast4(
    String cardholderName, 
    String issuingBank, 
    String last4Digits) async {
    
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("CreditCards")
        .where("CardholderName", isEqualTo: cardholderName)
        .where("IssuingBank", isEqualTo: issuingBank)
        .where("Last4Digits", isEqualTo: last4Digits)  // Assuming you store the last 4 digits separately
        .get();
        
      if (snapshot.docs.isEmpty) return null;
      return CreditCardModel.fromSnapshot(snapshot.docs.first);
    } catch (e) {
        throw e.toString();
    }
}

Future<List<CreditCardModel>> getCreditCardByCardholderNameAndBank(String cardholderName, String issuingBank) async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("CreditCards")
          .where("CardholderName", isEqualTo: cardholderName)
          .where("IssuingBank", isEqualTo: issuingBank)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) => CreditCardModel.fromSnapshot(doc)).toList();
    } catch (e) {
        throw e.toString();
    }
}


  // Fetch all credit cards
  Future<List<CreditCardModel>> getAllCreditCards() async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("CreditCards").get();
      return snapshot.docs.map((doc) => CreditCardModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  // Stream to listen to all credit cards
  Stream<List<CreditCardModel>> listenToAllCreditCards() {
    return _db.collection("Users").doc(checkUserId).collection("CreditCards").snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => CreditCardModel.fromSnapshot(doc)).toList();
    });
  }
}
