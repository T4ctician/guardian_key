import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/constants/constants.dart';
import 'package:guardian_key/src/features/authentication/models/creditcard_model.dart'; 
import 'package:guardian_key/src/features/authentication/controllers/addcreditcard_controller.dart';
import 'package:guardian_key/src/services/creditcard_service.dart';


class Addcreditcard extends StatefulWidget {
  final CreditCardModel? cardO;

  const Addcreditcard({Key? key, this.cardO}) : super(key: key);

  @override
  _AddcreditcardState createState() => _AddcreditcardState();
}

class _AddcreditcardState extends State<Addcreditcard> {
  String? selectedCardName;
  String? selectedCardId;
  String? userId;
  bool isCardNumberObscured = true;
  bool isCvvObscured = true;

  void Function()? toggleObscure;

  List<String> months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"];
  List<String> years = List<String>.generate(31, (int index) => (DateTime.now().year + index).toString());

  String selectedMonth = "01";
  String selectedYear = DateTime.now().year.toString();


  final CreditCardService creditCardService = CreditCardService();

  TextEditingController cardNameController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController issuingBankController = TextEditingController(); 
  TextEditingController noteController = TextEditingController(); 
  final monthController = TextEditingController();
  final yearController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (widget.cardO != null) {
      cardNameController.text = widget.cardO!.cardholderName ?? "";
      cardNumberController.text = widget.cardO!.creditCardNumber ?? "";
      cvvController.text = widget.cardO!.cvv ?? "";
      issuingBankController.text = widget.cardO!.issuingBank ?? "";
      noteController.text = widget.cardO!.note ?? "";

      // Extract the month and year from the expiryDate and assign to the controllers
      if (widget.cardO!.expiryDate != null && widget.cardO!.expiryDate.contains('/')) {
        List<String> splitDate = widget.cardO!.expiryDate.split('/');
        monthController.text = splitDate[0];
        yearController.text = splitDate[1];
      } else {
        monthController.text = "";
        yearController.text = "";
      }
    }

        toggleObscure = () {
        // Logic to toggle the obscuring of the text.
        // For instance, if you're using an `obscureText` boolean property:
        // setState(() {
        //     obscureText = !obscureText;
        // });
    };
  }

  @override
  void dispose() {
    cardNameController.dispose();
    cardNumberController.dispose();
    monthController.dispose();  // Dispose of the monthController
    yearController.dispose();   // Dispose of the yearController
    cvvController.dispose();
    issuingBankController.dispose();
    noteController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: screenWidth * 0.4,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 156, 156, 156),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            creditCardContainer(context, creditCardService),
            Column(
              children: [
                formHeading("CardHolder Name"),
                creditCardField("Enter Cardholder Name", Icons.credit_card, controller: cardNameController),
                formHeading("Card Number"),
                creditCardField("Enter Card Number", Icons.credit_card, controller: cardNumberController),
                formHeading("Valid Date till"),
                expiryDateRow(),
                formHeading("CVV"),
                creditCardField("Enter CVV", Icons.security, controller: cvvController),
                formHeading("Issuing Bank"),
                creditCardField("Enter Issuing Bank", Icons.business, controller: issuingBankController),
                formHeading("Note"),
                creditCardField("Enter Note", Icons.note, controller: noteController),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ok Done Button
                SizedBox(
                  height: screenHeight * 0.065,
                  width: screenWidth * 0.8,
                  child: ElevatedButton(
                    onPressed: () async {
                      String cardName = cardNameController.text.trim();
                      String cardNumber = cardNumberController.text.trim().replaceAll('-', '');
                      String expiryDate = "$selectedMonth/$selectedYear";
                      String cvv = cvvController.text.trim();
                      String issuingBank = issuingBankController.text.trim();
                      String note = noteController.text.trim();

                      if (cardName.isEmpty || cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty || issuingBank.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please fill out all required fields.',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      if (cardNumber.length != 16) {
                        Get.snackbar(
                          'Error',
                          'Card number must have 16 digits.',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      if (cvv.length < 3) {
                        Get.snackbar(
                          'Error',
                          'CVV should be at least 3 digits.',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      CreditCardModel card = CreditCardModel(
                        id: widget.cardO?.id,
                        cardholderName: cardName,
                        creditCardNumber: cardNumber,
                        expiryDate: expiryDate,
                        cvv: cvv,
                        issuingBank: issuingBank,
                        note: note,
                      );

                      CreditCardModel? existingCard = await CreditCardController.instance.fetchCardByCardholderNameBankAndLast4(cardName, issuingBank, cardNumber.substring(cardNumber.length - 4));

                      if (widget.cardO?.id != null) {
                        // This is an existing card, so update it.
                        CreditCardController.instance.updateCreditCard(card);
                    } else {
                        // This is a new card, so add it.
                        CreditCardController.instance.addCreditCard(card);
                    }

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Ok Done",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                // Red Circle Delete Button
                SizedBox(
                  height: screenHeight * 0.065,
                  width: screenHeight * 0.065,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.cardO?.id != null) {
                        bool? shouldDelete = await showConfirmationDialog(context);
                        if (shouldDelete == true) {
                          CreditCardController.instance.deleteCreditCard(widget.cardO!.id!);
                          Navigator.of(context).pop();
                        }
                      } else {
                        Get.snackbar(
                          'Error',
                          'This card cannot be deleted as it does not exist.',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget creditCardField(String hintText, IconData icon, {TextEditingController? controller}) {
    int? maxLength;
    TextInputType keyboardType = TextInputType.text;
    List<TextInputFormatter>? inputFormatters;
    bool isObscured = false;
    void Function()? toggleObscure;

    if (hintText.contains("Card Number")) {
      maxLength = 16;
      keyboardType = TextInputType.number;
      inputFormatters = [FilteringTextInputFormatter.digitsOnly];
      isObscured = isCardNumberObscured;
      toggleObscure = () {
        setState(() {
          isCardNumberObscured = !isCardNumberObscured;
        });
      };
    } else if (hintText.contains("Expiry Date")) {
      maxLength = 4;
    } else if (hintText.contains("CVV")) {
      maxLength = 3;
      keyboardType = TextInputType.number;
      inputFormatters = [FilteringTextInputFormatter.digitsOnly];
      isObscured = isCvvObscured;
      toggleObscure = () {
        setState(() {
          isCvvObscured = !isCvvObscured;
        });
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  controller: controller,
                  maxLength: maxLength,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  obscureText: isObscured,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
                      child: Icon(icon, color: Constants.searchGrey),
                    ),
                    suffixIcon: (toggleObscure != null)
                        ? IconButton(
                            icon: Icon(
                              isObscured ? Icons.visibility_off : Icons.visibility,
                              color: Constants.searchGrey,
                            ),
                            onPressed: toggleObscure,
                          )
                        : null,
                    filled: true,
                    contentPadding: const EdgeInsets.all(16),
                    hintText: hintText,
                    hintStyle: TextStyle(
                        color: Constants.searchGrey, fontWeight: FontWeight.w500),
                    fillColor: const Color.fromARGB(247, 232, 235, 237),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    counterText: "",
                  ),
                  style: const TextStyle(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget expiryDateRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 5),
            child: DropdownButtonFormField<String>(
              items: months.map((String month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
                  child: Icon(Icons.date_range, color: Constants.searchGrey),
                ),
                hintText: "Month",
                hintStyle: TextStyle(color: Constants.searchGrey, fontWeight: FontWeight.w500),
                fillColor: const Color.fromARGB(247, 232, 235, 237),
                filled: true,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedMonth = newValue!;
                });
              },
              value: selectedMonth,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 10),
            child: DropdownButtonFormField<String>(
              items: years.map((String year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
                  child: Icon(Icons.date_range, color: Constants.searchGrey),
                ),
                hintText: "Year",
                hintStyle: TextStyle(color: Constants.searchGrey, fontWeight: FontWeight.w500),
                fillColor: const Color.fromARGB(247, 232, 235, 237),
                filled: true,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedYear = newValue!;
                });
              },
              value: selectedYear,
            ),
          ),
        ),
      ],
    );
  }


  Widget formHeading(String text) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget creditCardContainer(BuildContext context, CreditCardService creditCardService) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            showAddModal(context);
          },
          child: Container(
            height: 55,
            width: 120,
            decoration: BoxDecoration(
              color: Constants.logoBackground,
              borderRadius: BorderRadius.circular(20)),
            child: FractionallySizedBox(
              heightFactor: 0.5,
              widthFactor: 0.5,
              child: Container(
                child: const Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Add",
                      style: TextStyle(fontSize: 14),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: 60,
              width: screenWidth * 0.6,
              child: FutureBuilder<List<CreditCardModel>>(
                future: creditCardService.fetchCreditCardData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<CreditCardModel> cards = snapshot.data ?? [];
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: cards.length,
                      itemBuilder: (context, index) => creditCardBlock(cards[index], context),
                    );
                  }
                },
              )
            ),
          ),
        ),
      ],
    );
  }

  void showAddModal(BuildContext context, {CreditCardModel? cardO}) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bc) {
        return Wrap(children: <Widget>[
          Container(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: Addcreditcard(cardO: cardO),
            ),
          )
        ]);
      },
    );
  }

Widget creditCardBlock(CreditCardModel card, BuildContext context) {
    String lastFourDigits = card.creditCardNumber != null && card.creditCardNumber.length >= 4
        ? card.creditCardNumber.substring(card.creditCardNumber.length - 4)
        : "";

    bool isHighlighted = widget.cardO?.id == card.id;

    return GestureDetector(
        onTap: () {
            setState(() {
                selectedCardId = card.id; // Update the selected card ID
            });

            // Open the modal to show the card details
            showAddModal(context, cardO: card);
        },
        child: Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 3, 6, 3),
            child: Container(
                width: 140,
                height: 70,
                decoration: BoxDecoration(
                    color: isHighlighted ? Colors.blue : Constants.logoBackground,
                    borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Text(
                            card.issuingBank ?? "",
                            style: TextStyle(
                                fontSize: 12,
                                color: isHighlighted ? Colors.white : Colors.black,
                            ),
                        ),
                        SizedBox(height: 5),
                        Text(
                            "$lastFourDigits",
                            style: TextStyle(
                                fontSize: 12,
                                color: isHighlighted ? Colors.white : Colors.black,
                            ),
                        ),
                    ],
                ),
            ),
        ),
    );
}


  Future<bool?> showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this card?'),
          actions: <Widget>[
            TextButton(
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  Text('Yes', style: TextStyle(color: Colors.green)),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Row(
                children: [
                  Icon(Icons.close, color: Colors.red),
                  Text('No', style: TextStyle(color: Colors.red)),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }
}
