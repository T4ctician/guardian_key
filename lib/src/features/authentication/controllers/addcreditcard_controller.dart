import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/models/creditcard_model.dart';
import 'package:guardian_key/src/repository/creditcard_repository.dart';

class CreditCardController extends GetxController {
  static CreditCardController get instance => Get.find();

  /// Repositories
  final _creditCardRepo = CreditCardRepository.instance;

  /// Add a new credit card
  Future<void> addCreditCard(CreditCardModel card) async {
    try {
      await _creditCardRepo.createCreditCard(card);
      Get.snackbar("Success", "Credit Card added successfully!",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

  /// Update a credit card
  Future<void> updateCreditCard(CreditCardModel card) async {
    try {
      await _creditCardRepo.updateCreditCardRecord(card);
      Get.snackbar("Success", "Credit Card updated successfully!",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

  /// Delete a credit card
  Future<void> deleteCreditCard(String cardId) async {
    try {
      await _creditCardRepo.deleteCreditCard(cardId);
      Get.snackbar("Success", "Credit Card deleted successfully!",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

/// Fetch a credit card by its cardholder name, issuing bank, and last 4 digits
Future<CreditCardModel?> fetchCardByCardholderNameBankAndLast4(String cardholderName, String issuingBank, String last4Digits) async {
    return await _creditCardRepo.getCreditCardByCardholderNameBankAndLast4(cardholderName, issuingBank, last4Digits);
}

/// Fetch all credit cards by cardholder name and issuing bank
Future<List<CreditCardModel>> fetchCardsByCardholderNameAndBank(String cardholderName, String issuingBank) async {
    return await _creditCardRepo.getCreditCardByCardholderNameAndBank(cardholderName, issuingBank);
}
}
