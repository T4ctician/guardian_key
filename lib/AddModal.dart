import 'package:flutter/material.dart';
import 'src/constants/constants.dart';
import 'package:guardian_key/model/password_model.dart';
import 'package:guardian_key/model/random_password.dart';
import 'package:password_strength_checker/password_strength_checker.dart';


class AddModal extends StatefulWidget {
  final passwords? passwordO;

  const AddModal({Key? key, this.passwordO}) : super(key: key);

  @override
  AddModalState createState() => AddModalState();
}

class AddModalState extends State<AddModal> {
  String? selectedWebsite;
  TextEditingController websiteNameController = TextEditingController();
  TextEditingController userIDController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController(); // Create the password controller

  @override
  void initState() {
    super.initState();
    selectedWebsite = widget.passwordO?.websiteName;
    if (widget.passwordO != null) {
      websiteNameController.text = widget.passwordO!.websiteName ?? '';
      userIDController.text = widget.passwordO!.userID ?? '';
      emailController.text = widget.passwordO!.email ?? '';
      passwordController.text = widget.passwordO!.password ?? '';
    }
  }

  @override
  void dispose() {
    passwordController.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
      child: SingleChildScrollView(
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
            websiteContainer(context),
            Column(
              children: [
                formHeading("Website / Application Name"),
                formTextField("Enter Website/ Application Name", Icons.web, controller: websiteNameController),
                formHeading("Login ID"),
                formTextField("Enter Login ID", Icons.person, controller: userIDController),
                formHeading("E-mail"),
                formTextField("Enter Email", Icons.email, controller: emailController),
                formHeading("Password"),
                formTextField("Enter Password", Icons.lock_outline, controller: passwordController, showGenerateButton: true),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                // Ok Done Button
                SizedBox(
                  height: screenHeight * 0.065,
                  width: screenWidth * 1.0 * 0.8,  // Increased the width
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      shadowColor: MaterialStateProperty.all(Constants.buttonBackground),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          side: BorderSide(color: Constants.buttonBackground),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Constants.buttonBackground),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Ok Done",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                // Red Circle Delete Button
                Container(
                  height: screenHeight * 0.065,
                  width: screenHeight * 0.065,  // Making width equal to height to ensure it's a circle
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      shape: MaterialStateProperty.all<CircleBorder>(
                        CircleBorder(),
                      ),
                    ),
                    onPressed: () async {
                      bool? shouldDelete = await showConfirmationDialog(context);
                      if (shouldDelete == true) {
                        // Clearing the values
                        setState(() {
                          websiteNameController.clear();
                          userIDController.clear();
                          emailController.clear();
                          passwordController.clear();
                        });
                        // Close the modal
                        Navigator.of(context).pop();
                      }
                    },
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

final passNotifier = ValueNotifier<PasswordStrength?>(null);

Widget formTextField(String hintText, IconData icon, {TextEditingController? controller, bool showGenerateButton = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: controller,
          onChanged: (value) {
            if (hintText == "Enter Password") {
              passNotifier.value = PasswordStrength.calculate(text: value);
            }
          },
          decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 5, 5, 5), // add padding to adjust icon
                child: Icon(
                  icon,
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
      ),
      if (showGenerateButton) Padding(
        padding: const EdgeInsets.only(right: 10.0, top: 5.0),
        child: InkWell(
          onTap: () {
            String generatedPassword = generatePassword();  // <-- Updated this line
            passwordController.text = generatedPassword;
            passNotifier.value = PasswordStrength.calculate(text: generatedPassword);
          },
          child: Text('Generate Password', style: TextStyle(color: Colors.blue)),
        ),
      ),
      if (hintText == "Enter Password") Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: PasswordStrengthChecker(strength: passNotifier),
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

Widget websiteContainer(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  double screenWidth = MediaQuery.of(context).size.width;
  return Row(
    children: [
    GestureDetector(
      onTap: () {
        showAddModal(context);  // Open a new AddModal
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
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: Constants.websiteList.length,
                itemBuilder: (context, index) =>
                    websiteBlock(Constants.websiteList[index], context)),
          ),
        ),
      ),
    ],
  );
}

void showAddModal(BuildContext context, {passwords? passwordO}) {
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
            child: AddModal(passwordO: passwordO),  // Pass the passwordO to AddModal
          ),
        )
      ]);
    },
  );
}

  Widget websiteBlock(String websiteString, BuildContext context) {
    bool isSelected = websiteString == selectedWebsite;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWebsite = websiteString;
        });
        passwords? selectedPassword;
        try {
          selectedPassword = Constants.passwordData.firstWhere(
            (password) => password.websiteName.contains(websiteString)
          );
        } catch (e) {
          selectedPassword = null;
        }

        if (selectedPassword != null) {
          showAddModal(context, passwordO: selectedPassword);
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 3, 6, 3),
        child: Container(
          constraints: BoxConstraints(maxWidth: 200),
          height: 50,
          decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Constants.logoBackground, 
              borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Text(
              websiteString,
              style: TextStyle(fontSize: 14, color: isSelected ? Colors.white : Colors.black),
            ),
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
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete the logins?'),
          actions: <Widget>[
            TextButton(
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  Text('Yes', style: TextStyle(color: Colors.green)),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop(true);  // Return true when user taps 'Yes'
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
                Navigator.of(context).pop(false);  // Return false when user taps 'No'
              },
            ),
          ],
        );
      },
    );
}
  
}
