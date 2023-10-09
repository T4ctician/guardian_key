import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guardian_key/AddModal.dart';
import 'package:guardian_key/src/constants/CategoryContainer.dart';
import 'package:guardian_key/src/constants/constants.dart';
import 'package:guardian_key/model/password_model.dart';
import 'package:guardian_key/src/constants/text_strings.dart';


class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  HomePageWidgetState createState() => HomePageWidgetState();
}

class HomePageWidgetState extends State<HomePageWidget> {
  List<passwords> displayedPasswords = List.from(Constants.passwordData);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final input = _searchController.text;
    List<passwords> matchingPasswords = [];
    List<passwords> nonMatchingPasswords = [];

    if (input.isNotEmpty) {
      for (var password in Constants.passwordData) {
        if (password.websiteName.toLowerCase().contains(input.toLowerCase())) {
          matchingPasswords.add(password);
        } else {
          nonMatchingPasswords.add(password);
        }
      }
      setState(() {
        displayedPasswords = [...matchingPasswords, ...nonMatchingPasswords];
      });
    } else {
      setState(() {
        displayedPasswords = List.from(Constants.passwordData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () => bottomModal(context),
          backgroundColor: Constants.fabBackground,
          child: const Icon(Icons.add),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
            child: Column(
              children: [
                profilePic(screenHeight),
                const SizedBox(height: 20),
                searchText(tSearchbox),
                const SizedBox(height: 10),
                HeadingText(tCategory),
                const SizedBox(height: 10),
                CategoryBoxes(),
                const SizedBox(height: 10),
                HeadingText("Recently Used"),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: displayedPasswords.length,
                  itemBuilder: (context, index) {
                    final password = displayedPasswords[index];
                    return PasswordTile(
                      password, 
                      context, 
                      highlight: index == 0 && _searchController.text.isNotEmpty
                    );
                  }
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget PasswordTile(passwords passwordO, BuildContext context, {bool highlight = false}) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 10),
      child: Container(
        decoration: BoxDecoration(
          color: highlight ? Colors.yellow.withOpacity(0.2) : null,  // Conditional highlight
          borderRadius: BorderRadius.circular(8.0)  // Adding some roundness to the tile
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // profile row
            Row(
              children: [
                EditIconButton(passwordO, context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0, 8, 0),
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
                      )
                    ],
                  ),
                )
              ],
            ),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: passwordO.password));
                // Optionally, you can show a Snackbar or Toast to notify the user that the password has been copied
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied to clipboard!')),
                );
              },
              child: SvgPicture.asset(
                "assets/copy.svg",
                semanticsLabel: 'Copy password icon',
                height: screenHeight * 0.030,
              ),
            )
          ],
        ),
      ),
    );
  }

Widget EditIconButton(passwords password, BuildContext context) {
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

Widget CategoryBoxes() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Column(
        children: [
          CategoryBox(
            outerColor: Constants.lightBlue,
            innerColor: Constants.darkBlue,
            logoAsset: "assets/codesandbox.svg",
          ),
          const SizedBox(height: 2.0),  // spacing between the box and the text
          const Text(
            "Login",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black, // or any desired color
            ),
          ),
        ],
      ),
      Column(
        children: [
          CategoryBox(
            outerColor: Constants.lightGreen,
            innerColor: Constants.darkGreen,
            logoAsset: "assets/compass.svg",
          ),
          const SizedBox(height: 2.0),
          const Text(
            "Note",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black, 
            ),
          ),
        ],
      ),
    ],
  );
}


  Widget circleAvatarRound() {
    return const CircleAvatar(
      radius: 28,
      backgroundColor: Color.fromARGB(255, 213, 213, 213),
      child: CircleAvatar(
        radius: 26.5,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/male_avatar.jpg"),
            radius: 25,
          ),
        ),
      ),
    );
  }

Widget profilePic(double screenHeight) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 35, 20.0, 5),
      child: Row(
        children: [
          circleAvatarRound(),
          const Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, Kenny",
                  style: TextStyle(
                    color: Color.fromARGB(255, 22, 22, 22),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Good morning",
                  style: TextStyle(
                    color: Color.fromARGB(255, 39, 39, 39),
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
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




Future<dynamic> bottomModal(BuildContext context, {passwords? passwordO}) {
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