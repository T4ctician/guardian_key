import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/controllers/masterpassword_controller.dart';
import 'package:guardian_key/src/features/authentication/models/creditcard_model.dart'; 
import 'package:guardian_key/src/repository/creditcard_repository.dart';

class CreditCardService {
  final _creditCardRepo = CreditCardRepository.instance;

  Future<List<CreditCardModel>> fetchCreditCardData() async {
    return await _creditCardRepo.getAllCreditCards(masterPassword);
  }

  String get masterPassword {
    final masterPasswordController = Get.find<MasterPasswordController>();
    return masterPasswordController.masterPassword ?? '';  // if null, return an empty string
  }
  
  Future<List<String>> fetchCardholderNames() async {
    try {
      // Fetch your credit card data from the data source
      final List<CreditCardModel> data = await fetchCreditCardData();

      // Extract cardholder names from the credit card data
      final List<String> cardholderNames = data.map((card) => card.cardholderName).toList();

      return cardholderNames;
    } catch (e) {
      // Handle any errors here
      print('Error fetching cardholder names: $e');
      return [];
    }
  }

  Future<CreditCardModel?> getCreditCardByCardholderNameBankAndLast4(
      String cardholderName, 
      String issuingBank, 
      String last4Digits) async {
    try {
      final List<CreditCardModel> data = await fetchCreditCardData();
      
      // Find the credit card with the matching cardholder name, issuing bank, and last 4 digits
      final selectedCard = data.firstWhere(
        (card) => card.cardholderName == cardholderName && card.issuingBank == issuingBank && card.creditCardNumber.endsWith(last4Digits),
        orElse: () => const CreditCardModel(
          issuingBank: '',
          cardholderName: '',
          creditCardNumber: '',
          expiryDate: '',
          cvv: '',
          note: ''),
      );

      return selectedCard;
    } catch (e) {
      print('Error fetching credit card by cardholder name, issuing bank, and last 4 digits: $e');
      return null;
    }
  }

  Stream<List<CreditCardModel>> listenToAllCreditCards() {
    return _creditCardRepo.listenToAllCreditCards(masterPassword);
  }
}
