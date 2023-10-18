import 'package:cloud_firestore/cloud_firestore.dart';

class CreditCardModel {
  final String? id;
  final String issuingBank;
  final String cardholderName;
  final String creditCardNumber;
  final String expiryDate;
  final String cvv;
  final String note;

  /// Constructor
  const CreditCardModel({
    this.id,
    required this.issuingBank,
    required this.cardholderName,
    required this.creditCardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.note,
  });

  /// Convert model to Json structure so that you can use it to store data in Firebase
  Map<String, dynamic> toJson() {
    return {
      "IssuingBank": issuingBank,
      "CardholderName": cardholderName,
      "CreditCardNumber": creditCardNumber,
      "ExpiryDate": expiryDate,
      "CVV": cvv,
      "Note": note,
    };
  }

  /// Map Json oriented document snapshot from Firebase to CreditCardModel
  factory CreditCardModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){
    final data = document.data()!;
    return CreditCardModel(
      id: document.id,
      issuingBank: data["IssuingBank"],
      cardholderName: data["CardholderName"],
      creditCardNumber: data["CreditCardNumber"],
      expiryDate: data["ExpiryDate"],
      cvv: data["CVV"],
      note: data["Note"],
    );
  }

  /// Get the last 4 digits of the credit card number
  String get last4Digits {
    if (creditCardNumber.length >= 4) {
      return creditCardNumber.substring(creditCardNumber.length - 4);
    } else {
      return creditCardNumber;  // If credit card number is less than 4 digits, return the whole number
    }
  }
}
