import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardian_key/src/services/encryption_service.dart';

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
  Map<String, dynamic> toJson(String masterPassword) {
      final encryptionService = EncryptionService();
      
      final encryptedIssuingBank = encryptionService.encryptData(issuingBank, masterPassword);
      final encryptedCardholderName = encryptionService.encryptData(cardholderName, masterPassword);
      final encryptedCreditCardNumber = encryptionService.encryptData(creditCardNumber, masterPassword);
      final encryptedExpiryDate = encryptionService.encryptData(expiryDate, masterPassword);
      final encryptedCVV = encryptionService.encryptData(cvv, masterPassword);

      Map<String, dynamic> data = {
        "IssuingBank": encryptedIssuingBank['encryptedText'],
        "IssuingBankIV": encryptedIssuingBank['iv'],
        "CardholderName": encryptedCardholderName['encryptedText'],
        "CardholderNameIV": encryptedCardholderName['iv'],
        "CreditCardNumber": encryptedCreditCardNumber['encryptedText'],
        "CreditCardNumberIV": encryptedCreditCardNumber['iv'],
        "ExpiryDate": encryptedExpiryDate['encryptedText'],
        "ExpiryDateIV": encryptedExpiryDate['iv'],
        "CVV": encryptedCVV['encryptedText'],
        "CVVIV": encryptedCVV['iv'],
      };

      // Only encrypt and add the note to the data if it's not empty
      if (note.isNotEmpty) {
        final encryptedNote = encryptionService.encryptData(note, masterPassword);
        data["Note"] = encryptedNote['encryptedText'];
        data["NoteIV"] = encryptedNote['iv'];
      }

      return data;
    }

  /// Map Json oriented document snapshot from Firebase to CreditCardModel
factory CreditCardModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document, String masterPassword) {
  final data = document.data()!;
  final encryptionService = EncryptionService();
  print('fromSnapshot method called for CreditCardModel');

  String issuingBank, cardholderName, creditCardNumber, expiryDate, cvv, note;

  try {
    issuingBank = encryptionService.decryptData(data["IssuingBank"], masterPassword, data["IssuingBankIV"]);
    cardholderName = encryptionService.decryptData(data["CardholderName"], masterPassword, data["CardholderNameIV"]);
    creditCardNumber = encryptionService.decryptData(data["CreditCardNumber"], masterPassword, data["CreditCardNumberIV"]);
    expiryDate = encryptionService.decryptData(data["ExpiryDate"], masterPassword, data["ExpiryDateIV"]);
    cvv = encryptionService.decryptData(data["CVV"], masterPassword, data["CVVIV"]);

    // Only attempt to decrypt the note if its IV is not empty
    if (data["NoteIV"]?.isNotEmpty ?? false) {
      note = encryptionService.decryptData(data["Note"], masterPassword, data["NoteIV"]);
    } else {
      note = "";
    }
  } catch (error) {
    print('Decryption error: $error');
    // You should handle this more gracefully. Maybe set them to empty strings or throw an error.
    issuingBank = "";
    cardholderName = "";
    creditCardNumber = "";
    expiryDate = "";
    cvv = "";
    note = "";
  }

  return CreditCardModel(
    id: document.id,
    issuingBank: issuingBank,
    cardholderName: cardholderName,
    creditCardNumber: creditCardNumber,
    expiryDate: expiryDate,
    cvv: cvv,
    note: note,
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
