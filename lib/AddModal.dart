import 'package:flutter/material.dart';
import 'src/constants/constants.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/models/password_model.dart';
import 'package:guardian_key/src/features/authentication/models/random_password.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:guardian_key/src/features/authentication/models/login_model.dart'; 
import 'package:guardian_key/src/features/authentication/controllers/addmodal_controller.dart';
import 'package:guardian_key/src/services/login_service.dart';


class AddModal extends StatefulWidget {
  final LoginModel? passwordO;

  const AddModal({Key? key, this.passwordO}) : super(key: key);

  @override
  AddModalState createState() => AddModalState();
}

class AddModalState extends State<AddModal> {
  String? selectedWebsite;
  String? selectedLoginId;
  final LoginService loginService = LoginService();
  TextEditingController websiteNameController = TextEditingController();
  TextEditingController userIDController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController(); // Create the password controller

  @override
  void initState() {
    super.initState();
    selectedWebsite = widget.passwordO?.websiteName;
    if (widget.passwordO != null) {
      selectedLoginId = widget.passwordO!.id;
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
            websiteContainer(context, loginService),
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
                        width: screenWidth * 1.0 * 0.8,
                        child: ElevatedButton(
                            // ... other properties ...
                            onPressed: () async {
                                // Create a new LoginModel instance with the data from text fields
                                LoginModel login = LoginModel(
                                  id: widget.passwordO?.id, // Add this line
                                  websiteName: websiteNameController.text.trim(),
                                  userID: userIDController.text.trim(),
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                                // Check if login already exists
                                LoginModel? existingLogin = await AddModalController.instance.getLoginByWebsiteName(login.websiteName);

                                if (existingLogin == null) {
                                    // Call the addLogin method to save the login
                                    AddModalController.instance.addLogin(login);
                                    Get.snackbar("Success", "Login added successfully!", snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
                                } else {
                                    // Call the updateLogin method to update the existing login
                                    AddModalController.instance.updateLogin(login);
                                    Get.snackbar("Success", "Login updated successfully!", snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
                                }

                                // Close the modal
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
                  width: screenHeight * 0.065,
                  child: ElevatedButton(
                    // ... other properties ...
                    onPressed: () async {
                      bool? shouldDelete = await showConfirmationDialog(context);
                      if (shouldDelete == true) {
                        // Delete the login based on the unique identifier
                        AddModalController.instance.deleteLogin(selectedLoginId ?? ''); // using websiteName as a unique ID for now

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

Widget websiteContainer(BuildContext context, LoginService loginService) {
  double screenHeight = MediaQuery.of(context).size.height;
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
            child: FutureBuilder<List<String>>(
              // Replace Constants.websiteList with a call to LoginService method
              future: loginService.fetchWebsiteList(), // Use fetchWebsiteList from loginService
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Loading indicator while fetching data
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Handle error
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Data is available, build the website blocks
                  List<String> websiteList = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: websiteList.length,
                    itemBuilder: (context, index) =>
                        websiteBlock(websiteList[index], context),
                  );
                }
              },
            ),
          ),
        ),
      ),
    ],
  );
}

void showAddModal(BuildContext context, {LoginModel? passwordO}) {
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
            child: AddModal(passwordO: passwordO),
          ),
        )
      ]);
    },
  );
}


  Widget websiteBlock(String websiteString, BuildContext context) {
    return FutureBuilder<LoginModel?>(
      // Replace Constants.passwordData with a call to LoginService method to get the selected password
      future: loginService.getPasswordByWebsiteName(websiteString), // Adjust the method name according to your LoginService
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Loading indicator while fetching data
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // Handle error
        return Text('Error: ${snapshot.error}');
      } else {
        final isSelected = websiteString == selectedWebsite;
        final selectedPassword = snapshot.data;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedWebsite = selectedPassword?.websiteName ?? 'DefaultWebsiteName';
            });

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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  websiteString,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    },
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
