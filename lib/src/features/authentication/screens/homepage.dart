import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guardian_key/AddModal.dart';
import 'package:guardian_key/CategoryContainer.dart';
import 'package:guardian_key/constants.dart';
import 'package:guardian_key/model/password_model.dart';

class HomePage  extends StatelessWidget {
  const HomePage ({super.key});

  @override
  Widget build(BuildContext context) {
    const String assetName = 'assets/bell.svg';
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
        bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            child: SizedBox(
                height: 60,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset("assets/4square.svg"),
                      const SizedBox(
                        width: 10,
                      ),
                      SvgPicture.asset("assets/shield.svg")
                    ]))),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
            child: Column(
              children: [
                profilePicAndBellIcon(assetName, screenHeight),
                const SizedBox(
                  height: 20,
                ),
                searchText("Search Website/App Password"),
                const SizedBox(
                  height: 10,
                ),
                HeadingText("Category"),
                const SizedBox(
                  height: 10,
                ),
                CategoryBoxes(),
                const SizedBox(
                  height: 10,
                ),
                HeadingText("Recently Used"),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 200,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: Constants.passwordData.length,
                      itemBuilder: (context, index) {
                        final password = Constants.passwordData[index];
                        return PasswordTile(password, context);
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget PasswordTile(passwords password, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // profile row
          Row(
            children: [
              LogoBox(password, context),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      password.websiteName,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 22, 22, 22),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      password.email,
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
          SvgPicture.asset("assets/copy.svg",
              semanticsLabel: 'bell icon ', height: screenHeight * 0.030),
        ],
      ),
    );
  }

  Widget LogoBox(passwords password, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
            color: Constants.logoBackground,
            borderRadius: BorderRadius.circular(20)),
        child: FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 0.5,
            child: Image.network(password.logoUrl)));
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
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      CategoryBox(
          outerColor: Constants.lightBlue,
          innerColor: Constants.darkBlue,
          logoAsset: "assets/codesandbox.svg"),
      CategoryBox(
          outerColor: Constants.lightGreen,
          innerColor: Constants.darkGreen,
          logoAsset: "assets/compass.svg"),
      CategoryBox(
          outerColor: Constants.lightRed,
          innerColor: Constants.darkRed,
          logoAsset: "assets/credit-card.svg")
    ]);
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

  Widget profilePicAndBellIcon(String assetName, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 35, 20.0, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // profile row
          Row(
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
                    )
                  ],
                ),
              )
            ],
          ),
          SvgPicture.asset(assetName,
              semanticsLabel: 'bell icon ', height: screenHeight * 0.035),
        ],
      ),
    );
  }

  Widget searchText(String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
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

  Future<dynamic> bottomModal(BuildContext context) {
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
                    color: Colors
                        .white, //forDialog ? Color(0xFF737373) : Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0))),
                child: const AddModal(),
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
          searchText("Search for a website or app"),
          const SizedBox(
            height: 10,
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