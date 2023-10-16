import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guardian_key/src/features/authentication/screens/widgets/homepagefunction/Addboxes/Addcredential.dart';
import 'package:guardian_key/src/constants/constants.dart';
import 'package:guardian_key/src/constants/text_strings.dart';
import 'package:guardian_key/src/features/authentication/controllers/profile_controller.dart';
import 'package:guardian_key/src/features/authentication/models/credential_model.dart';
import 'package:guardian_key/src/services/login_service.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

class CredentialsSection extends StatefulWidget {
  @override
  _CredentialsSectionState createState() => _CredentialsSectionState();
}

class _CredentialsSectionState extends State<CredentialsSection> {
  List<CredentialModel> displayedPasswords = [];
  final weakPasswordAlertNotifier = ValueNotifier<bool>(false);


  final TextEditingController _searchController = TextEditingController();
    final loginService = LoginService();



    @override
    void initState() {
      super.initState();
      _fetchUserData();
      _searchController.addListener(_onSearchChanged);
    }

      _fetchUserData() async {
      final controller = ProfileController.instance;
      final user = await controller.getUserData();
      final passwordData = await loginService.fetchPasswordData();

      setState(() {
        displayedPasswords = passwordData;  // Update the displayedPasswords list with the fetched data
      });
    }

    Future<void> _refreshData() async {
    try {
      await _fetchUserData();  // This fetches and updates your data
      setState(() {}); // This ensures the UI is refreshed
    } catch (error) {
      // Handle any errors here
      print('Error refreshing data: $error');
    }
  }

    void _onSearchChanged() {
      final input = _searchController.text;

      if (input.isNotEmpty) {
        final matchingPasswords = displayedPasswords.where((login) =>
            login.websiteName.toLowerCase().contains(input.toLowerCase()));
        final nonMatchingPasswords = displayedPasswords.where((password) =>
            !password.websiteName.toLowerCase().contains(input.toLowerCase()));
        setState(() {
          displayedPasswords = [...matchingPasswords, ...nonMatchingPasswords];
        });
      } else {
        _fetchUserData(); // Fetch data again when search is cleared
      }
    }

      @override
    void dispose() {
      weakPasswordAlertNotifier.dispose();
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
                  child: Row(
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
                HeadingText("Credentials"),
                const SizedBox(height: 10),
                searchText(tSearchbox),
                const SizedBox(height: 10),
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: displayedPasswords.length,
                    itemBuilder: (context, index) {
                      final password = displayedPasswords[index];
                      return PasswordTile(
                        password,
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



  Widget PasswordTile(CredentialModel passwordO, BuildContext context, {bool highlight = false}) {
  final strength = PasswordStrength.calculate(text: passwordO.password);

  weakPasswordAlertNotifier.value = strength == PasswordStrength.alreadyExposed || strength == PasswordStrength.weak;

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
            child: EditIconButton(passwordO, context),
          ),

          // Details (website name and email)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    passwordO.websiteName,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 22, 22, 22),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    passwordO.email,
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

          // Alert Icon
          Expanded(
            flex: 1,
            child: weakPasswordAlertNotifier.value
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.warning, color: Colors.red),
                  )
                : Container(), // Empty container if no alert
          ),

          // Copy Button
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: passwordO.password));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied to clipboard!')),
                );
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(
                  "assets/copy.svg",
                  semanticsLabel: 'Copy password icon',
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget EditIconButton(CredentialModel password, BuildContext context){
  return InkWell(
    onTap: () {
      bottomModal(context, passwordO: password);  // Pass the password object
    },
    child: Icon(Icons.edit, color: Colors.black),
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
            padding: const EdgeInsets.fromLTRB(
                20, 5, 5, 5), // add padding to adjust icon
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


Future<dynamic> bottomModal(BuildContext context, {CredentialModel? passwordO}){
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
                child: AddModal(passwordO: passwordO),  // Pass the passwordO to AddModal
              ),
            )
          ]);
        }
        ).then((Value){
          _fetchUserData();
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
