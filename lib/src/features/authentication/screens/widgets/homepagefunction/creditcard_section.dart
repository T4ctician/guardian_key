import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guardian_key/src/features/authentication/screens/widgets/homepagefunction/Addboxes/Addcreditcard.dart';
import 'package:guardian_key/src/constants/constants.dart';
import 'package:guardian_key/src/constants/text_strings.dart';
import 'package:guardian_key/src/features/authentication/models/creditcard_model.dart';
import 'package:guardian_key/src/services/creditcard_service.dart';

class CreditCardSection extends StatefulWidget {
  const CreditCardSection({super.key});

  @override
  _CreditCardSectionState createState() => _CreditCardSectionState();
}

class _CreditCardSectionState extends State<CreditCardSection> {
  List<CreditCardModel> displayedCreditCards = [];
  final TextEditingController _searchController = TextEditingController();
  final creditCardService = CreditCardService();

  @override
  void initState() {
    super.initState();
    _fetchCardData();
    _searchController.addListener(_onSearchChanged);
  }

  _fetchCardData() async {
    final cardData = await creditCardService.fetchCreditCardData();
    setState(() {
      displayedCreditCards = cardData;
    });
  }

  Future<void> _refreshData() async {
    try {
      await _fetchCardData();
      setState(() {});
    } catch (error) {
      print('Error refreshing card data: $error');
    }
  }

  void _onSearchChanged() {
    final input = _searchController.text;
    if (input.isNotEmpty) {
      final matchingCards = displayedCreditCards.where((card) =>
          card.cardholderName.toLowerCase().contains(input.toLowerCase()));
      final nonMatchingCards = displayedCreditCards.where((card) =>
          !card.cardholderName.toLowerCase().contains(input.toLowerCase()));
      setState(() {
        displayedCreditCards = [...matchingCards, ...nonMatchingCards];
      });
    } else {
      _fetchCardData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 30, 8, 0), // Added padding on top
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context); // Close the modal
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.home, size: 30,),
                      SizedBox(width: 30), // Give some spacing between the icon and text
                      Text(
                        "Homepage",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                HeadingText("Credit Cards"), // Adapted for credit cards
                const SizedBox(height: 10),
                searchText(tCardSearchbox), // Assuming you have a constant for the credit card search hint
                const SizedBox(height: 10),
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: displayedCreditCards.length, // Adapted for credit cards
                    itemBuilder: (context, index) {
                      final card = displayedCreditCards[index]; // Adapted for credit cards
                      return CreditCardTile( // Use the CreditCardTile widget
                        card,
                        context,
                        highlight: index == 0 && _searchController.text.isNotEmpty,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () => bottomModal(context),
          backgroundColor: Constants.fabBackground,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }


  // Update the tile widget to reflect credit card details
  Widget CreditCardTile(CreditCardModel cardO, BuildContext context, {bool highlight = false}) {
    // Mask the credit card number, displaying only the last 4 digits
    String maskedNumber = cardO.creditCardNumber != null && cardO.creditCardNumber.length >= 4
        ? "**** **** **** " + cardO.creditCardNumber.substring(cardO.creditCardNumber.length - 4)
        : "**** **** **** ****";

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 10),
      child: Container(
        decoration: BoxDecoration(
          color: highlight ? Colors.yellow.withOpacity(0.2) : null,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            // Edit Icon
            Expanded(
              flex: 1,
              child: EditIconButton(cardO, context),
            ),
            // Details (cardholder name, bank, masked credit card number, and expiry date)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${cardO.issuingBank}, ${cardO.cardholderName}",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 22, 22, 22),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "$maskedNumber ,\n Valid date: ${cardO.expiryDate}",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 39, 39, 39),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Copy Button for Credit Card Number
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: cardO.creditCardNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Credit Card Number copied to clipboard!')),
                  );
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(
                    "assets/copy.svg",
                    semanticsLabel: 'Copy credit card number icon',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



    Widget EditIconButton(CreditCardModel card, BuildContext context){
    return InkWell(
      onTap: () {
        bottomModal(context, cardO: card);  // Pass the note object
      },
      child: const Icon(Icons.edit, color: Colors.black),
    );
  }

  Widget HeadingText(String text) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10, 0, 0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

    Widget searchText(String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 5, 5), 
              child: Icon(
                Icons.search,
                color: Constants.searchGrey,
              ),
            ),
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
                borderRadius: BorderRadius.circular(20))),
        style: const TextStyle(),
      ),
    );
  }

  Future<dynamic> bottomModal(BuildContext context, {CreditCardModel? cardO}){
    return showModalBottomSheet(
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
                        topRight: Radius.circular(25.0))),
                child: Addcreditcard(cardO: cardO),  // Pass the cardO to Addcreditcard
              ),
            )
          ]);
        }
    ).then((Value){
      _fetchCardData();
    });
  }

  Widget bottomSheetWidgets(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: screenWidth * 0.4,
              height: 5,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 156, 156, 156),
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Container(
                height: 60,
                width: 130,
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
            ],
          ),
        ],
      ),
    );
  }
}
